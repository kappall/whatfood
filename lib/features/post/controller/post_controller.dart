import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:amplify_flutter/amplify_flutter.dart';
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
import 'package:whatfood/models/Comment.dart';
import 'package:whatfood/models/MealType.dart';
import 'package:whatfood/models/Post.dart';
import 'package:whatfood/models/User.dart';

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

final mealFilterProvider = StateProvider<MealType?>((ref) => null);

final postsProvider = StreamProvider((ref) {
  final postController = ref.watch(postControllerProvider.notifier);

  return postController.fetchPosts();
});

final viralPostsProvider = StreamProvider((ref) {
  final postController = ref.watch(postControllerProvider.notifier);

  return postController.fetchViralPosts();
});

final postByIdProvider = StreamProvider.family((ref, String id) {
  final posController = ref.watch(postControllerProvider.notifier);
  return posController.getPostById(id);
});

final getpostCommentsProvider = StreamProvider.family((ref, String id) {
  final posController = ref.watch(postControllerProvider.notifier);
  return posController.fetchCommentsOfPost(id);
});

final userNameProvider =
    StreamProvider.family<String, String>((ref, String uid) {
  final controller = StreamController<String>();

  try {
    String graphQLDocument = '''
      query GetUser {
        getUser(id: "$uid") {
          name
        }
      }
    ''';

    Amplify.API
        .query(
          request: GraphQLRequest<String>(document: graphQLDocument),
        )
        .response
        .then((response) {
      if (response.data != null) {
        final data = jsonDecode(response.data!)['getUser'];
        final name = data['name'] as String;
        controller.add(name);
      }
    }).catchError((error) {
      debugPrint('Error fetching username: $error');
      controller.addError(error);
    }).whenComplete(() {
      controller.close();
    });
  } catch (e) {
    controller.addError(e);
    controller.close();
  }

  return controller.stream;
});
final userPicProvider =
    StreamProvider.family<String, String>((ref, String uid) {
  final controller = StreamController<String>();

  try {
    String graphQLDocument = '''
      query GetUser {
        getUser(id: "$uid") {
          profilePic
        }
      }
    ''';

    Amplify.API
        .query(
          request: GraphQLRequest<String>(document: graphQLDocument),
        )
        .response
        .then((response) {
      if (response.data != null) {
        final data = jsonDecode(response.data!)['getUser'];
        final profilePic = data['profilePic'] as String;
        controller.add(profilePic);
      }
    }).catchError((error) {
      debugPrint('Error fetching profile pic: $error');
      controller.addError(error);
    }).whenComplete(() {
      controller.close();
    });
  } catch (e) {
    controller.addError(e);
    controller.close();
  }

  return controller.stream;
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

  Stream<List<Post>> fetchViralPosts({int limit = 5}) {
    return _postRepository.fetchViralPosts(limit);
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

  Future<void> createPost({
    required BuildContext context,
    required String title,
    required String content,
    required List<String> tags,
    required File? imageFile,
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
    try {
      final imageUrl;
      if (imageFile != null) {
        File processedFile;
        try {
          processedFile = await compressImage(imageFile);
        } catch (e) {
          if (context.mounted) {
            showSnackBar(context, 'Error compressing image: ${e.toString()}');
          }
          state = false;
          return;
        }

        final result = await _storageRepository.uploadImage(
          processedFile,
          postId,
        );

        imageUrl = result;
      } else {
        imageUrl = null;
      }

      final Post post = Post(
        id: postId,
        uid: user.id,
        title: title,
        content: content,
        authorImage: user.profilePic,
        authorname: user.name,
        createdAt: TemporalDateTime.now(),
        upVotes: [],
        downVotes: [],
        tags: tags,
        imageUrl: imageUrl,
        commentCount: 0,
      );

      final res = await _postRepository.addPost(post, user.postsCount);
      res.fold(
          (l) => ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l.message)),
              ),
          (r) => null);
    } catch (e) {
      if (context.mounted) {
        showSnackBar(context, 'Error: ${e.toString()}');
      }
    } finally {
      state = false;
    }
  }

  Future<void> deletePost(Post post, BuildContext context) async {
    final user = _ref.read(userProvider);

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not logged in')),
      );
      state = false;
      return;
    }

    final res =
        await _postRepository.deletePost(post.id, post.uid, user.postsCount);
    _ref.read(userProfileControllerProvider.notifier);
    res.fold((l) => showSnackBar(context, l.message), (r) {
      _ref.invalidate(getUserPostsProvider(user.id));
    });
  }

  Future<void> upvote(Post post, String uid) async {
    await _postRepository.upvote(post, uid);
  }

  Future<void> downvote(Post post, String uid) async {
    await _postRepository.downvote(post, uid);
  }

  Future<void> addOrRemoveBookmark(
    Post post,
    User user,
  ) async {
    await _postRepository.addOrRemoveBookmark(post, user);
  }

  Stream<Post> getPostById(String id) {
    return _postRepository.getPostById(id);
  }

  void addComment({
    required BuildContext context,
    required String content,
    required int commentCount,
    required String postId,
  }) async {
    final user = _ref.read(userProvider)!;
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
    _postRepository.addComment(
      comment,
      commentCount,
    );
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
