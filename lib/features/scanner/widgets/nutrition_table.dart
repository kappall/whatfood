import 'package:flutter/material.dart';

class NutritionTable extends StatelessWidget {
  final Map<String, dynamic>? data;
  const NutritionTable({super.key, required this.data});

  static const List<String> essentialKeys = [
    "energy-kcal",
    "carbohydrates",
    "sugars",
    "proteins",
    "fat",
    "saturated-fat",
    "fiber",
    "salt",
  ];

  @override
  Widget build(BuildContext context) {
    final nutrients = _generateNutrientItems();
    return Column(children: [
      Text(
        "Nutritional values",
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
      ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: nutrients.length,
        itemBuilder: (context, index) {
          final nutrient = nutrients[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _getNutrientColor(nutrient.key).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getNutrientIcon(nutrient.key),
                  color: _getNutrientColor(nutrient.key),
                ),
              ),
              title: Text(
                nutrient.label,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                ),
              ),
              trailing: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  "${nutrient.value} ${nutrient.unit}",
                  style: TextStyle(
                    color: _getNutrientColor(nutrient.key),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    ]);
  }

  List<NutrientItem> _generateNutrientItems() {
    return essentialKeys
        .where((key) => data?.containsKey(key) ?? false)
        .map((key) => NutrientItem(
              key: key,
              label: _formatKey(key),
              value: data![key].toString(),
              unit: _getUnit(key),
            ))
        .toList();
  }

  Color _getNutrientColor(String key) {
    switch (key) {
      case "energy-kcal":
        return Colors.orange;
      case "carbohydrates":
        return Colors.blue;
      case "proteins":
        return Colors.green;
      case "fat":
        return Colors.red;
      case "saturated-fat":
        return Colors.redAccent;
      case "fiber":
        return Colors.brown;
      case "salt":
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getNutrientIcon(String key) {
    switch (key) {
      case "energy-kcal":
        return Icons.bolt;
      case "carbohydrates":
        return Icons.grain;
      case "proteins":
        return Icons.fitness_center;
      case "fat":
        return Icons.opacity;
      case "saturated-fat":
        return Icons.warning;
      case "fiber":
        return Icons.grass;
      case "salt":
        return Icons.cookie;
      default:
        return Icons.science;
    }
  }

  String _formatKey(String key) {
    Map<String, String> labels = {
      "energy-kcal": "Energy",
      "carbohydrates": "Carbohydrates",
      "sugars": "Sugars",
      "proteins": "Proteins",
      "fat": "Fats",
      "saturated-fat": "Saturated Fat",
      "fiber": "Fibers",
      "salt": "Salt",
    };
    return labels[key] ?? key;
  }

  String _getUnit(String key) {
    if (key.contains("energy")) return "kcal";
    if (key.contains("sugars") ||
        key.contains("carbohydrates") ||
        key.contains("proteins") ||
        key.contains("fat") ||
        key.contains("salt") ||
        key.contains("fiber")) {
      return "g";
    }
    return "";
  }
}

class NutrientItem {
  final String key;
  final String label;
  final String value;
  final String unit;

  NutrientItem({
    required this.key,
    required this.label,
    required this.value,
    required this.unit,
  });
}
