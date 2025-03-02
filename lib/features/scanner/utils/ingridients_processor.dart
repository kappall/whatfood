class IngredientsProcessor {
  static const Set<String> unhealthyIngredients = {
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
  };

  static String cleanIngredients(String text) {
    return text
        .replaceAll(RegExp(r'_'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAll(RegExp(r'\s*([,;])\s*'), r', ')
        .trim();
  }

  static bool hasIntolerance(String ingredient, Set<String> intolerances) {
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
      String rawIngredients, Set<String> userIntolerances) {
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
