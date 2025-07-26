import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:intl/intl.dart';
//TODO: backend connection

final statsProvider = Provider<Stats>((_) => Stats.mock());

class Stats {
  final List<IngredientCount> ingredients;
  final Map<DateTime, int> last7Days;
  final double healthScore;

  Stats(this.ingredients, this.last7Days, this.healthScore);

  factory Stats.mock() => Stats(
        [
          IngredientCount('Tomato', 42, Colors.red),
          IngredientCount('Spinach', 30, Colors.green),
          IngredientCount('Rice', 28, Colors.brown),
        ],
        {
          for (int i = 0; i < 7; i++)
            DateTime.now().subtract(Duration(days: i)): 3 + i % 2,
        },
        0.85,
      );
}

class IngredientCount {
  final String name;
  final int count;
  final Color color;
  IngredientCount(this.name, this.count, this.color);
}

class StatsTab extends ConsumerWidget {
  const StatsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(statsProvider);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Most eaten ingredients',
            style: Theme.of(context).textTheme.titleMedium),
        SizedBox(
          height: 200,
          child: PieChart(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOut,
            PieChartData(
              centerSpaceRadius: double.infinity, // auto-size to container
              centerSpaceColor: Colors.transparent,
              startDegreeOffset: -90, // 12-o’clock start
              sectionsSpace:
                  kIsWeb ? 0 : 2, // 0 on web to avoid Path.combine crash
              pieTouchData: PieTouchData(
                touchCallback: (FlTouchEvent event, PieTouchResponse? res) {
                  // example: show snack-bar on tap
                  if (res != null && event is FlTapUpEvent) {
                    final idx = res.touchedSection?.touchedSectionIndex;
                    if (idx != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${data.ingredients[idx].name} '
                              '${data.ingredients[idx].count}×'),
                          duration: const Duration(milliseconds: 800),
                        ),
                      );
                    }
                  }
                },
              ),
              sections: data.ingredients
                  .asMap()
                  .entries
                  .map(
                    (entry) => PieChartSectionData(
                      value: entry.value.count.toDouble(),
                      color: entry.value.color,
                      gradient: LinearGradient(
                        colors: [
                          entry.value.color.withOpacity(0.9),
                          entry.value.color.withOpacity(0.6),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      radius: 60,
                      showTitle: true,
                      title: '${entry.value.name}\n${entry.value.count}',
                      titleStyle: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      titlePositionPercentageOffset: 0.55,
                      badgeWidget: _Badge(entry.value.count),
                      badgePositionPercentageOffset: 1.3,
                      borderSide: const BorderSide(
                        color: Colors.white,
                        width: 2,
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text('Meals per day last 7 days',
            style: Theme.of(context).textTheme.titleMedium),
        SizedBox(
          height: 160,
          child: BarChart(
            BarChartData(
              barGroups: data.last7Days.entries
                  .mapWithIndex((i, e) => BarChartGroupData(
                        x: i.value,
                        barRods: [
                          BarChartRodData(
                            toY: e.toDouble(),
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ],
                      ))
                  .toList(),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (v, __) => Text(DateFormat.E()
                        .format(data.last7Days.keys.elementAt(v.toInt()))),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text('Health score: ${(data.healthScore * 100).toStringAsFixed(0)}%',
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        LinearProgressIndicator(value: data.healthScore),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge(this.count);
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
      ),
      child: Text(
        '$count',
        style: const TextStyle(
          color: Colors.black,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
