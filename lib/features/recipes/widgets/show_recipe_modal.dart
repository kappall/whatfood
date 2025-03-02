import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';
import 'package:whatfood/button_styles.dart';
import 'package:whatfood/features/auth/controller/auth_controller.dart';
import 'package:whatfood/models/recipe_model.dart';

class RecipeModal extends ConsumerWidget {
  final Recipe recipe;

  const RecipeModal({super.key, required this.recipe});

  bool _hasIntolerance(String ingredient, Set<String> intolerances) {
    final lowerIngredient = ingredient.toLowerCase();
    return intolerances.any(
        (intolerance) => lowerIngredient.contains(intolerance.toLowerCase()));
  }

  Widget _buildIngredientsList(Set<String> intolerances, BuildContext context) {
    bool hasIntolerances = false;
    final chips = recipe.ingredients.map((ingredient) {
      final trimmedIngredient = ingredient.trim();
      final hasIntolerance = _hasIntolerance(trimmedIngredient, intolerances);
      if (hasIntolerance) hasIntolerances = true;

      return Container(
        decoration: BoxDecoration(
          color: hasIntolerance ? Colors.red : Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Theme.of(context).primaryColor),
        ),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        child: Text(
          trimmedIngredient,
          style: TextStyle(
            color: hasIntolerance ? Colors.white : Colors.black87,
            fontWeight: hasIntolerance ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      );
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hasIntolerances)
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.black),
            ),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                const Icon(Icons.warning_amber_rounded,
                    color: Colors.white, size: 32),
                const SizedBox(width: 8),
                Text(
                  'Warning: This product contains ingredients you may be intolerant to!',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: chips,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    final userIntolerances = user?.preferences ?? <String>{};

    bool hasIntolerances = recipe.ingredients
        .any((ingredient) => _hasIntolerance(ingredient, userIntolerances));

    return Material(
      color: const Color.fromARGB(255, 30, 30, 30),
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        side: hasIntolerances
            ? const BorderSide(color: Colors.red, width: 6)
            : BorderSide.none,
      ),
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (context, scrollController) {
          return ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: SingleChildScrollView(
              controller: scrollController,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      height: 5,
                      width: 50,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        recipe.coverImage,
                        width: double.infinity,
                        height: 300,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      recipe.title,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Ready in: ${recipe.cookTimeMinutes} minute',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Ingredients:',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        _buildIngredientsList(userIntolerances, context),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () => Routemaster.of(context).pop(),
                      style: ButtonStyles.elevatedButtonStyle(
                          backgroundColor: Colors.redAccent),
                      child: const Text(
                        'Close',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
