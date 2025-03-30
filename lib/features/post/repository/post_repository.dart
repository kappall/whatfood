import 'dart:async';
import 'dart:convert';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:whatfood/core/failure.dart';
import 'package:whatfood/core/type_def.dart';
import 'package:whatfood/models/Comment.dart';
import 'package:whatfood/models/User.dart';
import 'package:whatfood/models/Post.dart';
import 'package:whatfood/models/comment_extensions.dart';
import 'package:whatfood/models/post_extensions.dart';

final postRepositoryProvider = Provider((ref) {
  return PostRepository();
});

class PostRepository {
  FutureEither<void> addPost(Post post, int postsCount) async {
    try {
      Map<String, Object?> postMap = {
        "input": {
          "id": post.id,
          "description": post.description,
          "likes": post.likes,
          "username": post.username,
          "uid": post.uid,
          "userImage": post.userImage,
          "type": post.type,
          "createdAt": post.createdAt.toString(),
          "commentCount": post.commentCount,
          "imageUrl": post.imageUrl,
          "tags": post.tags,
          "mealType": post.mealType.name,
        }
      };

      String graphQLDocument = '''
    mutation CreatePost(\$input: CreatePostInput!) {
      createPost(input: \$input) {
        id
      }
    }
    ''';

      var operation = Amplify.API.mutate(
        request: GraphQLRequest<String>(
          document: graphQLDocument,
          variables: postMap,
        ),
      );

      final response = await operation.response;

      if (response.errors.isNotEmpty) {
        throw Exception(response.errors.first.message);
      }

      String updateUserMutation = '''
    mutation UpdateUser {
      updateUser(input: { id: "${post.uid}", postsCount: ${postsCount + 1} }) {
        id
      }
    }
    ''';

      final updateRequest =
          GraphQLRequest<String>(document: updateUserMutation);
      await Amplify.API.mutate(request: updateRequest).response;

      return right(null);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Stream<List<Comment>> getCommentsOfPost(String postId) {
    final controller = StreamController<List<Comment>>();
    String query = '''
    query GetComments {
      listComments(filter: { postId: { eq: "$postId" } }, sortDirection: DESC, sortField: createdAt) {
        items {
          ${CommentGraphQLFields.graphQLFields}
        }
      }
    }
  ''';

    final request = GraphQLRequest<String>(document: query);
    Amplify.API
        .query(request: request)
        .response
        .then((response) {
          if (response.data != null) {
            final Map<String, dynamic> decoded =
                jsonDecode(response.data!) as Map<String, dynamic>;
            final List<dynamic> items =
                decoded['data']['listComments']['items'];
            final comments =
                items.map((data) => Comment.fromJson(data)).toList();
            controller.add(comments);
          } else {
            controller.add([]);
          }
        })
        .whenComplete(() => controller.close())
        .catchError((error) {
          controller.addError(error);
        });

    return controller.stream;
  }

  Stream<List<Post>> fetchPosts() {
    final controller = StreamController<List<Post>>();

    try {
      var postsQuery = '''
        query ListPosts {
          listPosts(limit: 100) {
            items {
              ${PostGraphQLFields.graphQLFields}
            }
          }
        }
      ''';

      final request = GraphQLRequest<String>(document: postsQuery);

      Amplify.API.query(request: request).response.then((response) {
        if (response.errors.isNotEmpty) {
          debugPrint("GraphQL Errors: ${response.errors}");
          controller.addError(response.errors.first.message);
          return;
        }

        if (response.data == null) {
          controller.add([]);
          return;
        }

        try {
          final Map<String, dynamic> jsonResponse = jsonDecode(response.data!);
          if (jsonResponse['listPosts'] == null ||
              jsonResponse['listPosts']['items'] == null) {
            controller.add([]);
            return;
          }

          final List<dynamic> items = jsonResponse['listPosts']['items'];
          final posts = items.map((item) => Post.fromJson(item)).toList();

          // Sort by creation date, newest first
          posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));

          controller.add(posts);
        } catch (e, stackTrace) {
          debugPrint("Parse error: $e");
          debugPrint("Stack trace: $stackTrace");
          controller.addError('Error parsing posts: $e');
        }
      }).catchError((error) {
        debugPrint("Query error: $error");
        controller.addError(error);
      });
    } catch (e) {
      debugPrint("General error: $e");
      controller.addError(e);
    }

    return controller.stream;
  }

