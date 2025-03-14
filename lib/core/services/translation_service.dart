import 'dart:convert';
import 'package:http/http.dart' as http;

class TranslationService {
  static const String _baseUrl =
      'https://translation.googleapis.com/language/translate/v2';
  static const String _apiKey = 'YOUR_API_KEY'; // Move to environment variables

  static Future<String> translateToEnglish(String text) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl?key=$_apiKey'),
        body: {
          'q': text,
          'target': 'en',
          'format': 'text',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data']['translations'][0]['translatedText'];
      }
      throw Exception('Translation failed');
    } catch (e) {
      print('Translation error: $e');
      return text; // Return original text if translation fails
    }
  }
}
