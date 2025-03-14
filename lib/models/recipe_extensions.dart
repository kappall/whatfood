import 'package:whatfood/models/Recipe.dart';

extension RecipeGraphQLFields on Recipe {
  static String get graphQLFields => '''
    id
    title
    coverImage
    description
    ingredients
    instructions
    servings
    cookTimeMinutes
    createdAt
    likes
    uid
    userImage
    username
  ''';
}
