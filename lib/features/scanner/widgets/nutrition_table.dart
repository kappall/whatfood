import 'package:flutter/material.dart';

class NutritionTable extends StatelessWidget {
  final Map<String, dynamic>? data;
  const NutritionTable({super.key, required this.data});

  // Lista di nutrienti essenziali da visualizzare
  static const List<String> essentialKeys = [
    "energy-kcal_100g", // Energia in kcal
    "carbohydrates_100g", // Carboidrati
    "sugars_100g", // Zuccheri
    "proteins_100g", // Proteine
    "fat_100g", // Grassi
    "saturated-fat_100g", // Grassi saturi
    "fiber_100g", // Fibre
    "salt_100g", // Sale
  ];

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text(
        "Per 100g",
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
        .where((key) =>
            data?.containsKey(key) ?? false) // Filtra solo quelli presenti
        .map((key) {
      return TableRow(children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            _formatKey(key), // Nome leggibile
            textAlign: TextAlign.left,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            "${data![key]} ${_getUnit(key)}", // Valore con unità
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ]);
    }).toList();
  }

  /// Converte la chiave tecnica in un nome leggibile
  String _formatKey(String key) {
    Map<String, String> labels = {
      "energy-kcal_100g": "Energy (kcal)",
      "carbohydrates_100g": "Carbohydrates",
      "sugars_100g": "Sugars",
      "proteins_100g": "Proteins",
      "fat_100g": "Fats",
      "saturated-fat_100g": "   Saturated",
      "fiber_100g": "Fibers",
      "salt_100g": "Salt",
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
