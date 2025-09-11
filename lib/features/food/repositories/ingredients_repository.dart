import 'dart:async';
import 'dart:convert';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:whatfood/core/failure.dart';
import 'package:whatfood/models/Ingredient.dart';
import 'package:whatfood/models/ingredient_extensions.dart';

final ingredientRepositoryProvider = Provider((ref) {
  return IngredientRepository();
});

class IngredientRepository {
  Stream<List<Ingredient>> fetchIngredients() {
    final controller = StreamController<List<Ingredient>>();
    var recipesQuery = '''
        query ListIngredients {
          listIngredients {
            items {
              ${IngredientGraphQLFields.graphQLFields}
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
                decoded['listIngredients']['items'] as List<dynamic>;
            final recipes =
                items.map((data) => Ingredient.fromJson(data)).toList();

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

  // Aggiorna i like di una ricetta tramite mutation GraphQL.
  //TODO: like and unlike
  Future<void> likeOrUnlike(Ingredient ingredient, String uid) async {
    final bool isLiked = ingredient.likes.contains(uid);
    if (isLiked) {
      final request = GraphQLRequest<String>(
        document: '''
          mutation UnlikeIngredient(\$input: UnlikeIngredientInput!) {
            unlikeIngredient(input: \$input) {
              ${IngredientGraphQLFields.graphQLFields}
            }
          }
        ''',
        variables: {
          'input': {'id': ingredient.id, 'uid': uid}
        },
      );
      await Amplify.API.mutate(request: request).response;
    } else {
      final request = GraphQLRequest<String>(
        document: '''
          mutation LikeIngredient(\$input: LikeIngredientInput!) { 
            likeIngredient(input: \$input) {
              ${IngredientGraphQLFields.graphQLFields}
            }
          }
        ''',
        variables: {
          'input': {'id': ingredient.id, 'uid': uid}
        },
      );
      await Amplify.API.mutate(request: request).response;
    }
  }

  Stream<Ingredient> getIngredientById(String id) {
    final controller = StreamController<Ingredient>();
    try {
      String query = '''
        query GetIngredient(\$id: ID!) {
          getIngredient(id: \$id) {
            ${IngredientGraphQLFields.graphQLFields}
          }
        }
      ''';
      final request = GraphQLRequest<String>(document: query);
      Amplify.API.query(request: request).response.then((response) {
        if (response.data == null) {
          return;
        }
        try {
          debugPrint(response.data);
          var json = jsonDecode(response.data!)['getIngredient'];
          final ingredient = Ingredient.fromJson(json);
          controller.add(ingredient);
        } catch (e) {
          debugPrint("Error parsing ingredient data: $e");
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

  Future<Either<Failure, void>> updateIngredient(Ingredient ingredient) async {
    try {
      Map<String, Object?> recipeMap = {
        "input": {
          "id": ingredient.id,
          "name": ingredient.name,
          "coverImage": ingredient.coverImage,
          "description": ingredient.description,
          "shops": ingredient.shops,
          "tips": ingredient.tips,
          "recipes": ingredient.recipes,
          "createdAt": ingredient.createdAt.toString(),
          "likes": ingredient.likes,
          "similars": ingredient.similars,
        }
      };
      String graphQLDocument = '''
          mutation UpdateIngredient(\$input: UpdateIngredientInput!) {
            updateIngredient(input: \$input) {
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
