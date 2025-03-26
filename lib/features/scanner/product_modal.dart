import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';
import 'package:whatfood/button_styles.dart';
import 'package:whatfood/features/auth/controller/auth_controller.dart';
import 'package:whatfood/features/scanner/widgets/add_product_dialog.dart';
import 'package:whatfood/features/scanner/widgets/nutriscore_widget.dart';
import 'package:whatfood/features/scanner/widgets/nutrition_table.dart';
import 'package:whatfood/features/scanner/utils/ingridients_processor.dart';

class ProductModal extends ConsumerStatefulWidget {
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

  @override
  ConsumerState<ProductModal> createState() => _ProductModalState();
}

class _ProductModalState extends ConsumerState<ProductModal> {
  bool? _hasIntolerances;

  @override
  void initState() {
    super.initState();
    _translateIngredients();
  }

  Future<void> _translateIngredients() async {
    if (widget.productData['ingredients_text'] != null) {
      final ingredients =
          await IngredientsProcessor.cleanAndTranslateIngredients(
              widget.productData['ingredients_text_en'] ??
                  widget.productData['ingredients_text']);

      if (mounted) {
        setState(() {
          _hasIntolerances = ingredients.split(RegExp(r',\s*(?![^()]*\))')).any(
              (ingredient) => IngredientsProcessor.hasIntolerance(
                  ingredient.trim(),
                  ref.read(userProvider)?.preferences ?? <String>[]));
        });
      }
    }
  }

  Widget _buildIngredientsList(BuildContext context) {
    if (widget.processedIngredients.isEmpty) {
      return const Text(
        'No ingredients available',
        style: TextStyle(fontSize: 16),
      );
    }

    final chips = widget.processedIngredients.map((ingredient) {
      final isIntolerable = widget.intolerableIngredients.contains(ingredient);
      final isUnhealthy = widget.unhealthyIngredients.contains(ingredient);

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
        if (widget.intolerableIngredients.isNotEmpty)
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
            widget.productData['product_name'] ?? 'Product Name not available',
        nutritionalValues: widget.productData['nutriments'],
        totalGrams: widget.quantity,
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
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).scaffoldBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        side: _hasIntolerances ?? false
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
                    if (widget.productData['image_url']?.isNotEmpty ?? false)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          widget.productData['image_url']!,
                          height: 150,
                          fit: BoxFit.cover,
                          errorBuilder: (BuildContext context, Object exception,
                              StackTrace? stackTrace) {
                            return Container(
                              color: Colors.grey[300],
                              child: const Icon(Icons.broken_image, size: 50),
                            );
                          },
                        ),
                      ),
                    if (widget.productData['nutriscore_grade'] != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: NutriScoreWidget(
                          grade: widget.productData['nutriscore_grade'],
                        ),
                      ),
                    const SizedBox(height: 16),
                    Text(
                      '${widget.productData['product_name'] ?? 'Product Name not available'} ${widget.productData['product_name'] != null && widget.productData['product_name']!.isNotEmpty ? '${widget.quantity}g' : ''}',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    if (widget.productData['brands']?.isNotEmpty ?? false)
                      Text(
                        'Brand: ${widget.productData['brands']}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white60,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    const SizedBox(height: 16),
                    if (widget.productData['ingredients_text'] != null)
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
                    NutritionTable(data: widget.productData["nutriments"]),
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
