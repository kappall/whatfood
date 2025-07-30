import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'diary_tab.dart' show diaryGroupedProvider, DayGroup;

enum Period { day, week, month, all }

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
    final goal =
        const NutrientGoal(kcal: 100, protein: 100, carbs: 100, fat: 100);
    final feedback = _feedback(data, goal, period);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _PeriodSelector(period: period),
          const SizedBox(height: 16),
          _FeedbackCard(feedback: feedback),
          const SizedBox(height: 24),
          _NutrientBar(label: 'Calories', value: data.kcal, goal: goal.kcal),
          _NutrientBar(
              label: 'Protein', value: data.protein, goal: goal.protein),
          _NutrientBar(label: 'Carbs', value: data.carbs, goal: goal.carbs),
          _NutrientBar(label: 'Fat', value: data.fat, goal: goal.fat),
        ],
      ),
    );
  }

  static final _periodProvider = StateProvider<Period>((_) => Period.day);

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

    int kcal = 0, protein = 0, carbs = 0, fat = 0;
    for (final day in groups) {
      if (!isIn(day.date)) continue;
      for (final e in day.meals) {
        debugPrint(e.toJson().toString());
        if (e.calories != null &&
            e.carbs != null &&
            e.fat != null &&
            e.protein != null) {
          kcal += e.calories!;
          protein += e.protein!.round();
          carbs += e.carbs!.round();
          fat += e.fat!.round();
        }
      }
    }
    return NutrientData(kcal: kcal, protein: protein, carbs: carbs, fat: fat);
  }

  String _feedback(NutrientData d, NutrientGoal g, Period p) {
    final ratio = d.kcal / g.kcal;
    final periodStr = p.name[0].toUpperCase() + p.name.substring(1);
    if (ratio < .7) {
      return "$periodStr: far below quota. Adjust your meals.";
    } else if (ratio > 1.3) {
      return "$periodStr: exceeded quota. Try rebalancing.";
    } else {
      return "$periodStr: on track — keep it up!";
    }
  }
}

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
          ref.read(StatsTab._periodProvider.notifier).state = s.first,
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
      color: Theme.of(context).colorScheme.primaryContainer,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
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
    final ratio = (value / goal).clamp(0, 2).toDouble();
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
          Text(label, style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 12,
              backgroundColor: Theme.of(context).colorScheme.surface,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '$value / $goal',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
