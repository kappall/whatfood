import 'dart:convert';

import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:whatfood/core/failure.dart';
import 'package:whatfood/core/providers/aws_providers.dart';
import 'package:whatfood/models/Post.dart';
import 'package:whatfood/models/User.dart';
import 'package:whatfood/models/post_extensions.dart';

final userProfileRepositoryProvider = Provider((ref) {
  return UserProfileRepository(auth: ref.read(authProvider));
});

class UserProfileRepository {
  final AmplifyAuthCognito _auth;
  UserProfileRepository({required AmplifyAuthCognito auth}) : _auth = auth;

  // Aggiorna il profilo utente tramite una mutation GraphQL
  Future<Either<Failure, void>> editProfile(User user) async {
    try {
      // La mutation updateUser aggiorna i campi dell'utente.
      String updateMutation = '''
        mutation UpdateUser(\$id: ID!, \$data: UserInput!) {
          updateUser(input: { id: \$id, ...\$data }) {
            id
          }
        }
      ''';

      final request = GraphQLRequest<String>(
        document: updateMutation,
        variables: {
          'id': user.uid,
          // Assicurati che user.toMap() restituisca una mappa conforme al tipo UserInput definito nello schema
          'data': user.toMap(),
        },
      );

      final response = await Amplify.API.mutate(request: request).response;
      if (response.errors.isNotEmpty) {
        return left(Failure(response.errors.first.message));
      }
      return right(null);
    } on ApiException catch (e) {
      return left(Failure(e.message));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  // Recupera i post dell'utente tramite una query GraphQL
  Future<List<Post>> getUserPosts(String uid) async {
    String query = '''
      query ListUserPosts(\$uid: ID!) {
        listPosts(filter: { uid: { eq: \$uid } }, sortDirection: DESC, sortField: createdAt) {
          items {
            ${PostGraphQLFields.graphQLFields}
          }
        }
      }
    ''';

    final request = GraphQLRequest<String>(
      document: query,
      variables: {'uid': uid},
    );

    final response = await Amplify.API.query(request: request).response;
    if (response.data == null) return [];
    final Map<String, dynamic> decoded =
        jsonDecode(response.data!) as Map<String, dynamic>;
    final List<dynamic> items =
        decoded['data']['listPosts']['items'] as List<dynamic>;
    return items
        .map((item) => Post.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  // Recupera i post salvati (in base agli id) tramite una query GraphQL
  Future<List<Post>> getUserSavedPosts(List<String> savedPosts) async {
    if (savedPosts.isEmpty) return [];
    String query = '''
      query GetUserSavedPosts(\$ids: [ID!]!) {
        listPosts(filter: { id: { in: \$ids } }, sortDirection: DESC, sortField: createdAt) {
          items {
            ${PostGraphQLFields.graphQLFields}
          }
        }
      }
    ''';

    final request = GraphQLRequest<String>(
      document: query,
      variables: {'ids': savedPosts},
    );

    final response = await Amplify.API.query(request: request).response;
    if (response.data == null) return [];
    final Map<String, dynamic> decoded =
        jsonDecode(response.data!) as Map<String, dynamic>;
    final List<dynamic> items =
        decoded['data']['listPosts']['items'] as List<dynamic>;
    return items
        .map((item) => Post.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  // Logout utente utilizzando Amplify Auth (rimane invariato)
  Future<void> logOut() async {
    await _auth.signOut();
  }

  // Elimina l'account utente e tutti i dati associati tramite chiamate GraphQL
  Future<Either<Failure, void>> deleteAccount() async {
    try {
      final user = await _auth.getCurrentUser();
      final String uid = user.userId;

      // Mutation per eliminare un post
      String deletePostMutation = '''
        mutation DeletePost(\$id: ID!) {
          deletePost(input: { id: \$id }) {
            id
          }
        }
      ''';

      // Query per recuperare tutti i post dell'utente
      String postsQuery = '''
        query ListUserPosts(\$uid: ID!) {
          listPosts(filter: { uid: { eq: \$uid } }) {
            items { id }
          }
        }
      ''';
      final postsRequest = GraphQLRequest<String>(
        document: postsQuery,
        variables: {'uid': uid},
      );
      final postsResponse =
          await Amplify.API.query(request: postsRequest).response;
      if (postsResponse.data != null) {
        final Map<String, dynamic> decodedPosts =
            jsonDecode(postsResponse.data!) as Map<String, dynamic>;
        final List<dynamic> postItems =
            decodedPosts['data']['listPosts']['items'] as List<dynamic>;
        for (var post in postItems) {
          final String postId = post['id'];
          final deletePostRequest = GraphQLRequest<String>(
            document: deletePostMutation,
            variables: {'id': postId},
          );
          await Amplify.API.mutate(request: deletePostRequest).response;
        }
      }

      // Mutation per eliminare una ricetta
      String deleteRecipeMutation = '''
        mutation DeleteRecipe(\$id: ID!) {
          deleteRecipe(input: { id: \$id }) {
            id
          }
        }
      ''';

      // Query per recuperare le ricette dell'utente
      String recipesQuery = '''
        query ListUserRecipes(\$uid: ID!) {
          listRecipes(filter: { uid: { eq: \$uid } }) {
            items { id }
          }
        }
      ''';
      final recipesRequest = GraphQLRequest<String>(
        document: recipesQuery,
        variables: {'uid': uid},
      );
      final recipesResponse =
          await Amplify.API.query(request: recipesRequest).response;
      if (recipesResponse.data != null) {
        final Map<String, dynamic> decodedRecipes =
            jsonDecode(recipesResponse.data!) as Map<String, dynamic>;
        final List<dynamic> recipeItems =
            decodedRecipes['data']['listRecipes']['items'] as List<dynamic>;
        for (var recipe in recipeItems) {
          final String recipeId = recipe['id'];
          final deleteRecipeRequest = GraphQLRequest<String>(
            document: deleteRecipeMutation,
            variables: {'id': recipeId},
          );
          await Amplify.API.mutate(request: deleteRecipeRequest).response;
        }
      }

      // Mutation per eliminare l'utente dal database
      String deleteUserMutation = '''
        mutation DeleteUser(\$id: ID!) {
          deleteUser(input: { id: \$id }) {
            id
          }
        }
      ''';
      final deleteUserRequest = GraphQLRequest<String>(
        document: deleteUserMutation,
        variables: {'id': uid},
      );
      await Amplify.API.mutate(request: deleteUserRequest).response;

      // Elimina l'account utente da Auth
      await _auth.deleteUser();

      return right(null);
    } on ApiException catch (e) {
      return left(Failure(e.message));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  // Segui o smetti di seguire un utente tramite le rispettive mutation GraphQL
  Future<void> followOrUnfollowUser(String uid, User userToFollow) async {
    final isFollowing = userToFollow.followers.contains(uid);

    if (isFollowing) {
      // Mutation per smettere di seguire
      String unfollowMutation = '''
        mutation UnfollowUser(\$followerId: ID!, \$followeeId: ID!) {
          unfollowUser(input: { followerId: \$followerId, followeeId: \$followeeId }) {
            followerId
          }
        }
      ''';
      final requestUnfollow = GraphQLRequest<String>(
        document: unfollowMutation,
        variables: {'followerId': uid, 'followeeId': userToFollow.uid},
      );
      await Amplify.API.mutate(request: requestUnfollow).response;
    } else {
      // Mutation per seguire
      String followMutation = '''
        mutation FollowUser(\$followerId: ID!, \$followeeId: ID!) {
          followUser(input: { followerId: \$followerId, followeeId: \$followeeId }) {
            followerId
          }
        }
      ''';
      final requestFollow = GraphQLRequest<String>(
        document: followMutation,
        variables: {'followerId': uid, 'followeeId': userToFollow.uid},
      );
      await Amplify.API.mutate(request: requestFollow).response;
    }
  }
}
