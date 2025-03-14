import 'dart:convert';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:whatfood/core/failure.dart';
import 'package:whatfood/models/Recipe.dart';
import 'package:whatfood/models/recipe_extensions.dart';

final recipeRepositoryProvider = Provider((ref) {
  return RecipeRepository();
});

class RecipeRepository {
  // Aggiunge una ricetta tramite una mutation GraphQL
  Future<Either<Failure, void>> addRecipe(Recipe recipe) async {
    try {
      final request = GraphQLRequest<String>(
        document: '''
          mutation CreateRecipe(\$input: CreateRecipeInput!) {
            createRecipe(input: \$input) {
              ${RecipeGraphQLFields.graphQLFields}
            }
          }
        ''',
        variables: {'input': recipe.toJson()},
      );
      await Amplify.API.mutate(request: request).response;
      return right(null);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  // Recupera le ricette tramite una query GraphQL
  Future<List<Recipe>> fetchRecipes() async {
    final request = GraphQLRequest<String>(
      document: '''
        query ListRecipes {
          listRecipes(sortDirection: DESC, sortField: createdAt) {
            items {
              ${RecipeGraphQLFields.graphQLFields}
            }
          }
        }
      ''',
    );
    final response = await Amplify.API.query(request: request).response;
    if (response.data == null) return [];
    final Map<String, dynamic> decoded =
        jsonDecode(response.data!) as Map<String, dynamic>;
    final List<dynamic> items =
        decoded['data']['listRecipes']['items'] as List<dynamic>;
    return items
        .map((item) => Recipe.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  // Elimina una ricetta tramite mutation GraphQL
  Future<Either<Failure, void>> deleteRecipe(String id) async {
    try {
      final request = GraphQLRequest<String>(
        document: '''
          mutation DeleteRecipe(\$input: DeleteRecipeInput!) {
            deleteRecipe(input: \$input) {
              ${RecipeGraphQLFields.graphQLFields}
            }
          }
        ''',
        variables: {
          'input': {'id': id}
        },
      );
      await Amplify.API.mutate(request: request).response;
      return right(null);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  // Aggiorna i like di una ricetta tramite mutation GraphQL.
  Future<void> likeOrUnlike(Recipe recipe, String uid) async {
    final bool isLiked = recipe.likes.contains(uid);
    if (isLiked) {
      final request = GraphQLRequest<String>(
        document: '''
          mutation UnlikeRecipe(\$input: UnlikeRecipeInput!) {
            unlikeRecipe(input: \$input) {
              ${RecipeGraphQLFields.graphQLFields}
            }
          }
        ''',
        variables: {
          'input': {'id': recipe.id, 'uid': uid}
        },
      );
      await Amplify.API.mutate(request: request).response;
    } else {
      final request = GraphQLRequest<String>(
        document: '''
          mutation LikeRecipe(\$input: LikeRecipeInput!) {
            likeRecipe(input: \$input) {
              ${RecipeGraphQLFields.graphQLFields}
            }
          }
        ''',
        variables: {
          'input': {'id': recipe.id, 'uid': uid}
        },
      );
      await Amplify.API.mutate(request: request).response;
    }
  }

  // Recupera una ricetta per id tramite una query GraphQL
  Future<Recipe> getRecipeById(String id) async {
    final request = GraphQLRequest<String>(
      document: '''
        query GetRecipe(\$id: ID!) {
          getRecipe(id: \$id) {
            ${RecipeGraphQLFields.graphQLFields}
          }
        }
      ''',
      variables: {'id': id},
    );
    final response = await Amplify.API.query(request: request).response;
    final Map<String, dynamic> decoded =
        jsonDecode(response.data!) as Map<String, dynamic>;
    final recipeData = decoded['data']['getRecipe'];
    return Recipe.fromJson(recipeData);
  }

  // Aggiorna una ricetta tramite mutation GraphQL
  Future<Either<Failure, void>> updateRecipe(Recipe recipe) async {
    try {
      final request = GraphQLRequest<String>(
        document: '''
          mutation UpdateRecipe(\$input: UpdateRecipeInput!) {
            updateRecipe(input: \$input) {
              ${RecipeGraphQLFields.graphQLFields}
            }
          }
        ''',
        variables: {'input': recipe.toJson()},
      );
      await Amplify.API.mutate(request: request).response;
      return right(null);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }
}
