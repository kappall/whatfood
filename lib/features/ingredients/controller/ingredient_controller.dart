import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

class Ingredient {
  Ingredient(
      {required this.id,
      required this.name,
      required this.coverImage,
      required this.description});
  String id;
  String name;
  String coverImage;
  String description;
}

/// Parametri per la ricerca su OpenFoodFacts
class OpenFoodFactsParams {
  final String query;
  final List<String> filters;

  OpenFoodFactsParams({required this.query, this.filters = const []});
}

/// Provider che restituisce una lista di Ingredienti da OpenFoodFacts
final openFoodFactsProvider =
    FutureProvider.family<List<Ingredient>, OpenFoodFactsParams>(
        (ref, params) async {
  final baseUrl = 'https://world.openfoodfacts.org/cgi/search.pl';

  // Costruisci i parametri di query
  final uri = Uri.parse(baseUrl).replace(queryParameters: {
    'search_terms': params.query.isEmpty ? '' : params.query,
    'search_simple': '1',
    'action': 'process',
    'json': '1',
    'page_size': '40',
    // aggiunge filtri come tag
    ..._buildFilterParams(params.filters),
  });

  print('Fetching OFF: $uri');
  final response = await http.get(uri).timeout(const Duration(seconds: 10));
  print(response);

  if (response.statusCode != 200) {
    throw Exception('OpenFoodFacts API error: HTTP ${response.statusCode}');
  }

  final data = jsonDecode(response.body) as Map<String, dynamic>;
  final products = data['products'] as List<dynamic>?;
  if (products == null) return [];

  // Mappa i prodotti in Ingredient
  return products
      .map((p) {
        final name = (p['product_name'] ?? p['generic_name'] ?? '').toString();
        final imageUrl = p['image_front_small_url'] as String?;
        final description = p['ingredients_text'] as String?;
        return Ingredient(
          id: p['code'] as String,
          name: name,
          coverImage: imageUrl ?? '',
          description: description ?? '',
        );
      })
      .where((ing) => ing.name.isNotEmpty)
      .toList();
});

/// Costruisce parametri per i filtri (labels)
Map<String, String> _buildFilterParams(List<String> filters) {
  final params = <String, String>{};
  for (var i = 0; i < filters.length; i++) {
    params['tagtype_$i'] = 'labels';
    params['tag_contains_$i'] = 'contains';
    params['tag_$i'] = filters[i];
  }
  return params;
}
