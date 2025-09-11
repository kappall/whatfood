import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:whatfood/core/common/loader.dart';
import 'package:whatfood/features/auth/controller/auth_controller.dart';
import 'package:whatfood/features/private_area/controllers/food_suggestion_controller.dart';
import 'package:whatfood/models/diary_entry.dart';
import 'package:whatfood/models/food_suggestion.dart';

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
    double? protein,
    double? fat,
    double? carbs,
    MealType type = MealType.other,
  }) async {
    final key = await _box.add(
      DiaryEntry(
        meal: meal,
        timestamp: DateTime.now(),
        quantity: quantity,
        calories: calories,
        protein: protein,
        fat: fat,
        carbs: carbs,
        type: type,
        key: 0,
      ),
    );
    final entry = DiaryEntry(
      meal: meal,
      timestamp: DateTime.now(),
      quantity: quantity,
      calories: calories,
      protein: protein,
      fat: fat,
      carbs: carbs,
      type: type,
      key: key,
    );
    await _box.put(key, entry);
    state = [...state, entry];
  }

  Future<void> addEntry(DiaryEntry entry) async {
    final tempEntry = _copyFrom(entry, 0);
    final key = await _box.add(tempEntry);

    final finalEntry = _copyFrom(entry, key);
    await _box.put(key, finalEntry);
    state = [...state, finalEntry];
  }

  DiaryEntry _copyFrom(DiaryEntry entry, int key) {
    return DiaryEntry(
      meal: entry.meal,
      timestamp: entry.timestamp,
      quantity: entry.quantity,
      calories: entry.calories,
      protein: entry.protein,
      fat: entry.fat,
      carbs: entry.carbs,
      type: entry.type,
      key: key,
    );
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

class DiaryTab extends ConsumerStatefulWidget {
  const DiaryTab({super.key});

  @override
  ConsumerState<DiaryTab> createState() => _DiaryTabState();
}

class _DiaryTabState extends ConsumerState<DiaryTab> {
  bool _showCalendar = true;

  @override
  Widget build(BuildContext context) {
    final grouped = ref.watch(diaryGroupedProvider);

    final activityMap = <DateTime, int>{};
    for (final e in ref.watch(diaryProvider)) {
      final d = DateTime(e.timestamp.year, e.timestamp.month, e.timestamp.day);
      activityMap[d] = (activityMap[d] ?? 0) + 1;
    }

    return SingleChildScrollView(
      child: Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom + 80),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    icon: Icon(
                      _showCalendar ? Icons.expand_less : Icons.expand_more,
                    ),
                    label:
                        Text(_showCalendar ? 'Hide calendar' : 'Show calendar'),
                    onPressed: () {
                      setState(() => _showCalendar = !_showCalendar);
                    },
                  ),
                ],
              ),
            ),
            if (_showCalendar)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: HeatMapCalendar(
                      datasets: activityMap,
                      colorMode: ColorMode.opacity,
                      defaultColor: Colors.grey.shade300,
                      textColor: Colors.black87,
                      showColorTip: false,
                      size: 30,
                      weekTextColor: Colors.grey.shade600,
                      monthFontSize: 12,
                      borderRadius: 6,
                      fontSize: 10,
                      colorTipCount: 3,
                      colorsets: {
                        1: Colors.green.shade100,
                        2: Colors.green.shade300,
                        3: Colors.green.shade600,
                        4: Colors.green.shade900,
                      },
                    ),
                  ),
                ),
              ),
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 12, 20, 8),
              child: _AddMealInput(),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  ...grouped.map((day) => _DayCard(day: day)).toList(),
                ],
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
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
            dividerColor: Colors.transparent,
            splashFactory: NoSplash.splashFactory),
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
                    ? Theme.of(context).colorScheme.onSurface
                    : Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.8)),
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
                          style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(context).colorScheme.onSurface),
                        ),
                      ),
                      Text(
                        DateFormat.Hm().format(m.timestamp),
                        style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.onSurface),
                      ),
                      if (isToday) ...[
                        const SizedBox(width: 8),
                        InkWell(
                          onTap: () async {
                            final box = Hive.box<DiaryEntry>('foodDiary');
                            await box.delete(m.key);
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
                            fontSize: 11,
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant),
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
  final _cardKey = GlobalKey();

  double? _kcalPer100g;
  List<FoodSuggestion> _suggestions = [];
  Timer? _debounce;
  MealType _type = MealType.breakfast;
  bool _showOptional = false;
  bool _submitting = false;

  FoodSuggestion? suggestionSelected;

  @override
  void initState() {
    super.initState();
    _focus.addListener(() {
      if (_focus.hasFocus) setState(() => _showOptional = true);
    });
    _qtyCtrl.addListener(_recalcKcal);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _qtyCtrl.dispose();
    _kcalCtrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _initDefaultFields() {
    _qtyCtrl.text = '100';
  }

  void _recalcKcal() {
    final qty = double.tryParse(_qtyCtrl.text.replaceAll(',', '.'));
    if (qty != null && _kcalPer100g != null) {
      _kcalCtrl.text = ((qty / 100) * _kcalPer100g!).toStringAsFixed(0);
    }
  }

  void _submit() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _submitting = true;
    });
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;

    final jwt = await getCognitoJwt();

    DiaryEntry? food = await fetchFromUSDA(suggestionSelected?.name ?? text);

    if (food == null && jwt != null) {
      food = await fetchNutritionFromAi(text, jwt);
    }

    if (food != null) {
      ref.read(diaryProvider.notifier).addEntry(food);
    } else {
      ref.read(diaryProvider.notifier).add(
            text,
            type: _type,
            quantity:
                _qtyCtrl.text.trim().isEmpty ? null : _qtyCtrl.text.trim(),
            calories: int.tryParse(_kcalCtrl.text.trim()),
          );
    }

    _ctrl.clear();
    _qtyCtrl.clear();
    _kcalCtrl.clear();
    _suggestions.clear();
    _kcalPer100g = null;
    _focus.unfocus();
    setState(() {
      _submitting = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Material(
        color: Colors.white,
        elevation: 2,
        borderRadius: BorderRadius.circular(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 6, 8, 6),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      key: _cardKey,
                      focusNode: _focus,
                      onTapOutside: (event) {
                        _focus.unfocus();
                      },
                      controller: _ctrl,
                      onChanged: (value) {
                        if (_debounce?.isActive ?? false) _debounce!.cancel();
                        _debounce =
                            Timer(const Duration(milliseconds: 1000), () async {
                          //debugPrint("fetching suggestions for ${value}");
                          await normalizeFromAi(value, null);
                          final res = await normalizeFromAi(value, null);
                          //debugPrint("suggestions are ${res.toString()}");
                          if (res != null) {
                            setState(() => _suggestions = res);
                          }
                        });
                      },
                      onSubmitted: (_) => _submit(),
                      style: TextStyle(color: Colors.black),
                      textInputAction: TextInputAction.done,
                      decoration: InputDecoration(
                        hintText: 'What did you eat?',
                        hintStyle: TextStyle(color: Colors.grey.shade500),
                        border: InputBorder.none,
                        isDense: true,
                      ),
                    ),
                  ),
                  if (_submitting)
                    SizedBox(
                      width: 35,
                      height: 35,
                      child: CircularProgressIndicator(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  if (!_submitting)
                    IconButton.filledTonal(
                      style: IconButton.styleFrom(
                        backgroundColor:
                            Theme.of(context).colorScheme.surfaceContainerLow,
                        foregroundColor: Theme.of(context).colorScheme.primary,
                        minimumSize: const Size(40, 40),
                      ),
                      icon: const Icon(Icons.send_rounded, size: 20),
                      onPressed: _submit,
                    ),
                ],
              ),
            ),
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: _OptionalPanel(
                type: _type,
                onTypeChanged: (t) => setState(() => _type = t),
                qtyCtrl: _qtyCtrl,
                kcalCtrl: _kcalCtrl,
                focus: _focus,
                suggestions: _suggestions,
                onSuggestionSelected: (s) {
                  setState(() {
                    suggestionSelected = s;
                    _ctrl.text = s.name;
                    _kcalPer100g = s.kcalPer100g;
                    _suggestions.clear();
                    _initDefaultFields();
                    _recalcKcal();
                  });
                },
              ),
              crossFadeState: _showOptional
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 200),
            ),
          ],
        ),
      ),
    );
  }
}