  FutureEither<void> addComment(Comment comment, int commentCount) async {
    try {
      String createCommentMutation = '''
      mutation CreateComment {
        createComment(input: ${jsonEncode(comment.toMap())}) {
          id
        }
      }
      ''';
      final commentRequest =
          GraphQLRequest<String>(document: createCommentMutation);
      await Amplify.API.mutate(request: commentRequest).response;

      // Update the post's comment count
      String updatePostMutation = '''
      mutation UpdatePost {
        updatePost(input: { id: "${comment.postID}", commentCount: ${commentCount + 1} }) {
          id
        }
      }
      ''';
      final updatePostRequest =
          GraphQLRequest<String>(document: updatePostMutation);
      await Amplify.API.mutate(request: updatePostRequest).response;

      return right(null);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  FutureEither<void> deleteComment(String commentId, String postId) async {
    try {
      String deleteCommentMutation = '''
      mutation DeleteComment {
        deleteComment(input: { id: "$commentId" }) {
          id
        }
      }
      ''';
      final deleteRequest =
          GraphQLRequest<String>(document: deleteCommentMutation);
      final ret = await Amplify.API.mutate(request: deleteRequest).response;
      debugPrint(ret.toString());
      // Decrement post comment count
      String updatePostMutation = '''
      mutation UpdatePost {
        updatePost(input: { id: "$postId", commentCount: -1 }) {
          id
        }
      }
      ''';
      final updateRequest =
          GraphQLRequest<String>(document: updatePostMutation);
      await Amplify.API.mutate(request: updateRequest).response;

      return right(null);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Future<void> deleteImageFolder(String id) async {
    try {
      // Ottieni tutti i file nella cartella
      final listResult = await Amplify.Storage.list(
              path: StoragePath.fromString('images/$id/'))
          .result;
      // Elimina ogni file individualmente
      for (final item in listResult.items) {
        await Amplify.Storage.remove(path: StoragePath.fromString(item.path))
            .result;
      }

      debugPrint('Cartella eliminata con successo!');
    } catch (e) {
      debugPrint('Errore nell\'eliminazione della cartella: $e');
    }
  }

  FutureEither<void> deletePost(String id, String uid, int postsCount) async {
    try {
      // First try to delete from GraphQL to ensure the post exists
      final deletePostRequest = GraphQLRequest<String>(
        document: '''
      mutation DeletePost(\$input: DeletePostInput!) {
        deletePost(input: \$input) {
          ${PostGraphQLFields.graphQLFields}
        }
      }
      ''',
        variables: {
          'input': {'id': id}
        },
      );

      // Delete the post from API
      await Amplify.API.mutate(request: deletePostRequest).response;
      // Try to delete the image from storage
      try {
        await deleteImageFolder(id);
      } catch (storageError) {
        debugPrint('Storage delete error: $storageError');
        // Continue with post deletion even if storage deletion fails
      }

      // Update user post count
      final updateUserRequest = GraphQLRequest<String>(
        document: '''
      mutation UpdateUser {
        updateUser(input: { id: "$uid", postsCount: ${postsCount - 1} }) {
          id
        }
      }
      ''',
      );
      await Amplify.API.mutate(request: updateUserRequest).response;

      return right(null);
    } catch (e) {
      debugPrint('Delete post error: $e');
      return left(Failure(e.toString()));
    }
  }

  Future<void> likeOrUnlike(Post post, String uid) async {
    try {
      List<String> updatedLikes = List.from(post.likes);

      if (post.likes.contains(uid)) {
        updatedLikes.remove(uid);
      } else {
        updatedLikes.add(uid);
      }
      String updateLikesMutation = '''
      mutation UpdatePost {
        updatePost(input: { id: "${post.id}", likes: ${jsonEncode(updatedLikes)} }) {
          id
        }
      }
      ''';
      final request = GraphQLRequest<String>(document: updateLikesMutation);

      await Amplify.API.mutate(request: request).response;
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> addOrRemoveBookmark(Post post, User user) async {
    try {
      List<String> updatedBookmarks = List.from(user.savedPosts);
      if (user.savedPosts.contains(post.id)) {
        updatedBookmarks.remove(post.id);
      } else {
        updatedBookmarks.add(post.id);
      }
      String updateUserMutation = '''
      mutation UpdateUser {
        updateUser(input: { id: "${user.id}", savedPosts: ${jsonEncode(updatedBookmarks)} }) {
          id
        }
      }
      ''';
      final request = GraphQLRequest<String>(document: updateUserMutation);
      await Amplify.API.mutate(request: request).response;
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Stream<Post> getPostById(String id) {
    final controller = StreamController<Post>();
    try {
      String query = '''
    query GetPost {
      getPost(id: "$id") {
        ${PostGraphQLFields.graphQLFields}
      }
    }
    ''';
      final request = GraphQLRequest<String>(document: query);
      Amplify.API.query(request: request).response.then((response) {
        if (response.data == null) {
          return;
        }
        try {
          var json = jsonDecode(response.data!)['getPost'];
          final post = Post.fromJson(json);
          controller.add(post);
        } catch (e) {
          debugPrint("Error parsing post data: $e");
          controller.addError(e);
        }
      }).catchError((error) {
        debugPrint("Error fetching user: $error");
        controller.addError(error);
      }).whenComplete(() {
        controller.close();
      });
    } catch (e) {
      controller.addError(e);
      controller.close();
    }

    return controller.stream;
  }

  Future<String> getUserName(String uid) async {
    String query = '''
    query GetUser {
      getUser(uid: "$uid") {
        name
      }
    }
    ''';
    final request = GraphQLRequest<String>(document: query);
    final response = await Amplify.API.query(request: request).response;
    final data = jsonDecode(response.data!) as Map<String, dynamic>;
    return data['getUser']['name'] as String? ?? 'Unknown';
  }
}
