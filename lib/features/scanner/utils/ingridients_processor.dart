import 'package:whatfood/core/services/translation_service.dart';

class IngredientsProcessor {
  static const List<String> unhealthyIngredients = [
    'hydrogenated fats',
    'glucose syrup',
    'aspartame',
    'monosodium glutamate',
    'artificial coloring',
    'palm oil',
    'sucrose',
    'preservative',
    'E621',
    'high fructose corn syrup'
  ];

  static String cleanIngredients(String ingredients) {
    String cleaned = ingredients.toLowerCase();

    // Remove standalone measurements and energy values
    cleaned = cleaned.replaceAll(RegExp(r'\b\d+\.?\d*\s*(kcal|kj|g)\b'), '');

    // Remove percentage values
    cleaned = cleaned.replaceAll(RegExp(r'\d+\.?\d*\s*%'), '');

    // Remove any remaining standalone numbers
    cleaned = cleaned.replaceAll(RegExp(r'\b\d+\.?\d*\b'), '');

    // Clean up extra spaces and commas
    cleaned = cleaned.replaceAll(RegExp(r'\s+'), ' ');
    cleaned = cleaned.replaceAll(RegExp(r',\s*,'), ',');

    // Remove empty parentheses and their contents if they only contain measurements
    cleaned = cleaned.replaceAll(RegExp(r'\([^()]*?(kcal|kj|g)[^()]*?\)'), '');

    // Remove leading/trailing commas and spaces
    cleaned = cleaned.trim().replaceAll(RegExp(r'^,+|,+$'), '');

    // Remove empty items between commas
    cleaned = cleaned
        .split(',')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .join(', ');

    return cleaned;
  }

  static Future<String> cleanAndTranslateIngredients(String ingredients) async {
    // First, clean the ingredients
    String cleaned = cleanIngredients(ingredients);

    // Split ingredients while preserving parentheses content
    List<String> individualIngredients =
        cleaned.split(RegExp(r',\s*(?![^()]*\))'));

    // Translate each ingredient
    List<String> translatedIngredients =
        await Future.wait(individualIngredients.map((ingredient) async {
      // Skip translation if ingredient appears to be English
      if (_isEnglishText(ingredient)) {
        return ingredient;
      }
      return await TranslationService.translateToEnglish(ingredient);
    }));

    // Join back translated ingredients
    return translatedIngredients.join(', ');
  }

  static bool _isEnglishText(String text) {
    // Basic check for English text using common English characters and patterns
    final englishPattern = RegExp(r'^[a-zA-Z0-9\s\-(),.*%]+$');
    return englishPattern.hasMatch(text);
  }

  static bool hasIntolerance(String ingredient, List<String> intolerances) {
    final lowerIngredient = ingredient.toLowerCase();
    return intolerances.any(
        (intolerance) => lowerIngredient.contains(intolerance.toLowerCase()));
  }

  static bool isUnhealthy(String ingredient) {
    final lowerIngredient = ingredient.toLowerCase();
    return unhealthyIngredients.any((bad) => lowerIngredient.contains(bad)) ||
        RegExp(r'\bE\d{3}\b').hasMatch(lowerIngredient);
  }

  static (List<String>, List<String>, List<String>) processIngredients(
      String rawIngredients, List<String> userIntolerances) {
    final cleanText = cleanIngredients(rawIngredients);
    final ingredients = cleanText
        .split(RegExp(r',\s*(?![^()]*\))'))
        .where((ingredient) =>
            ingredient.trim().isNotEmpty && !ingredient.trim().contains("%"))
        .map((e) => e.trim())
        .toList();

    final intolerableIngredients = ingredients
        .where((ingredient) => hasIntolerance(ingredient, userIntolerances))
        .toList();
    final unhealthyItems =
        ingredients.where((ingredient) => isUnhealthy(ingredient)).toList();

    return (ingredients, intolerableIngredients, unhealthyItems);
  }
}
