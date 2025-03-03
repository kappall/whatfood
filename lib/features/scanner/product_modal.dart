import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';
import 'package:whatfood/button_styles.dart';
import 'package:whatfood/features/auth/controller/auth_controller.dart';
import 'package:whatfood/features/scanner/widgets/add_product_dialog.dart';
import 'package:whatfood/features/scanner/widgets/nutriscore_widget.dart';
import 'package:whatfood/features/scanner/widgets/nutrition_table.dart';
import 'package:whatfood/features/scanner/utils/ingridients_processor.dart';

class ProductModal extends ConsumerWidget {
  final Map<String, dynamic> productData;
  final int quantity;
  final List<String> processedIngredients;
  final List<String> intolerableIngredients;
  final List<String> unhealthyIngredients;

  const ProductModal({
    super.key,
    required this.productData,
    required this.quantity,
    required this.processedIngredients,
    required this.intolerableIngredients,
    required this.unhealthyIngredients,
  });

  Widget _buildIngredientsList(BuildContext context) {
    if (processedIngredients.isEmpty) {
      return const Text(
        'No ingredients available',
        style: TextStyle(fontSize: 16),
      );
    }

    final chips = processedIngredients.map((ingredient) {
      final isIntolerable = intolerableIngredients.contains(ingredient);
      final isUnhealthy = unhealthyIngredients.contains(ingredient);

      return Container(
        decoration: BoxDecoration(
          color: isIntolerable
              ? Colors.red
              : (isUnhealthy ? Colors.redAccent : Colors.grey[100]),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Theme.of(context).primaryColor),
        ),
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        child: Text(
          ingredient,
          style: TextStyle(
            color: isIntolerable || isUnhealthy ? Colors.white : Colors.black87,
            fontWeight: isIntolerable || isUnhealthy
                ? FontWeight.bold
                : FontWeight.normal,
          ),
        ),
      );
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (intolerableIngredients.isNotEmpty)
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
                    color: Colors.black, size: 32),
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

  Future<double?> showAddProductDialog(BuildContext context) {
    return showDialog<double>(
      context: context,
      builder: (context) => AddProductDialog(
        productName:
            productData['product_name'] ?? 'Product Name not available',
        nutritionalValues: productData['nutriments'],
        totalGrams: quantity,
      ),
    );
  }

  Future<void> _handleAddProduct(BuildContext context) async {
    final double? quantity = await showAddProductDialog(context);
    if (quantity != null) {
      if (!context.mounted) return;
      Routemaster.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    final userIntolerances = user?.preferences ?? <String>{};

    // Check if product contains any intolerant ingredients
    bool hasIntolerances = false;
    if (productData['ingredients_text'] != null) {
      final ingredients = IngredientsProcessor.cleanIngredients(
              productData['ingredients_text_en'] ??
                  productData['ingredients_text'])
          .split(RegExp(r',\s*(?![^()]*\))'));

      hasIntolerances = ingredients.any((ingredient) =>
          IngredientsProcessor.hasIntolerance(ingredient, userIntolerances));
    }

    return Material(
      color: Theme.of(context).scaffoldBackgroundColor,
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
                      '${productData['product_name'] ?? 'Product Name not available'} ${productData['product_name'] != null && productData['product_name']!.isNotEmpty ? '${quantity}g' : ''}',
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
                          color: Colors.white60,
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
                          _buildIngredientsList(context),
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
          );
        },
      ),
    );
  }
}
