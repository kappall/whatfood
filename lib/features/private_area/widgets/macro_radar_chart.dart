import 'package:flutter/material.dart';
import 'package:flutter_radar_chart/flutter_radar_chart.dart';

class NutrientGoal {
  final protein = 100;
  final carbs = 100;
  final fat = 100;
}

class MacroRadarChart extends StatelessWidget {
  MacroRadarChart({
    required this.protein,
    required this.carbs,
    required this.fat,
    super.key,
  });

  final int protein;
  final int carbs;
  final int fat;
  final NutrientGoal goal = NutrientGoal();

  @override
  Widget build(BuildContext context) {
    const ticks = [0, 1, 2, 3]; // % del target

    final data = [
      [
        (protein / goal.protein).clamp(0, 2.0),
        (carbs / goal.carbs).clamp(0, 2.0),
        (fat / goal.fat).clamp(0, 2.0),
      ]
    ];

    return Column(
      children: [
        Text('Macro Balance', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        SizedBox(
          height: 150, // o anche meno se vuoi
          width: 150, // quadrato per un radar chart
          child: RadarChart(
            ticks: ticks,
            features: const ['Protein', 'Carbs', 'Fat'],
            data: data,
            reverseAxis: false,
            outlineColor: Colors.grey.shade300,
            graphColors: [Theme.of(context).colorScheme.primary],
          ),
        ),
      ],
    );
  }
}
