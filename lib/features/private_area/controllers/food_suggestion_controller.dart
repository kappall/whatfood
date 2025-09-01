import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:whatfood/models/food_suggestion.dart';

double? _parse(dynamic value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}

Future<List<FoodSuggestion>> fetchSuggestions(String query) async {
  if (query.trim().isEmpty) return [];

  final url = Uri.parse(
    'https://world.openfoodfacts.org/cgi/search.pl?search_terms=${Uri.encodeComponent(query)}&search_simple=1&action=process&json=1&page_size=4',
  );

  final res = await http.get(url);
  if (res.statusCode != 200) return [];

  final data = json.decode(res.body);
  final products = data['products'] as List<dynamic>?;

  if (products == null) return [];

  return products
      .map((item) {
        final name = item['product_name'] ?? 'Unnamed';
        final nutriments = item['nutriments'];

        if (nutriments == null) return null;

        double? kcal = _parse(nutriments['energy-kcal_100g']);
        double? protein = _parse(nutriments['proteins_100g']);
        double? carbs = _parse(nutriments['carbohydrates_100g']);
        double? fat = _parse(nutriments['fat_100g']);

        if (kcal == null || protein == null || carbs == null || fat == null) {
          return null;
        }

        return FoodSuggestion(
          name: name,
          kcalPer100g: kcal,
          proteinPer100g: protein,
          carbsPer100g: carbs,
          fatPer100g: fat,
        );
      })
      .whereType<FoodSuggestion>()
      .toList();
}

Future<FoodSuggestion?> fetchFromUSDA(String query) async {
  final res = await http.post(
    Uri.parse(
        'https://0xiiuk1qrh.execute-api.eu-north-1.amazonaws.com/usdaAPICall'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'query': query}),
  );

  if (res.statusCode != 200) return null;
  final json = jsonDecode(res.body);
  return FoodSuggestion(
    name: json['name'], //TODO is it for 100g? add other nutrients?
    kcalPer100g: (json['calories'] as num).toDouble(),
    proteinPer100g: (json['protein'] as num).toDouble(),
    carbsPer100g: (json['carbohydrates'] as num).toDouble(),
    fatPer100g: (json['fat'] as num).toDouble(),
  );
}

Future<Map<String, dynamic>?> normalizeFromAi(String query, String? jwt) async {
  try {
    debugPrint("normalizeFromAi called");
    final response = await http.post(
      Uri.parse(
          'https://lbpcnp99x3.execute-api.eu-north-1.amazonaws.com/foodAiApiCall'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $jwt",
      },
      body: jsonEncode({
        "action": "normalize",
        "query": query,
      }),
    );

    debugPrint("response:${response.body}");

    if (response.statusCode != 200) return null;

    final data = jsonDecode(response.body);
    return data;
  } catch (e) {
    debugPrint("AI fetch error: $e");
    return null;
  }
}

Future<FoodSuggestion?> fetchNutritionFromAi(String query, String? jwt) async {
  try {
    debugPrint("fetchFromAi called");
    final response = await http.post(
      Uri.parse(
          'https://lbpcnp99x3.execute-api.eu-north-1.amazonaws.com/foodAiApiCall'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $jwt",
      },
      body: jsonEncode({
        "action": "nutrition",
        "query": query,
      }),
    );

    debugPrint("response:${response.body}");

    if (response.statusCode != 200) return null;

    final data = jsonDecode(response.body);
    return FoodSuggestion(
      name: data['english_name'] ?? query,
      kcalPer100g: (data['calories'] as num?)?.toDouble() ?? 0,
      proteinPer100g: (data['protein_g'] as num?)?.toDouble() ?? 0,
      carbsPer100g: (data['carbs_g'] as num?)?.toDouble() ?? 0,
      fatPer100g: (data['fat_g'] as num?)?.toDouble() ?? 0,
    );
  } catch (e) {
    debugPrint("AI fetch error: $e");
    return null;
  }
}
