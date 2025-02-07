import 'package:flutter/material.dart';
import 'package:routemaster/routemaster.dart';
import 'package:whatfood/button_styles.dart';
import 'package:whatfood/core/utils.dart';
import 'package:whatfood/features/scanner/widgets/add_product_dialog.dart';
import 'package:whatfood/features/scanner/widgets/nutriscore_widget.dart';
import 'package:whatfood/features/scanner/widgets/nutrition_table.dart';

String _cleanIngredients(String text) {
  return text
      .replaceAll(RegExp(r'_'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .replaceAll(RegExp(r'\s*([,;])\s*'), r', ')
      .trim();
}

const unhealthyIngredients = {
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

bool _isUnhealthy(String ingredient) {
  final lowerIngredient = ingredient.toLowerCase();
  return unhealthyIngredients.any((bad) => lowerIngredient.contains(bad)) ||
      RegExp(r'\bE\d{3}\b').hasMatch(lowerIngredient);
}

Widget _buildIngredientsList(String? cleanText) {
  if (cleanText == null || cleanText.isEmpty) {
    return const Text(
      'No ingredients available',
      style: TextStyle(fontSize: 16),
    );
  }

  final ingredients = cleanText
      .split(RegExp(r',\s*(?![^()]*\))'))
      .where((ingredient) => ingredient.trim().isNotEmpty)
      .toList();

  return Wrap(
    spacing: 8.0,
    runSpacing: 8.0,
    children: ingredients.map((ingredient) {
      final trimmedIngredient = ingredient.trim();
      final isUnhealthy = _isUnhealthy(trimmedIngredient);
      return Chip(
        label: Text(
          trimmedIngredient,
          style: TextStyle(
            color: isUnhealthy ? Colors.white : Colors.black87,
            fontWeight: isUnhealthy ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        backgroundColor: isUnhealthy ? Colors.redAccent : Colors.grey[100],
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        elevation: 2,
      );
    }).toList(),
  );
}

class ProductModal extends StatelessWidget {
  final Map<String, dynamic> productData;

  const ProductModal({super.key, required this.productData});

  Future<int?> showAddProductDialog(BuildContext context) {
    return showDialog<int>(
      context: context,
      builder: (context) => const AddProductDialog(),
    );
  }

  Future<void> _handleAddProduct(BuildContext context) async {
    final int? quantity = await showAddProductDialog(context);
    if (quantity != null) {
      debugPrint("Adding product with quantity: $quantity");
      if (!context.mounted) return;
      showSnackBar(context, 'Product added with quantity: $quantity');
      Routemaster.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (context, scrollController) => SingleChildScrollView(
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
                if (productData['image_url']?.isNotEmpty ?? false)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      productData['image_url']!,
                      height: 150,
                      fit: BoxFit.cover,
                    ),
                  ),
                if (productData['nutriscore_grade'] != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: NutriScoreWidget(
                      grade: productData['nutriscore_grade'],
                    ),
                  ),
                const SizedBox(height: 16),
                Text(
                  productData['product_name'] ?? 'Product Name not available',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                if (productData['brands']?.isNotEmpty ?? false)
                  Text(
                    'Brand: ${productData['brands']}',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                    textAlign: TextAlign.center,
                  ),
                const SizedBox(height: 16),
                if (productData['ingredients_text'] != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Ingredients:',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      _buildIngredientsList(_cleanIngredients(
                          productData['ingredients_text_en'] ??
                              productData['ingredients_text'])),
                    ],
                  ),
                const SizedBox(height: 16),
                NutritionTable(data: productData["nutriments"]),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    await _handleAddProduct(context);
                  },
                  style: ButtonStyles.elevatedButtonStyle(
                      backgroundColor: Colors.green),
                  child: const Text(
                    'Add to report',
                    style: TextStyle(fontSize: 16),
                  ),
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
      ),
    );
  }
}