class _OptionalPanel extends StatelessWidget {
  const _OptionalPanel({
    required this.type,
    required this.onTypeChanged,
    required this.qtyCtrl,
    required this.kcalCtrl,
    required this.focus,
    required this.suggestions,
    required this.onSuggestionSelected,
  });

  final MealType type;
  final ValueChanged<MealType> onTypeChanged;
  final TextEditingController qtyCtrl;
  final TextEditingController kcalCtrl;
  final FocusNode focus;
  final List<FoodSuggestion> suggestions;
  final ValueChanged<FoodSuggestion> onSuggestionSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (suggestions.isNotEmpty) ...[
            SizedBox(
              height: suggestions.length * 80,
              child: Card(
                elevation: 0,
                color: Theme.of(context).colorScheme.surfaceVariant,
                child: ListView(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  children: suggestions
                      .where((s) => s.name.isNotEmpty)
                      .map(
                        (s) => ListTile(
                          title: Text(s.name),
                          subtitle: Text('${s.kcalPer100g} kcal / 100g'),
                          onTap: () => {onSuggestionSelected(s)},
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: MealType.values.map((t) {
                final selected = t == type;
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: FilterChip(
                    label: Text(t.name.capitalize()),
                    selected: selected,
                    showCheckmark: false,
                    labelStyle: TextStyle(
                      fontSize: 14,
                      color: selected
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.secondary,
                    ),
                    onSelected: (_) => onTypeChanged(t),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _SmallField(
                  controller: qtyCtrl,
                  hint: 'Quantity',
                  icon: Icons.scale_outlined,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SmallField(
                  controller: kcalCtrl,
                  hint: 'kcal',
                  icon: Icons.local_fire_department_outlined,
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SmallField extends StatelessWidget {
  const _SmallField({
    required this.controller,
    required this.hint,
    this.icon,
    this.keyboardType,
  });

  final TextEditingController controller;
  final String hint;
  final IconData? icon;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: TextStyle(color: Colors.black),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: icon != null ? Icon(icon, size: 18) : null,
        isDense: true,
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 1.4,
          ),
        ),
      ),
    );
  }
}

extension on String {
  String capitalize() =>
      length > 0 ? '${this[0].toUpperCase()}${substring(1)}' : this;
}
