import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image/image.dart' as img;
import 'package:routemaster/routemaster.dart';
import 'package:uuid/uuid.dart';
import 'package:whatfood/core/providers/storage_repository_provider.dart';
import 'package:whatfood/core/utils.dart';
import 'package:whatfood/features/auth/controller/auth_controller.dart';
import 'package:whatfood/features/post/repository/post_repository.dart';
import 'package:whatfood/features/profile/controller/user_profile_controller.dart';
import 'package:whatfood/models/comment_model.dart';
import 'package:whatfood/models/post_model.dart';

final postControllerProvider =
    StateNotifierProvider<PostController, bool>((ref) {
  final postRepository = ref.watch(postRepositoryProvider);
  final storageRepository = ref.watch(storageRepositoryProvider);
  return PostController(
    postRepository: postRepository,
    ref: ref,
    storageRepository: storageRepository,
  );
});

final postsProvider = StreamProvider((ref) {
  final postController = ref.watch(postControllerProvider.notifier);

  return postController.fetchPosts();
});

final postByIdProvider = StreamProvider.family((ref, String id) {
  final posController = ref.watch(postControllerProvider.notifier);
  return posController.getPostById(id);
});

final getpostCommentsProvider = StreamProvider.family((ref, String id) {
  final posController = ref.watch(postControllerProvider.notifier);
  return posController.fetchCommentsOfPost(id);
});

class PostController extends StateNotifier<bool> {
  final PostRepository _postRepository;
  final Ref _ref;
  final StorageRepository _storageRepository;

  PostController({
    required PostRepository postRepository,
    required StorageRepository storageRepository,
    required Ref ref,
  })  : _postRepository = postRepository,
        _storageRepository = storageRepository,
        _ref = ref,
        super(false);

  Stream<List<Post>> fetchPosts() {
    return _postRepository.fetchPosts();
  }

  void shareTextPost({
    required BuildContext context,
    required String title,
    required List<String> tags,
    required String description,
  }) async {
    state = true;
    final user = _ref.watch(userProvider);

    debugPrint('Current user for text post: ${user?.uid}');

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not logged in')),
      );
      state = false;
      return;
    }

    String postId = const Uuid().v1();

    final Post post = Post(
      id: postId,
      title: title,
      description: description,
      uid: user.uid,
      userImage: user.profilePic,
      username: user.name,
      createdAt: DateTime.now(),
      likes: [],
      tags: tags,
      commentCount: 0,
      type: 'text',
    );

    final res = await _postRepository.addPost(post);
    state = false;
    res.fold(
      (l) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.message)),
      ),
      (r) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Posted successfully!')),
        );
        Routemaster.of(context).popUntil((route) => route.path == '/');
      },
    );
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

  void shareimagePost({
    required BuildContext context,
    required String title,
    required List<String> tags,
    required File image,
  }) async {
    state = true;
    final user = _ref.watch(userProvider);

    debugPrint('Current user: ${user?.uid}');

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not logged in')),
      );
      state = false;
      return;
    }

    String postId = const Uuid().v1();

    try {
      File processedFile;
      try {
        processedFile = await compressImage(image);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error compressing image: ${e.toString()}')),
        );
        state = false;
        return;
      }

      final imageId = const Uuid().v1();
      final result = await _storageRepository.storeFile(
        path: 'posts',
        id: imageId,
        file: processedFile,
      );

      final imageUrl = result.fold(
        (l) => throw Exception(l.message),
        (r) => r,
      );

      final Post post = Post(
        id: postId,
        title: title,
        uid: user.uid,
        userImage: user.profilePic,
        username: user.name,
        createdAt: DateTime.now(),
        likes: [],
        tags: tags,
        imageUrl: imageUrl,
        commentCount: 0,
        type: 'image',
      );

      final res = await _postRepository.addPost(post);
      state = false;
      res.fold(
        (l) => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l.message)),
        ),
        (r) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Posted successfully!')),
          );
          Routemaster.of(context).popUntil((route) => route.path == '/');
        },
      );
    } catch (e) {
      state = false;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  void deletePost(String id, BuildContext context) async {
    final res = await _postRepository.deletePost(id);
    _ref.read(userProfileControllerProvider.notifier);
    res.fold((l) => null,
        (r) => showSnackBar(context, 'Post Deleted successfully!'));
  }

  void likeOrUnlike(Post post) async {
    final uid = _ref.read(userProvider)!.uid;
    _postRepository.likeOrUnlike(post, uid);
  }

  Stream<Post> getPostById(String id) {
    return _postRepository.getPostById(id);
  }

  void addComment({
    required BuildContext context,
    required String content,
    required String postId,
  }) async {
    final user = _ref.read(userProvider)!;
    String cId = const Uuid().v1();
    Comment comment = Comment(
        id: cId,
        text: content,
        createdAt: DateTime.now(),
        postId: postId,
        username: user.name,
        profilePic: user.profilePic,
        uid: user.uid);
    _postRepository.addComment(comment);
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
}
