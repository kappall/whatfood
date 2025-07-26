import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:whatfood/models/diary_entry.dart';
//TODO: backend connection

final diaryProvider =
    NotifierProvider<DiaryNotifier, List<DiaryEntry>>(DiaryNotifier.new);

class DiaryNotifier extends Notifier<List<DiaryEntry>> {
  late Box<DiaryEntry> _box;

  @override
  List<DiaryEntry> build() {
    _box = Hive.box<DiaryEntry>('foodDiary');
    return _box.values.toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  void add(String meal) async {
    final entry = DiaryEntry(meal: meal, timestamp: DateTime.now());
    await _box.add(entry);
    state = [...state, entry];
  }
}

final diaryGroupedProvider = Provider<List<DayGroup>>((ref) {
  final entries = ref.watch(diaryProvider);

  final groupedMap = <String, List<DiaryEntry>>{};

  for (final entry in entries) {
    final dateKey = DateFormat('yyyy-MM-dd').format(entry.timestamp);
    groupedMap.putIfAbsent(dateKey, () => []).add(entry);
  }

  final groups = groupedMap.entries.map((e) {
    final date = DateTime.parse(e.key);
    final meals = e.value;
    meals.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return DayGroup(date, meals);
  }).toList()
    ..sort((a, b) => b.date.compareTo(a.date));

  return groups;
});

class DayGroup {
  final DateTime date;
  final List<DiaryEntry> meals;
  DayGroup(this.date, this.meals);
}

class DiaryTab extends ConsumerWidget {
  const DiaryTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final grouped = ref.watch(diaryGroupedProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: _AddMealInput(),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: grouped.length,
            itemBuilder: (_, i) {
              final day = grouped[i];
              return ExpansionTile(
                title: Text(DateFormat.yMMMMd().format(day.date)),
                children: day.meals
                    .map((m) => ListTile(
                          title: Text(m.meal),
                          trailing: Text(DateFormat.Hm().format(m.timestamp)),
                        ))
                    .toList(),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _AddMealInput extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ctrl = TextEditingController();
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: ctrl,
            decoration: const InputDecoration(
              hintText: 'What did you eat?',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(Icons.send, size: 32),
          onPressed: () {
            if (ctrl.text.trim().isEmpty) return;
            ref.read(diaryProvider.notifier).add(ctrl.text.trim());
            ctrl.clear();
          },
        ),
      ],
    );
  }
}
