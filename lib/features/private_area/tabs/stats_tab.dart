import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:whatfood/features/private_area/widgets/kcal_line_chart.dart';
import 'package:whatfood/features/private_area/widgets/macro_radar_chart.dart';

import 'diary_tab.dart' show diaryGroupedProvider, DayGroup;

enum Period { day, week, month, all }

final _periodProvider = StateProvider<Period>((_) => Period.day);

extension on DateTime {
  int get weekOfYear {
    final first = DateTime(year, 1, 1);
    final days = difference(first).inDays;
    return ((days + first.weekday - 1) / 7).ceil();
  }
}

class StatsTab extends ConsumerWidget {
  const StatsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final grouped = ref.watch(diaryGroupedProvider);
    final period = ref.watch(_periodProvider);

    final data = _aggregate(grouped, period);
    const goal = NutrientGoal(kcal: 100, protein: 100, carbs: 100, fat: 100);
    final feedback = _feedback(data, goal, period);
    final dailyKcal = _dailyCalories(grouped, period);

    return Scaffold(
      backgroundColor:
          Theme.of(context).colorScheme.surfaceVariant.withOpacity(.25),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: const Text('Statistics'),
            pinned: true,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(48),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: _PeriodSelector(period: period),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate.fixed([
                _FeedbackCard(feedback: feedback),
                const SizedBox(height: 16),
                _NutrientCard(data: data, goal: goal),
                const SizedBox(height: 16),
                _MacroAverageCard(data: data, period: period),
                const SizedBox(height: 16),
                _WeekComparisonCard(groups: grouped, period: period),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  /* ---------------- providers & helpers ---------------- */

  Map<DateTime, int> _dailyCalories(List<DayGroup> groups, Period period) {
    final now = DateTime.now();
    bool isIn(DateTime date) {
      switch (period) {
        case Period.day:
          return DateUtils.isSameDay(date, now);
        case Period.week:
          return date.weekOfYear == now.weekOfYear && date.year == now.year;
        case Period.month:
          return date.month == now.month && date.year == now.year;
        case Period.all:
          return true;
      }
    }

    final daily = <DateTime, int>{};
    for (final g in groups) {
      if (!isIn(g.date)) continue;
      final day = DateTime(g.date.year, g.date.month, g.date.day);
      daily[day] = g.meals.fold<int>(0, (sum, e) => sum + (e.calories ?? 0));
    }
    return daily;
  }

  NutrientData _aggregate(List<DayGroup> groups, Period period) {
    final now = DateTime.now();
    bool isIn(DateTime date) {
      switch (period) {
        case Period.day:
          return DateUtils.isSameDay(date, now);
        case Period.week:
          return date.weekOfYear == now.weekOfYear && date.year == now.year;
        case Period.month:
          return date.month == now.month && date.year == now.year;
        case Period.all:
          return true;
      }
    }

    int k = 0, p = 0, c = 0, f = 0;
    for (final d in groups) {
      if (!isIn(d.date)) continue;
      for (final e in d.meals) {
        k += e.calories ?? 0;
        p += e.protein?.round() ?? 0;
        c += e.carbs?.round() ?? 0;
        f += e.fat?.round() ?? 0;
      }
    }
    return NutrientData(kcal: k, protein: p, carbs: c, fat: f);
  }

  String _feedback(NutrientData d, NutrientGoal g, Period p) {
    final ratio = d.kcal / g.kcal;
    final name = p.name[0].toUpperCase() + p.name.substring(1);
    if (ratio < .7) return '$name: far below quota. Adjust meals.';
    if (ratio > 1.3) return '$name: quota exceeded. Rebalance.';
    return '$name: on track — keep it up!';
  }
}

/* ---------------- reusable widgets ---------------- */

class _PeriodSelector extends ConsumerWidget {
  const _PeriodSelector({required this.period});
  final Period period;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SegmentedButton<Period>(
      segments: const [
        ButtonSegment(value: Period.day, label: Text('Day')),
        ButtonSegment(value: Period.week, label: Text('Week')),
        ButtonSegment(value: Period.month, label: Text('Month')),
        ButtonSegment(value: Period.all, label: Text('All')),
      ],
      selected: {period},
      onSelectionChanged: (s) =>
          ref.read(_periodProvider.notifier).state = s.first,
      showSelectedIcon: false,
    );
  }
}

class _FeedbackCard extends StatelessWidget {
  const _FeedbackCard({required this.feedback});
  final String feedback;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.info_outline,
                color: Theme.of(context).colorScheme.onPrimaryContainer),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                feedback,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NutrientCard extends StatelessWidget {
  const _NutrientCard({required this.data, required this.goal});
  final NutrientData data;
  final NutrientGoal goal;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Nutrient Goals',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    )),
            const SizedBox(height: 12),
            _NutrientBar(label: 'Calories', value: data.kcal, goal: goal.kcal),
            _NutrientBar(
                label: 'Protein', value: data.protein, goal: goal.protein),
            _NutrientBar(label: 'Carbs', value: data.carbs, goal: goal.carbs),
            _NutrientBar(label: 'Fat', value: data.fat, goal: goal.fat),
          ],
        ),
      ),
    );
  }
}

