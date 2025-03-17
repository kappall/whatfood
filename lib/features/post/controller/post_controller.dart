import 'dart:io';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image/image.dart' as img;
import 'package:routemaster/routemaster.dart';
import 'package:whatfood/core/providers/storage_repository_provider.dart';
import 'package:whatfood/core/utils.dart';
import 'package:whatfood/features/auth/controller/auth_controller.dart';
import 'package:whatfood/features/post/repository/post_repository.dart';
import 'package:whatfood/models/MealType.dart';
import 'package:whatfood/models/User.dart';
import 'package:whatfood/models/Comment.dart';
import 'package:whatfood/models/Post.dart';

class PostController {
  final PostRepository _postRepository;
  final StorageRepository _storageRepository;
  // If needed, inject a currentUser or a way to retrieve it.
  User? currentUser;

  PostController({
    required PostRepository postRepository,
    required StorageRepository storageRepository,
    this.currentUser,
  })  : _postRepository = postRepository,
        _storageRepository = storageRepository;

  Stream<List<Post>> fetchPosts() {
    return _postRepository.fetchPosts();
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
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not logged in')),
      );
      return;
    }

    final String postId = const Uuid().v1();
    try {
      File processedFile = await compressImage(image);
      final imageUrl =
          await _storageRepository.uploadImage(processedFile, currentUser!.uid);

      final Post post = Post(
        id: postId,
        uid: currentUser!.uid,
        description: description,
        userImage: currentUser!.profilePic,
        username: currentUser!.name,
        createdAt: TemporalDateTime.now(),
        likes: [],
        tags: tags,
        imageUrl: imageUrl,
        commentCount: 0,
        type: 'image',
        mealType: mealType,
      );

      final res = await _postRepository.addPost(post, currentUser!.postsCount);
      res.fold(
        (failure) => ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(failure.message))),
        (_) {
          // Navigate back after success.
          Navigator.of(context).popUntil((route) => route.settings.name == '/');
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

  void likeOrUnlike(Post post) async {
    final uid = User.fromJson(await getUserData()).uid;
    _postRepository.likeOrUnlike(post, uid);
  }

  Future<void> addOrRemoveBookmark(
    Post post,
  ) async {
    final user = User.fromJson(await getUserData());
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
    final user = User.fromJson(await getUserData());
    String cId = const Uuid().v1();
    Comment comment = Comment(
      id: cId,
      text: content,
      createdAt: TemporalDateTime.now(),
      postID: postId,
      username: user.name,
      userImage: user.profilePic,
      uid: user.uid,
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
