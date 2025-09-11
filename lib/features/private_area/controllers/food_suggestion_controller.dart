import 'dart:convert';
import 'dart:ffi';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:whatfood/models/diary_entry.dart';
import 'package:whatfood/models/food_suggestion.dart';

double? _parse(dynamic value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}

Future<List<DiaryEntry>> fetchSuggestions(String query) async {
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

        return DiaryEntry(
          meal: name,
          timestamp: DateTime.now(),
          quantity: '100g',
          calories: kcal.toInt(),
          protein: protein,
          carbs: carbs,
          fat: fat,
          key: 0,
        );
      })
      .whereType<DiaryEntry>()
      .toList();
}

Future<DiaryEntry?> fetchFromUSDA(String query) async {
  final res = await http.post(
    Uri.parse(
        'https://0xiiuk1qrh.execute-api.eu-north-1.amazonaws.com/usdaAPICall'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'query': query}),
  );

  if (res.statusCode != 200) return null;
  final json = jsonDecode(res.body);

  return DiaryEntry(
    meal: json['name'] ?? query,
    timestamp: DateTime.now(),
    quantity: '100g',
    calories: (json['calories'] as num).toInt(),
    protein: (json['protein'] as num).toDouble(),
    carbs: (json['carbohydrates'] as num).toDouble(),
    fat: (json['fat'] as num).toDouble(),
    key: 0,
  );
}

Future<List<FoodSuggestion>> normalizeFromAi(String query, String? jwt) async {
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

    debugPrint("response from normalization: ${response.body}");

    if (response.statusCode != 200) return [];

    final data = jsonDecode(response.body);
    final List<FoodSuggestion> ret = [];
    for (var item in data['interpretations']) {
      ret.add(new FoodSuggestion(
          name: item['name'],
          kcalPer100g: (item['kcal_per_100g'] as int).toDouble()));
    }
    return ret;
  } catch (e) {
    debugPrint("AI fetch error: $e");
    return [];
  }
}

Future<DiaryEntry?> fetchNutritionFromAi(String query, String? jwt) async {
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
    return DiaryEntry(
      meal: data['english_name'] ?? query,
      timestamp: DateTime.now(),
      quantity: '100g',
      calories: (data['calories'] as num?)?.toInt() ?? 0,
      protein: (data['protein_g'] as num?)?.toDouble() ?? 0,
      carbs: (data['carbs_g'] as num?)?.toDouble() ?? 0,
      fat: (data['fat_g'] as num?)?.toDouble() ?? 0,
      key: 0,
    );
  } catch (e) {
    debugPrint("AI fetch error: $e");
    return null;
  }
}
