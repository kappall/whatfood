import 'dart:convert';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:whatfood/models/Ingredient.dart';

enum OpenFoodFactsSort { popularity, uniqueScansN }

class OpenFoodFactsParams {
  final String query;
  final List<String> categories;
  final List<String> allergensToAvoid;
  final List<String> ingredientsToAvoid;
  final List<String> nutritionGrades;
  final List<String> novaGroups;
  final bool vegan;
  final bool vegetarian;
  final bool glutenFree;
  final OpenFoodFactsSort? sortBy;
  final int? limit;

  const OpenFoodFactsParams({
    this.query = '',
    this.categories = const [],
    this.allergensToAvoid = const [],
    this.ingredientsToAvoid = const [],
    this.nutritionGrades = const [],
    this.novaGroups = const [],
    this.vegan = false,
    this.vegetarian = false,
    this.glutenFree = false,
    this.sortBy,
    this.limit,
  });

  OpenFoodFactsParams copyWith({
    String? query,
    List<String>? categories,
    List<String>? allergensToAvoid,
    List<String>? ingredientsToAvoid,
    List<String>? nutritionGrades,
    List<String>? novaGroups,
    bool? vegan,
    bool? vegetarian,
    bool? glutenFree,
    OpenFoodFactsSort? sortBy,
    int? limit,
  }) {
    return OpenFoodFactsParams(
      query: query ?? this.query,
      categories: categories ?? List.from(this.categories),
      allergensToAvoid: allergensToAvoid ?? List.from(this.allergensToAvoid),
      ingredientsToAvoid:
          ingredientsToAvoid ?? List.from(this.ingredientsToAvoid),
      nutritionGrades: nutritionGrades ?? List.from(this.nutritionGrades),
      novaGroups: novaGroups ?? List.from(this.novaGroups),
      vegan: vegan ?? this.vegan,
      vegetarian: vegetarian ?? this.vegetarian,
      glutenFree: glutenFree ?? this.glutenFree,
      sortBy: sortBy ?? this.sortBy,
      limit: limit ?? this.limit,
    );
  }

  bool get hasActiveFilters =>
      categories.isNotEmpty ||
      allergensToAvoid.isNotEmpty ||
      ingredientsToAvoid.isNotEmpty ||
      nutritionGrades.isNotEmpty ||
      novaGroups.isNotEmpty ||
      vegan ||
      vegetarian ||
      glutenFree;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OpenFoodFactsParams &&
          query == other.query &&
          vegan == other.vegan &&
          vegetarian == other.vegetarian &&
          glutenFree == other.glutenFree &&
          sortBy == other.sortBy &&
          _listEquals(categories, other.categories) &&
          _listEquals(nutritionGrades, other.nutritionGrades) &&
          _listEquals(novaGroups, other.novaGroups) &&
          _listEquals(allergensToAvoid, other.allergensToAvoid);

  @override
  int get hashCode => Object.hash(
        query,
        vegan,
        vegetarian,
        glutenFree,
        sortBy,
        Object.hashAll(categories),
        Object.hashAll(nutritionGrades),
        Object.hashAll(novaGroups),
        Object.hashAll(allergensToAvoid),
      );

  static bool _listEquals(List a, List b) =>
      a.length == b.length && a.every((e) => b.contains(e));
}

final openFoodFactsParamsProvider = StateProvider<OpenFoodFactsParams>(
  (ref) => const OpenFoodFactsParams(),
);

final openFoodFactsProvider =
    StreamProvider.family<List<Ingredient>, OpenFoodFactsParams>(
        (ref, params) async* {
  debugPrint("called");
  const _baseUrl = 'https://world.openfoodfacts.org/api/v2/search';

  Uri _buildUri(OpenFoodFactsParams p) {
    debugPrint("quey: ${p.query}");
    final qParams = <String, String>{
      'json': '1',
      if (p.query.trim().isNotEmpty) 'search_terms': p.query.trim(),
      if (p.categories.isNotEmpty) 'categories_tags_en': p.categories.join(','),
      if (p.vegan || p.vegetarian || p.glutenFree)
        'labels_tags_en': [
          if (p.vegan) 'vegan',
          if (p.vegetarian) 'vegetarian',
          if (p.glutenFree) 'gluten-free',
        ].map((l) => 'en:$l').join(','),
      if (p.nutritionGrades.isNotEmpty)
        'nutriscore_grade': p.nutritionGrades.join(','),
      if (p.novaGroups.isNotEmpty) 'nova_group': p.novaGroups.join(','),
      if (p.allergensToAvoid.isNotEmpty)
        'allergens_tags': p.allergensToAvoid.map((a) => '-$a').join(','),
      if (p.sortBy != null)
        'sort_by': switch (p.sortBy!) {
          OpenFoodFactsSort.popularity => 'popularity',
          OpenFoodFactsSort.uniqueScansN => 'unique_scans_n',
        },
      'fields': 'code,product_name,brands,ingredients_text,image_url'
    };
    return Uri.parse(_baseUrl).replace(queryParameters: qParams);
  }

  final uri = _buildUri(params);
  print(uri.toString());

  // emit loading empty list first if desired
  yield [];

  final response = await http.get(uri).timeout(const Duration(seconds: 10));

  if (response.statusCode != 200) {
    throw Exception('OpenFoodFacts API error: HTTP ${response.statusCode}');
  }

  final data = jsonDecode(response.body) as Map<String, dynamic>;
  final products = data['products'] as List<dynamic>?;
  if (products == null) {
    yield [];
    return;
  }

  final blacklist = ['water', 'oil'];

  final res = products
      .where((p) => !blacklist.any((word) {
            final keywords = List<String>.from(p['_keywords'] ?? []);
            return keywords.contains(word);
          }))
      .map((p) {
        final name =
            (p['product_name_en'] ?? p['product_name'] ?? '').toString();
        final imageUrl = p['image_url'] as String?;
        final description = p['ingredients_text'] as String?;
        return Ingredient(
          id: p['code'] as String,
          name: name,
          coverImage: imageUrl ?? '',
          description: description ?? '',
          similars: [],
          tips: [],
          shops: [],
          recipes: [],
          likes: [],
          createdAt: TemporalDateTime.now(),
          updatedAt: TemporalDateTime.now(),
        );
      })
      .where((ing) => ing.name.isNotEmpty)
      .toList();

  // emit the final result
  yield res;
});
