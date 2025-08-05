import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
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
                      _showCalendar
                          ? Icons.expand_less
                          : Icons.expand_more,
                    ),
                    label: Text(_showCalendar ? 'Hide calendar' : 'Show calendar'),
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
  final _cardKey = GlobalKey();

  double? _kcalPer100g;
  List<FoodSuggestion> _suggestions = [];
  Timer? _debounce;
  MealType _type = MealType.breakfast;
  bool _showOptional = false;

  final _suggestionBoxKey = GlobalKey();
  OverlayEntry? _overlay;

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
    _overlay?.remove();
    super.dispose();
  }

  void _showOverlay() {
    if (_overlay != null) return;

    final renderBox =
        _suggestionBoxKey.currentContext!.findRenderObject() as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    _overlay = OverlayEntry(
      builder: (context) => Positioned(
        left: offset.dx,
        top: offset.dy + size.height + 4,
        width: size.width,
        child: _buildSuggestionsCard(),
      ),
    );
    Overlay.of(context, rootOverlay: true).insert(_overlay!);
  }

  void _hideOverlay() {
    _overlay?.remove();
    _overlay = null;
  }

  Widget _buildSuggestionsCard() {
    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(16),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 220),
        child: ListView(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          children: _suggestions
              .filter((s) => s.name != '')
              .map(
                (s) => ListTile(
                  title: Text(s.name),
                  subtitle: Text('${s.kcalPer100g} kcal / 100g'),
                  onTap: () {
                    _ctrl.text = s.name;
                    _kcalPer100g = s.kcalPer100g;
                    _initDefaultFields();
                    _recalcKcal();
                    _hideOverlay();
                  },
                ),
              )
              .toList(),
        ),
      ),
    );
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
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    //usda call
    FoodSuggestion? food = await fetchFromUSDA(text);
    debugPrint(food?.carbsPer100g.toString());
    if (food != null) {
      ref.read(diaryProvider.notifier).add(text,
          calories: food.kcalPer100g.round(),
          quantity: _qtyCtrl.text.trim().isEmpty ? null : _qtyCtrl.text.trim(),
          carbs: food.carbsPer100g,
          fat: food.fatPer100g,
          protein: food.proteinPer100g,
          type: _type);
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
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Material(
        color: Colors.white,
        elevation: 2,
        borderRadius: BorderRadius.circular(28),
        child: Column(
          key: _suggestionBoxKey,
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
                      controller: _ctrl,
                      onChanged: (value) {
                        if (_debounce?.isActive ?? false) _debounce!.cancel();
                        _debounce =
                            Timer(const Duration(milliseconds: 50), () async {
                          final res = await fetchSuggestions(value);
                          setState(() => _suggestions = res);
                          if (res.isNotEmpty) {
                            _showOverlay();
                          } else {
                            _hideOverlay();
                          }
                        });
                      },
                      onSubmitted: (_) => _submit(),
                      style: TextStyle(color: Colors.black),
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        hintText: 'What did you eat?',
                        hintStyle: TextStyle(color: Colors.grey.shade500),
                        border: InputBorder.none,
                        isDense: true,
                      ),
                    ),
                  ),
                  IconButton.filledTonal(
                    style: IconButton.styleFrom(
                      backgroundColor: primary.withOpacity(.9),
                      foregroundColor: Colors.white,
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
  });

  final MealType type;
  final ValueChanged<MealType> onTypeChanged;
  final TextEditingController qtyCtrl;
  final TextEditingController kcalCtrl;
  final FocusNode focus;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                      color: selected ? Colors.green : null,
                    ),
                    onSelected: (_) => onTypeChanged(t),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
          // Quantity + kcal row
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
