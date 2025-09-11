import 'dart:async';
import 'dart:convert';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:whatfood/core/failure.dart';
import 'package:whatfood/models/Recipe.dart';
import 'package:whatfood/models/recipe_extensions.dart';

final recipeRepositoryProvider = Provider((ref) {
  return RecipeRepository();
});

class RecipeRepository {
  Future<Either<Failure, void>> addRecipe(Recipe recipe) async {
    try {
      Map<String, Object?> recipeMap = {
        "input": {
          "id": recipe.id,
          "title": recipe.title,
          "coverImage": recipe.coverImage,
          "description": recipe.description,
          "ingredients": recipe.ingredients,
          "instructions": recipe.instructions,
          "servings": recipe.servings,
          "cookTimeMinutes": recipe.cookTimeMinutes,
          "createdAt": recipe.createdAt.toString(),
          "likes": recipe.likes,
          "uid": recipe.uid,
          "userImage": recipe.userImage,
          "username": recipe.username,
        }
      };

      String graphQLDocument = '''
          mutation CreateRecipe(\$input: CreateRecipeInput!) {
            createRecipe(input: \$input) {
              id
            }
          }
        ''';
      var operation = Amplify.API.mutate(
        request: GraphQLRequest<String>(
          document: graphQLDocument,
          variables: recipeMap,
        ),
      );

      final response = await operation.response;

      if (response.errors.isNotEmpty) {
        throw Exception(response.errors.first.message);
      }
      return right(null);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Stream<List<Recipe>> fetchRecipes() {
    final controller = StreamController<List<Recipe>>();
    var recipesQuery = '''
        query ListRecipes {
          listRecipes {
            items {
              ${RecipeGraphQLFields.graphQLFields}
            }
          }
        }
      ''';

    final request = GraphQLRequest<String>(document: recipesQuery);
    Amplify.API
        .query(request: request)
        .response
        .then((response) {
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
            final Map<String, dynamic> decoded =
                jsonDecode(response.data!) as Map<String, dynamic>;
            final List<dynamic> items =
                decoded['listRecipes']['items'] as List<dynamic>;
            final recipes = items.map((data) => Recipe.fromJson(data)).toList();

            recipes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
            controller.add(recipes);
          } catch (e, stackTrace) {
            debugPrint("Parse error: $e");
            debugPrint("Stack trace: $stackTrace");
            controller.addError('Error parsing posts: $e');
          }
        })
        .whenComplete(() => controller.close())
        .catchError((error) {
          controller.addError(error);
        });
    return controller.stream;
  }

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

  Stream<Recipe> getRecipeById(String id) {
    final controller = StreamController<Recipe>();
    try {
      String query = '''
        query GetRecipe(\$id: ID!) {
          getRecipe(id: \$id) {
            ${RecipeGraphQLFields.graphQLFields}
          }
        }
      ''';
      final request =
          GraphQLRequest<String>(document: query, variables: {'id': id});
      Amplify.API.query(request: request).response.then((response) {
        if (response.data == null) {
          return;
        }
        try {
          var json = jsonDecode(response.data!)['getRecipe'];
          final recipe = Recipe.fromJson(json);
          controller.add(recipe);
        } catch (e) {
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

  Future<Either<Failure, void>> updateRecipe(Recipe recipe) async {
    try {
      Map<String, Object?> recipeMap = {
        "input": {
          "id": recipe.id,
          "title": recipe.title,
          "coverImage": recipe.coverImage,
          "description": recipe.description,
          "ingredients": recipe.ingredients,
          "instructions": recipe.instructions,
          "servings": recipe.servings,
          "cookTimeMinutes": recipe.cookTimeMinutes,
          "createdAt": recipe.createdAt.toString(),
          "likes": recipe.likes,
          "uid": recipe.uid,
          "userImage": recipe.userImage,
          "username": recipe.username,
        }
      };
      String graphQLDocument = '''
          mutation UpdateRecipe(\$input: UpdateRecipeInput!) {
            updateRecipe(input: \$input) {
              id
            }
          }
        ''';
      var operation = Amplify.API.mutate(
        request: GraphQLRequest<String>(
          document: graphQLDocument,
          variables: recipeMap,
        ),
      );

      final response = await operation.response;

      if (response.errors.isNotEmpty) {
        throw Exception(response.errors.first.message);
      }
      return right(null);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }
}
