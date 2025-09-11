import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:whatfood/features/auth/controller/auth_controller.dart';

class FoodAlternative {
  final String name;
  final double kcal_per_100g;
  final double protein_per_100g;
  final double fat_per_100g;
  final double carbs_per_100g;
  final String category;

  FoodAlternative(
      {required this.name,
      required this.kcal_per_100g,
      required this.protein_per_100g,
      required this.fat_per_100g,
      required this.carbs_per_100g,
      required this.category});
}

Future<List<FoodAlternative>> getFoodAlternative(
    String query, String? jwt, WidgetRef ref) async {
  try {
    debugPrint("alternativeFood called");
    final currentUSer = ref.read(userProvider)!;
    final response = await http.post(
      Uri.parse(
          'https://ksuq3bvuwl.execute-api.eu-north-1.amazonaws.com//foodAlternative'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $jwt",
      },
      body: jsonEncode({
        "dish_name": query,
        "allergies": currentUSer.allergies,
        "dislikes": currentUSer.dislikes,
        "preferences": currentUSer.preferences
      }),
    );

    debugPrint("response: ${response.body}");

    if (response.statusCode != 200) return [];

    final data = jsonDecode(response.body);
    final List<FoodAlternative> ret = [];
    for (var item in data['alternatives']) {
      ret.add(FoodAlternative(
        name: item['name'],
        kcal_per_100g: (item['kcal_per_100g']?.toDouble() ?? 0.0),
        fat_per_100g: (item['fat_per_100g']?.toDouble() ?? 0.0),
        protein_per_100g: (item['protein_per_100g']?.toDouble() ?? 0.0),
        carbs_per_100g: (item['carbs_per_100g']?.toDouble() ?? 0.0),
        category: item['category'] ?? '',
      ));
    }
    return ret;
  } catch (e) {
    debugPrint("AI fetch error: $e");
    return [];
  }
}
