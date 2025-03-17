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
      // Create the post in the backend
      String createPostMutation = '''
      mutation CreatePost {
        createPost(input: ${jsonEncode(post.toMap())}) {
          id
        }
      }
      ''';
      final createRequest =
          GraphQLRequest<String>(document: createPostMutation);
      await Amplify.API.mutate(request: createRequest).response;

      // Update the user's postsCount
      String updateUserMutation = '''
      mutation UpdateUser {
        updateUser(input: { uid: "${post.uid}", postsCount: ${postsCount + 1} }) {
          uid
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
    // Create a StreamController
    final controller = StreamController<List<Post>>();

    // Define the GraphQL query to fetch posts
    var postsQuery = '''
    query ListPosts {
      listPosts(sortDirection: DESC, sortField: createdAt) {
        items {
          ${PostGraphQLFields.graphQLFields}
        }
      }
    }
    ''';

    // Create a GraphQL request
    final request = GraphQLRequest<String>(document: postsQuery);

    // Fetch posts asynchronously
    Amplify.API.query(request: request).response.then((response) {
      final data = response.data;
      if (data != null) {
        final Map<String, dynamic> decoded = jsonDecode(data);
        final List<dynamic> items = decoded['data']['listPosts']['items'];
        final posts = items
            .map((item) => Post.fromJson(item as Map<String, dynamic>))
            .toList();
        // Add the posts to the stream
        controller.add(posts);
      } else {
        // Add an empty list to the stream if no data is found
        controller.add([]);
      }
    }).catchError((error) {
      // Add an error to the stream in case of an exception
      controller.addError(error);
    }).whenComplete(() {
      // Close the stream when the operation is complete
      controller.close();
    });

    // Return the stream
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
      await Amplify.API.mutate(request: deleteRequest).response;

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

  FutureEither<void> deletePost(String id, String uid) async {
    try {
      // Remove the post's media from S3 storage
      Amplify.Storage.remove(path: StoragePath.fromString('posts/$id'));

      String deletePostMutation = '''
      mutation DeletePost {
        deletePost(input: { id: "$id" }) {
          id
        }
      }
      ''';
      final deleteRequest =
          GraphQLRequest<String>(document: deletePostMutation);
      await Amplify.API.mutate(request: deleteRequest).response;

      // Update the user's posts count
      String updateUserMutation = '''
      mutation UpdateUser {
        updateUser(input: { uid: "$uid", postsCount: -1 }) {
          uid
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
        updateUser(input: { uid: "${user.uid}", savedPosts: ${jsonEncode(updatedBookmarks)} }) {
          uid
        }
      }
      ''';
      final request = GraphQLRequest<String>(document: updateUserMutation);
      await Amplify.API.mutate(request: request).response;
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<Post?> getPostById(String id) async {
    String query = '''
    query GetPost {
      getPost(id: "$id") {
        ${PostGraphQLFields.graphQLFields}
      }
    }
    ''';
    final request = GraphQLRequest<String>(document: query);
    var operation = Amplify.API.query(request: request);
    var response = await operation.response;
    var data = response.data;

    if (data == null) {
      return null;
    }

    var json = jsonDecode(data);
    return Post.fromJson(json);
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
