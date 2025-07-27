import 'dart:convert';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:whatfood/models/Ingredient.dart';

class OpenFoodFactsParams {
  final String query;
  final List<String> categories;
  final List<String> allergensToAvoid;
  final List<String> ingredientsToAvoid;
  final List<String> nutritionGrades; // a,b,c,d,e
  final List<String> novaGroups; // 1,2,3,4
  final bool vegan;
  final bool vegetarian;
  final bool glutenFree;

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
  });

  bool get hasActiveFilters =>
      categories.isNotEmpty ||
      allergensToAvoid.isNotEmpty ||
      ingredientsToAvoid.isNotEmpty ||
      nutritionGrades.isNotEmpty ||
      novaGroups.isNotEmpty ||
      vegan ||
      vegetarian ||
      glutenFree;
}

final openFoodFactsProvider =
    FutureProvider.family<List<Ingredient>, OpenFoodFactsParams>(
        (ref, params) async {
  const _baseUrl =
      'https://world.openfoodfacts.org/cgi/search.pl'; // this version because of the search
  Uri _buildUri(OpenFoodFactsParams p) {
    final qParams = <String, String>{
      'search_simple': '1',
      'action': 'process',
      'json': '1',
      'page_size': '40',
      if (p.query.trim().isNotEmpty) 'search_terms': p.query.trim(),
    };

    if (p.categories.isNotEmpty) {
      qParams['categories_tags_en'] = p.categories.join(',');
    }

    final labels = <String>[];
    if (p.vegan) labels.add('en:vegan');
    if (p.vegetarian) labels.add('en:vegetarian');
    if (p.glutenFree) labels.add('en:gluten-free');
    if (labels.isNotEmpty) qParams['labels_tags_en'] = labels.join(',');

    if (p.nutritionGrades.isNotEmpty) {
      qParams['nutriscore_grade'] = p.nutritionGrades.join(',');
    }

    if (p.novaGroups.isNotEmpty) {
      qParams['nova_group'] = p.novaGroups.join(',');
    }

    if (p.allergensToAvoid.isNotEmpty) {
      qParams['allergens_tags'] =
          p.allergensToAvoid.map((a) => '-$a').join(',');
    }

    return Uri.parse(_baseUrl).replace(queryParameters: qParams);
  }

  final uri = _buildUri(params);

  print('Fetching OFF: $uri');
  final response = await http.get(uri).timeout(const Duration(seconds: 10));
  print(response.body);

  if (response.statusCode != 200) {
    throw Exception('OpenFoodFacts API error: HTTP ${response.statusCode}');
  }

  final data = jsonDecode(response.body) as Map<String, dynamic>;
  final products = data['products'] as List<dynamic>?;
  if (products == null) return [];

  return products
      .map((p) {
        final name =
            (p['product_name_en'] ?? p['product_name'] ?? '').toString();
        final imageUrl = p['image_front_small_url'] as String?;
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
});
