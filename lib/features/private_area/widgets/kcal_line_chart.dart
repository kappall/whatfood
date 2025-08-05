import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class KcalLineChart extends StatelessWidget {
  const KcalLineChart({
    required this.dailyData,
    required this.periodLabel,
    super.key,
  });

  final Map<DateTime, int> dailyData;
  final String periodLabel; // "Day", "Week", etc.

  @override
  Widget build(BuildContext context) {
    if (dailyData.isEmpty) {
      return _EmptyState(periodLabel: periodLabel);
    }

    final sorted = dailyData.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    final spots = sorted
        .map((e) =>
            FlSpot(e.key.millisecondsSinceEpoch.toDouble(), e.value.toDouble()))
        .toList();

    final maxY =
        spots.fold<double>(0, (prev, s) => s.y > prev ? s.y : prev) * 1.1;

    final colorScheme = Theme.of(context).colorScheme;

    return AspectRatio(
      aspectRatio: 1.8,
      child: LineChart(
        LineChartData(
          lineTouchData: LineTouchData(enabled: true),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: colorScheme.primary,
              barWidth: 3,
              dotData: FlDotData(
                show: true,
                getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
                  radius: 4,
                  color: colorScheme.primary,
                  strokeWidth: 2,
                  strokeColor: colorScheme.surface,
                ),
              ),
            ),
          ],
          titlesData: FlTitlesData(
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1,
                getTitlesWidget: (value, _) {
                  final idx = value.toInt();
                  if (idx < 0 || idx >= sorted.length) return const SizedBox();
                  final date = sorted[idx].key;
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      DateFormat('d/M').format(date),
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 36,
                interval: maxY > 0 ? (maxY / 4) : 25,
                getTitlesWidget: (value, _) => Text(
                  value.toInt().toString(),
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ),
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: maxY > 0 ? (maxY / 4) : 25,
            getDrawingHorizontalLine: (_) => FlLine(
              color: colorScheme.outlineVariant,
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(show: false),
          minX: 0,
          maxX: spots.length.toDouble() - 1,
          minY: 0,
          maxY: maxY,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.periodLabel});
  final String periodLabel;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Text(
          'No kcal data for this $periodLabel.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }
}
