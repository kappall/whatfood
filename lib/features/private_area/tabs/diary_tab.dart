import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:whatfood/models/diary_entry.dart';

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

  Future<void> add(
    String meal, {
    String? quantity,
    int? calories,
    MealType type = MealType.other,
  }) async {
    final key = await _box.add(
      DiaryEntry(
        meal: meal,
        timestamp: DateTime.now(),
        quantity: quantity,
        calories: calories,
        type: type,
        key: 0,
      ),
    );
    final entry = DiaryEntry(
      meal: meal,
      timestamp: DateTime.now(),
      quantity: quantity,
      calories: calories,
      type: type,
      key: key,
    );
    await _box.put(key, entry);
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

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 12, 20, 8),
              child: _AddMealInput(),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: grouped.length,
                itemBuilder: (_, i) {
                  final day = grouped[i];
                  return _DayCard(day: day);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DayCard extends ConsumerWidget {
  const _DayCard({required this.day});
  final DayGroup day;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateLabel = DateFormat.yMMMMd().format(day.date);
    final isToday = DateUtils.isSameDay(day.date, DateTime.now());

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding:
              const EdgeInsets.only(bottom: 8, left: 16, right: 16),
          iconColor: Colors.grey.shade600,
          collapsedIconColor: Colors.grey.shade600,
          title: Text(
            dateLabel,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
              color: isToday
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey.shade800,
            ),
          ),
          children: day.meals.map((m) {
            final subtitle = [
              if (m.quantity != null) m.quantity,
              if (m.calories != null) '${m.calories} kcal',
              m.type.name,
            ].join(' • ');

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          m.meal,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF333333),
                          ),
                        ),
                      ),
                      Text(
                        DateFormat.Hm().format(m.timestamp),
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade500),
                      ),
                      // delete icon only for today
                      if (isToday) ...[
                        const SizedBox(width: 8),
                        InkWell(
                          onTap: () async {
                            final box = Hive.box<DiaryEntry>('foodDiary');
                            await box
                                .delete(m.key); // or use index if you store it
                            ref.invalidate(diaryProvider);
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: const Padding(
                            padding: EdgeInsets.all(4),
                            child: Icon(Icons.delete_outline,
                                size: 18, color: Colors.red),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (subtitle.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(left: 8, top: 2),
                      child: Text(
                        subtitle,
                        style: TextStyle(
                            fontSize: 11, color: Colors.grey.shade600),
                      ),
                    ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _AddMealInput extends ConsumerStatefulWidget {
  const _AddMealInput();

  @override
  ConsumerState<_AddMealInput> createState() => _AddMealInputState();
}

class _AddMealInputState extends ConsumerState<_AddMealInput> {
  final _ctrl = TextEditingController();
  final _qtyCtrl = TextEditingController();
  final _kcalCtrl = TextEditingController();
  final _focus = FocusNode();

  MealType _type = MealType.breakfast;

  bool _showOptional = false;

  @override
  void initState() {
    super.initState();
    _focus.addListener(() {
      if (_focus.hasFocus) setState(() => _showOptional = true);
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _qtyCtrl.dispose();
    _kcalCtrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;

    ref.read(diaryProvider.notifier).add(
          text,
          type: _type,
          quantity: _qtyCtrl.text.trim().isEmpty ? null : _qtyCtrl.text.trim(),
          calories: int.tryParse(_kcalCtrl.text.trim()),
        );

    setState(() {
      _showOptional = false;
      _ctrl.clear();
      _qtyCtrl.clear();
      _kcalCtrl.clear();
    });
    _focus.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary.withOpacity(.85);

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                focusNode: _focus,
                controller: _ctrl,
                textInputAction: TextInputAction.next,
                onSubmitted: (_) => _submit(),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: 'What did you eat?',
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(28),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(28),
                    borderSide: BorderSide(color: primary, width: 1.2),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            FloatingActionButton(
              mini: true,
              elevation: 0,
              backgroundColor: primary,
              onPressed: _submit,
              child: const Icon(Icons.send, size: 22, color: Colors.white),
            ),
          ],
        ),
        if (_showOptional) ...[
          const SizedBox(height: 8),
          _OptionalPanel(
            type: _type,
            onTypeChanged: (t) => setState(() => _type = t),
            qtyCtrl: _qtyCtrl,
            kcalCtrl: _kcalCtrl,
            focus: _focus,
          ),
        ],
      ],
    );
  }
}

class _OptionalPanel extends StatelessWidget {
  _OptionalPanel({
    required this.type,
    required this.onTypeChanged,
    required this.qtyCtrl,
    required this.kcalCtrl,
    required this.focus,
  });

  final MealType type;
  final ValueChanged<MealType> onTypeChanged;
  final TextEditingController qtyCtrl;
  final TextEditingController kcalCtrl;
  final FocusNode focus;

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(color: Colors.grey.shade700, fontSize: 13);
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.03),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Optional', style: textStyle.copyWith(fontSize: 11)),
          const SizedBox(height: 8),
          // scrollable chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: MealType.values
                  .map(
                    (t) => Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: ChoiceChip(
                        label: Text(t.name),
                        selected: type == t,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        labelStyle: TextStyle(
                          fontSize: 12,
                          color:
                              type == t ? Colors.white : Colors.grey.shade700,
                        ),
                        selectedColor: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(.85),
                        side: BorderSide.none,
                        onSelected: (_) => onTypeChanged(t),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 8),
          //TODO: focus not working on first tap
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: qtyCtrl,
                  onTap: () => focus.unfocus(),
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: 'Quantity',
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(.85),
                        width: 1.4,
                      ),
                    ),
                  ),
                  style: textStyle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: kcalCtrl,
                  onTap: () => focus.unfocus(),
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: 'kcal',
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(.85),
                        width: 1.4,
                      ),
                    ),
                  ),
                  style: textStyle,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
