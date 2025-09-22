import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

class ApiController extends StateNotifier<bool> {
  ApiController(super.state);

  Future<Map<String, dynamic>?> recognizeFood(String base64Image) async {
    final food = await http.post(
      Uri.parse(
          "https://yan1o1mgc5.execute-api.eu-north-1.amazonaws.com/dev/recognizeFoodFromBase64"),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'query': base64Image}),
    );

    debugPrint(food.body);

    return jsonDecode(food.body) as Map<String, dynamic>;
  }
}
