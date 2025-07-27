import 'dart:convert';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:whatfood/models/Ingredient.dart';

extension IngredientGraphQLFields on Ingredient {
  static String get graphQLFields => '''
    id
    name
    coverImage
    description
    healthScore
    nutriscoreGrade
    novaGroup
    nutritionPer100g
    similars
    tips
    shops
    recipes
    likes
    createdAt
    updatedAt
  ''';
}

Ingredient ingredientFromOpenFoodFacts(Map<String, dynamic> json) => Ingredient(
      id: json['code'] ?? '',
      name: (json['product_name_en'] ?? json['product_name'] ?? '').toString(),
      coverImage: (json['image_front_url'] ?? '').toString(),
      description:
          (json['ingredients_text_en'] ?? json['ingredients_text'] ?? '')
              .toString(),
      nutritionPer100g: jsonEncode(
        (json['nutriments'] as Map? ?? {})
            .map((k, v) => MapEntry(k, v is num ? v.toDouble() : v)),
      ),
      similars: const [],
      tips: const [],
      shops: const [],
      recipes: const [],
      likes: const [],
      createdAt: TemporalDateTime.now(),
      updatedAt: TemporalDateTime.now(),
    );
