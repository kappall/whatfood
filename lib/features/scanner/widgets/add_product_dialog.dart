import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatfood/features/report/controller/report_controller.dart';
import 'package:whatfood/features/scanner/widgets/nutrition_table.dart';

class AddProductDialog extends ConsumerStatefulWidget {
  final String productName;
  final Map<String, dynamic> nutritionalValues;
  final int totalGrams;

  const AddProductDialog({
    super.key,
    required this.productName,
    required this.nutritionalValues,
    required this.totalGrams,
  });

  @override
  ConsumerState<AddProductDialog> createState() => _AddProductDialogState();
}

class _AddProductDialogState extends ConsumerState<AddProductDialog> {
  final TextEditingController quantityController = TextEditingController();

  void addProduct(BuildContext context) {
    final quantity = double.tryParse(quantityController.text.trim()) ?? 0;
    if (quantity <= 0) return;

    final totalGramsDouble = widget.totalGrams.toDouble();
    final ratio = quantity / totalGramsDouble;

    final filteredNutritionalValues = Map<String, dynamic>.fromEntries(
      NutritionTable.essentialKeys
          .where((key) => widget.nutritionalValues.containsKey(key))
          .map((key) {
        final value = widget.nutritionalValues[key];
        return MapEntry(key, (value * ratio).roundToDouble());
      }),
    );

    final now = DateTime.now();
    final date = DateTime(now.year, now.month, now.day);

    ref.read(reportControllerProvider.notifier).addFoodReport(
          context: context,
          nutritionalValues: jsonEncode(filteredNutritionalValues),
          description: '${widget.productName} ${quantity}g',
          category: 'Scanned Product',
        );
  }

  @override
  void dispose() {
    quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Add Product',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: TextField(
        keyboardType:
            TextInputType.numberWithOptions(decimal: true, signed: false),
        controller: quantityController,
        decoration: InputDecoration(
          filled: true,
          hintText: 'Quantity',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          suffixText: 'g',
          suffixStyle:
              const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          contentPadding: const EdgeInsets.all(20),
        ),
        inputFormatters: [FilteringTextInputFormatter.singleLineFormatter],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(
            'Cancel',
            style: TextStyle(color: Colors.grey),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            addProduct(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: const Text(
            'Add',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}
