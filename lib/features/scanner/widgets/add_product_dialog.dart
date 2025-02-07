import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AddProductDialog extends StatefulWidget {
  const AddProductDialog({super.key});

  @override
  _AddProductDialogState createState() => _AddProductDialogState();
}

class _AddProductDialogState extends State<AddProductDialog> {
  final TextEditingController quantityController = TextEditingController();

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
        keyboardType: TextInputType.number,
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
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(null);
          },
          child: const Text(
            'Cancel',
            style: TextStyle(color: Colors.grey),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            final quantity = int.tryParse(quantityController.text.trim());
            if (quantity != null && quantity > 0) {
              Navigator.of(context).pop(quantity);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please enter a valid quantity')),
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
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
