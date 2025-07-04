import 'package:whatfood/models/Ingredient.dart';

extension IngredientGraphQLFields on Ingredient {
  static String get graphQLFields => '''
    id
    name
    coverImage
    description
    similars
    tips
    shops
    recipes
    createdAt
    likes
  ''';
}
