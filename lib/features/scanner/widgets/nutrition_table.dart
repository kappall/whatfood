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
    return Column(children: [
      Text(
        "Nutritional values",
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
      Table(
        border: TableBorder.all(),
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        children: _generateRows(),
      ),
    ]);
  }

  List<TableRow> _generateRows() {
    return essentialKeys
        .where((key) => data?.containsKey(key) ?? false)
        .map((key) {
      return TableRow(children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            _formatKey(key),
            textAlign: TextAlign.left,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            "${data![key]} ${_getUnit(key)}",
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ]);
    }).toList();
  }

  String _formatKey(String key) {
    Map<String, String> labels = {
      "energy-kcal": "Energy (kcal)",
      "carbohydrates": "Carbohydrates",
      "sugars": "Sugars",
      "proteins": "Proteins",
      "fat": "Fats",
      "saturated-fat": "   Saturated",
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
