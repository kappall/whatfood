import 'package:flutter/material.dart';

class IntollerancesList extends StatefulWidget {
  final Set<String> intollerances;
  const IntollerancesList({super.key, required this.intollerances});

  static const List<String> foodIntolerances = [
    "Milk",
    "Eggs",
    "Fish",
    "Shellfish",
    "Peanuts",
    "Soy",
    "Wheat",
    "Gluten",
    "Tree Nuts",
    "Sesame",
    "Mustard",
    "Sulfites",
    "Lupin",
    "Celery",
    "Mollusks",
    "Crustaceans",
    "Corn",
    "Rice",
    "Barley",
    "Rye"
  ];

  @override
  State<IntollerancesList> createState() => _IntollerancesListState();
}

class _IntollerancesListState extends State<IntollerancesList> {
  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: IntollerancesList.foodIntolerances.map((intoll) {
        final bool selected = widget.intollerances.contains(intoll);
        return FilterChip(
          label: Text(intoll),
          selected: selected,
          selectedColor:
              Colors.redAccent, // Colore di sfondo quando selezionato
          backgroundColor: Colors.grey[200],
          onSelected: (bool selected) {
            setState(() {
              if (selected) {
                widget.intollerances.add(intoll);
              } else {
                widget.intollerances.remove(intoll);
              }
            });
          },
          labelStyle: TextStyle(
            color: selected ? Colors.white : Colors.black,
          ),
        );
      }).toList(),
    );
  }
}