class _MacroAverageCard extends StatelessWidget {
  const _MacroAverageCard({required this.data, required this.period});
  final NutrientData data;
  final Period period;

  int _divisor(Period p) {
    switch (p) {
      case Period.day:
        return 1;
      case Period.week:
        return 7;
      case Period.month:
        return 30;
      case Period.all:
        return 90;
    }
  }

  @override
  Widget build(BuildContext context) {
    final divisor = _divisor(period);
    final macros = {
      'Protein': data.protein / divisor,
      'Carbs': data.carbs / divisor,
      'Fat': data.fat / divisor,
    };

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Avg. Macronutrient Intake',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    )),
            const SizedBox(height: 16),
            ...macros.entries.map(
              (e) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    SizedBox(width: 60, child: Text(e.key)),
                    Expanded(
                      child: LinearProgressIndicator(
                        value: (e.value / 200).clamp(0, 1),
                        minHeight: 8,
                        backgroundColor: Colors.grey.shade300,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(e.value.toStringAsFixed(0)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WeekComparisonCard extends StatelessWidget {
  const _WeekComparisonCard({required this.groups, required this.period});
  final List<DayGroup> groups;
  final Period period;

  NutrientData _getForPeriod(DateTime start, DateTime end) {
    int k = 0, p = 0, c = 0, f = 0;
    for (final g in groups) {
      if (g.date.isBefore(start) || g.date.isAfter(end)) continue;
      for (final e in g.meals) {
        k += e.calories ?? 0;
        p += e.protein?.round() ?? 0;
        c += e.carbs?.round() ?? 0;
        f += e.fat?.round() ?? 0;
      }
    }
    return NutrientData(kcal: k, protein: p, carbs: c, fat: f);
  }

  @override
  Widget build(BuildContext context) {
    if (period == Period.all) return const SizedBox.shrink();

    final now = DateTime.now();
    final start = {
      Period.day: now.subtract(const Duration(days: 1)),
      Period.week: now.subtract(const Duration(days: 7)),
      Period.month: now.subtract(const Duration(days: 30)),
    }[period]!;

    final currStart = {
      Period.day: DateTime(now.year, now.month, now.day),
      Period.week: now.subtract(Duration(days: now.weekday - 1)),
      Period.month: DateTime(now.year, now.month),
    }[period]!;

    final prev =
        _getForPeriod(start, currStart.subtract(const Duration(days: 1)));
    final curr = _getForPeriod(currStart, now);

    Map<String, int> current = {
      'Kcal': curr.kcal,
      'Protein': curr.protein,
      'Carbs': curr.carbs,
      'Fat': curr.fat,
    };
    Map<String, int> previous = {
      'Kcal': prev.kcal,
      'Protein': prev.protein,
      'Carbs': prev.carbs,
      'Fat': prev.fat,
    };

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Change from Previous ${period.name}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    )),
            const SizedBox(height: 16),
            ...current.entries.map((e) {
              final delta = e.value - previous[e.key]!;
              final icon = delta > 0
                  ? Icons.arrow_upward
                  : delta < 0
                      ? Icons.arrow_downward
                      : Icons.remove;
              final color = delta > 0
                  ? Colors.red
                  : delta < 0
                      ? Colors.green
                      : Colors.grey;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    SizedBox(width: 60, child: Text(e.key)),
                    Icon(icon, color: color, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '${delta.abs()}',
                      style: TextStyle(color: color),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

/* ---------------- models ---------------- */

class NutrientData {
  const NutrientData({
    required this.kcal,
    required this.protein,
    required this.carbs,
    required this.fat,
  });
  final int kcal;
  final int protein;
  final int carbs;
  final int fat;
}

class NutrientGoal {
  const NutrientGoal({
    required this.kcal,
    required this.protein,
    required this.carbs,
    required this.fat,
  });
  final int kcal;
  final int protein;
  final int carbs;
  final int fat;
}

class _NutrientBar extends StatelessWidget {
  const _NutrientBar({
    required this.label,
    required this.value,
    required this.goal,
  });

  final String label;
  final int value;
  final int goal;

  @override
  Widget build(BuildContext context) {
    final ratio = (value / goal).clamp(0, 2);
    final color = ratio < .7
        ? Colors.amber
        : ratio <= 1.3
            ? Colors.green
            : Colors.red;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: Theme.of(context).textTheme.labelMedium),
              Text('$value / $goal',
                  style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: LinearProgressIndicator(
              value: ratio.toDouble(),
              minHeight: 8,
              backgroundColor: Theme.of(context).colorScheme.surface,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }
}
