import 'dart:io';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:routemaster/routemaster.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:image/image.dart' as img;
import 'package:whatfood/core/providers/storage_repository_provider.dart';
import 'package:whatfood/core/utils.dart';
import 'package:whatfood/features/auth/controller/auth_controller.dart';
import 'package:whatfood/features/post/repository/post_repository.dart';
import 'package:whatfood/models/MealType.dart';
import 'package:whatfood/models/Comment.dart';
import 'package:whatfood/models/Post.dart';

get postControllerProvider {
  return PostController(
      postRepository: PostRepository(), storageRepository: StorageRepository());
}

class PostController {
  final PostRepository _postRepository;
  final StorageRepository _storageRepository;
  final Map<String, bool> _expandedStates = {};
  final Set<String> _likes = {};

  PostController({
    required PostRepository postRepository,
    required StorageRepository storageRepository,
  })  : _postRepository = postRepository,
        _storageRepository = storageRepository;

  Stream<List<Post>> fetchPosts() {
    return _postRepository.fetchPosts();
  }

  ValueNotifier<bool> getExpandedStateNotifier(String postId) =>
      ValueNotifier(_expandedStates[postId] ?? false);

  ValueNotifier<Set<String>> get likesNotifier => ValueNotifier(_likes);

  void toggleDescriptionExpansion(String postId) {
    _expandedStates[postId] = !(_expandedStates[postId] ?? false);
  }

  void likeOrUnlike(Post post) async {
    if (_likes.contains(post.id)) {
      _likes.remove(post.id);
    } else {
      _likes.add(post.id);
    }
    final user = (await getUserData())!;
    _postRepository.likeOrUnlike(post, user.id);
  }

  Future<File> compressImage(File file,
      {int maxSizeInBytes = 1024 * 1024}) async {
    final originalSize = await file.length();
    debugPrint('Original size: ${originalSize / 1024} KB');

    if (originalSize <= maxSizeInBytes) {
      debugPrint('Image already under size limit, skipping compression');
      return file;
    }

    img.Image? image = img.decodeImage(await file.readAsBytes());
    if (image == null) throw Exception('Unable to decode image');

    double scaleFactor = 1.0;
    if (originalSize > 2 * maxSizeInBytes) {
      scaleFactor = 0.5;
    } else if (originalSize > 1.5 * maxSizeInBytes) {
      scaleFactor = 0.7;
    } else {
      scaleFactor = 0.8;
    }

    final newWidth = (image.width * scaleFactor).round();
    img.Image resizedImage = img.copyResize(image, width: newWidth);

    final qualities = [85, 70, 60, 50];
    File? compressedFile;

    for (int quality in qualities) {
      final tempFile =
          File('${file.parent.path}/compressed_${file.uri.pathSegments.last}');
      await tempFile
          .writeAsBytes(img.encodeJpg(resizedImage, quality: quality));

      final newSize = await tempFile.length();
      debugPrint('Compressed size with quality $quality: ${newSize / 1024} KB');

      if (newSize <= maxSizeInBytes) {
        compressedFile = tempFile;
        debugPrint(
            'Successfully compressed image to ${newSize / 1024} KB with quality $quality');
        break;
      }
    }

    if (compressedFile == null) {
      throw Exception(
          'Unable to compress image to under 1MB while maintaining acceptable quality');
    }

    return compressedFile;
  }

  Future<bool> isFileSizeValid(File file, int maxSizeInBytes) async {
    final fileSize = await file.length();
    debugPrint('Checking file size: ${fileSize / 1024} KB');
    return fileSize <= maxSizeInBytes;
  }

  Future<void> shareImagePost({
    required BuildContext context,
    required String description,
    required List<String> tags,
    required File image,
    required MealType mealType,
  }) async {
    try {
      final user = (await getUserData())!;

      final String postId = const Uuid().v1();
      File processedFile = await compressImage(image);
      final imageUrl =
          await _storageRepository.uploadImage(processedFile, user.id);

      final Post post = Post(
        id: postId,
        uid: user.id,
        description: description,
        userImage: user.profilePic,
        username: user.name,
        createdAt: TemporalDateTime.now(),
        likes: [],
        tags: tags,
        imageUrl: imageUrl,
        commentCount: 0,
        type: 'image',
        mealType: mealType,
      );

      final res = await _postRepository.addPost(post, user.postsCount);
      res.fold(
        (failure) => debugPrint(failure.message),
        (_) {
          Routemaster.of(context).replace('/');
        },
      );
    } catch (e) {
      if (context.mounted) {
        showSnackBar(context, 'Error: ${e.toString()}');
      }
    }
  }

  void deletePost(Post post, BuildContext context) async {
    final res = await _postRepository.deletePost(post.id, post.uid);
    res.fold((l) => null,
        (r) => showSnackBar(context, 'Post Deleted successfully!'));
  }

  Future<void> addOrRemoveBookmark(
    Post post,
  ) async {
    final user = (await getUserData())!;
    await _postRepository.addOrRemoveBookmark(post, user);
  }

  Future<Post?> getPostById(String id) {
    return _postRepository.getPostById(id);
  }

  void addComment({
    required BuildContext context,
    required String content,
    required String postId,
    required int commentCount,
  }) async {
    final user = (await getUserData())!;
    String cId = const Uuid().v1();
    Comment comment = Comment(
      id: cId,
      text: content,
      createdAt: TemporalDateTime.now(),
      postID: postId,
      username: user.name,
      userImage: user.profilePic,
      uid: user.id,
      likes: [],
    );
    _postRepository.addComment(comment, commentCount);
  }

  void deleteComment({
    required String commentId,
    required String postId,
    required BuildContext context,
  }) async {
    await _postRepository.deleteComment(commentId, postId);
    debugPrint("comment deleted");
  }

  Stream<List<Comment>> fetchCommentsOfPost(String postId) {
    return _postRepository.getCommentsOfPost(postId);
  }

  Future<String> getUserName(String uid) async {
    return await _postRepository.getUserName(uid);
  }
}
