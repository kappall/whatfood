import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image/image.dart' as img;
import 'package:routemaster/routemaster.dart';
import 'package:uuid/uuid.dart';
import 'package:whatfood/core/providers/storage_repository_provider.dart';
import 'package:whatfood/core/utils.dart';
import 'package:whatfood/features/auth/controller/auth_controller.dart';
import 'package:whatfood/features/post/provider/post_provider.dart';
import 'package:whatfood/features/profile/controller/user_profile_controller.dart';
import 'package:whatfood/models/post_model.dart';

final postControllerProvider =
    StateNotifierProvider<PostController, bool>((ref) {
  final postRepository = ref.watch(postRepositoryProvider);
  final storageRepository = ref.watch(storageRepositoryProvider);
  return PostController(
    postRepository: postRepository,
    ref: ref,
    StorageRepository: storageRepository,
  );
});

class PostController extends StateNotifier<bool> {
  final PostRepository _postRepository;
  final Ref _ref;
  final StorageRepository _storageRepository;

  PostController({
    required PostRepository postRepository,
    required StorageRepository StorageRepository,
    required Ref ref,
  })  : _postRepository = postRepository,
        _storageRepository = StorageRepository,
        _ref = ref,
        super(false);

  Stream<List<Post>> fetchUserPosts(String uid) {
    return _postRepository.fetchUserPosts(uid);
  }

  void shareTextPost({
    required BuildContext context,
    required String title,
    required List<String> tags,
    required String description,
  }) async {
    state = true;
    final user = _ref.read(userProvider);
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
        Routemaster.of(context).push('/');
      },
    );
  }

  void shareLinkPost({
    required BuildContext context,
    required String title,
    required List<String> tags,
    required String link,
  }) async {
    state = true;
    final user = _ref.read(userProvider);
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
      link: link,
      uid: user.uid,
      username: user.name,
      createdAt: DateTime.now(),
      likes: [],
      tags: tags,
      commentCount: 0,
      type: 'link',
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
        Routemaster.of(context).push('/');
      },
    );
  }

  Future<File> compressImage(File file) async {
    img.Image? image = img.decodeImage(await file.readAsBytes());

    if (image == null) {
      throw Exception('Unable to decode image');
    }

    img.Image compressedImage = img.copyResize(image, width: 800);

    final compressedFile =
        File('${file.parent.path}/compressed_${file.uri.pathSegments.last}');
    await compressedFile
        .writeAsBytes(img.encodeJpg(compressedImage, quality: 85));

    return compressedFile;
  }

  Future<bool> isFileSizeValid(File file, int maxSizeInBytes) async {
    final fileSize = await file.length();
    return fileSize <= maxSizeInBytes;
  }

  void shareimagePost({
    required BuildContext context,
    required String title,
    required List<String> tags,
    required List<File> files,
  }) async {
    state = true;
    final user = _ref.read(userProvider);
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not logged in')),
      );
      state = false;
      return;
    }

    String postId = const Uuid().v1();
    List<String> imageUrls = [];

    try {
      for (var file in files) {
        bool isValidSize = await isFileSizeValid(file, 1024 * 1024); // 1MB
        if (!isValidSize) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text(
                    'File size exceeds 1MB, please upload smaller images.')),
          );
          state = false;
          return;
        }

        File compressedFile = await compressImage(file);

        final imageId = const Uuid().v1();
        final result = await _storageRepository.storeFile(
          path: 'posts',
          id: imageId,
          file: compressedFile,
        );

        final imageUrl = result.fold(
          (l) => throw Exception(l.message),
          (r) => r,
        );

        imageUrls.add(imageUrl);
      }

      final Post post = Post(
        id: postId,
        title: title,
        uid: user.uid,
        username: user.name,
        createdAt: DateTime.now(),
        likes: [],
        tags: tags,
        imageUrls: imageUrls,
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
          Routemaster.of(context).push('/');
        },
      );
    } catch (e) {
      state = false;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  void deletePost(Post post, BuildContext context) async {
    final res = await _postRepository.deletePost(post);
    _ref.read(userProfileControllerProvider.notifier);
    res.fold((l) => null,
        (r) => showSnackBar(context, 'Post Deleted successfully!'));
  }
}
