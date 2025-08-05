import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatfood/features/ingredients/controller/ingredient_controller.dart';
import 'package:whatfood/features/ingredients/widgets/ingredient_card.dart';
import 'package:whatfood/l10n/app_localizations.dart';
import 'package:whatfood/models/Ingredient.dart';

class IngredientsScreen extends ConsumerStatefulWidget {
  const IngredientsScreen({super.key});

  @override
  ConsumerState<IngredientsScreen> createState() => _IngredientsScreenState();
}

class _IngredientsScreenState extends ConsumerState<IngredientsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl;

  final _searchCtrl = TextEditingController();
  String _query = '';

  final List<String> _categories = [];
  final List<String> _allergensAvoid = [];
  final List<String> _ingredientsAvoid = [];
  final List<String> _nutritionGrades = [];
  final List<String> _novaGroups = [];
  bool _vegan = false;
  bool _vegetarian = false;
  bool _glutenFree = false;

  AsyncValue<List<Ingredient>>? _lastResult;

  Timer? _debounce;

  Future<void> _search() async {
    final params = OpenFoodFactsParams(
      query: _query.trim(),
      categories: _categories,
      allergensToAvoid: _allergensAvoid,
      ingredientsToAvoid: _ingredientsAvoid,
      nutritionGrades: _nutritionGrades,
      novaGroups: _novaGroups,
      vegan: _vegan,
      vegetarian: _vegetarian,
      glutenFree: _glutenFree,
    );
    final res = await ref.read(openFoodFactsProvider(params).future);
    if (mounted) setState(() => _lastResult = AsyncValue.data(res));
  }

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    _query = 'pasta';
    _searchCtrl.text = _query;
    _search();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.dispose();
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: Text(l10n.ingredientsLabel),
            bottom: TabBar(
              controller: _tabCtrl,
              tabs: [
                Tab(icon: Icon(Icons.list), text: l10n.ingredientsLabel),
                Tab(icon: Icon(Icons.shopping_cart), text: l10n.cartLabel),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabCtrl,
            children: [
              _buildIngredientsTab(),
              const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.shopping_cart_outlined, size: 48),
                    SizedBox(height: 8),
                    Text('Your cart is empty'),
                    SizedBox(height: 16),
                    Text(
                      'Here you will add ingredients later',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIngredientsTab() {
    final asyncIng = _lastResult;
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Search ingredients...',
                prefixIcon: const Icon(Icons.search),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
              ),
              onChanged: (v) {
                setState(() => _query = v);
                _debounce?.cancel();
                _debounce = Timer(const Duration(milliseconds: 500), _search);
              },
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                ...['Pasta', 'Bread', 'Milk', 'Cheese', 'Yogurt']
                    .map((c) => _filterChip(c, _categories)),
                const SizedBox(width: 8),
                ...['Milk', 'Eggs', 'Nuts', 'Soy', 'Gluten']
                    .map((a) => _filterChip('NO $a', _allergensAvoid)),
                const SizedBox(width: 8),
                ...['a', 'b', 'c', 'd', 'e']
                    .map((g) => _filterChip('Grade $g', _nutritionGrades)),
                const SizedBox(width: 8),
                ...['1', '2', '3', '4']
                    .map((n) => _filterChip('Nova $n', _novaGroups)),
                const SizedBox(width: 8),
                _toggleChip('Vegan', _vegan, (v) => setState(() => _vegan = v)),
                _toggleChip('Vegetarian', _vegetarian,
                    (v) => setState(() => _vegetarian = v)),
                _toggleChip('Gluten-Free', _glutenFree,
                    (v) => setState(() => _glutenFree = v)),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: asyncIng?.when(
                  data: (list) => GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: .75,
                    ),
                    itemCount: list.length,
                    itemBuilder: (_, i) => IngredientCard(
                      ingredient: list[i],
                      imageUrl: list[i].coverImage,
                    ),
                  ),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('Error: $e')),
                ) ??
                const SizedBox(),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String label, List<String> list) {
    final selected = list.contains(label);
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: FilterChip(
        label: Text(label),
        selected: selected,
        onSelected: (sel) {
          setState(() {
            sel ? list.add(label) : list.remove(label);
          });
          _search();
        },
      ),
    );
  }

  Widget _toggleChip(String label, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: FilterChip(
        label: Text(label),
        selected: value,
        onSelected: (v) {
          onChanged(v);
          _search();
        },
      ),
    );
  }
}
