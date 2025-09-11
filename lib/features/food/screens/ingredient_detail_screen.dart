import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:routemaster/routemaster.dart';
import 'package:whatfood/models/Ingredient.dart';
import 'package:whatfood/models/ingredient_extensions.dart';

class IngredientDetailScreen extends StatefulWidget {
  final String id;
  const IngredientDetailScreen({super.key, required this.id});

  @override
  State<IngredientDetailScreen> createState() => _IngredientDetailScreenState();
}

class _IngredientDetailScreenState extends State<IngredientDetailScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl;
  Ingredient? _ingredient;
  List<Ingredient> _similar = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
    _fetch();
  }

  Future<void> _fetch() async {
    try {
      // single product
      debugPrint(
          "fetching: ${'https://world.openfoodfacts.org/api/v2/product/${widget.id}.json'}");
      final res = await http.get(Uri.parse(
        'https://world.openfoodfacts.org/api/v2/product/${widget.id}.json',
      ));
      final json = jsonDecode(res.body)['product'];
      final ing = ingredientFromOpenFoodFacts(json);
      debugPrint(ing.toString());

      final cat = (json['categories_tags'] as List?)?.firstOrNull;
      debugPrint('Category tag: $cat');

      final simRes = cat == null
          ? null
          : await http.get(
              Uri.parse('https://world.openfoodfacts.org/api/v2/search')
                  .replace(
                queryParameters: {
                  'categories_tags_en': cat.toString(),
                  'page_size': '4',
                },
              ),
            );

      final simList =
          jsonDecode(simRes?.body ?? "{products:[]}")['products'] as List;

      if (mounted) {
        debugPrint("is mounted");
        setState(() {
          _ingredient = ing;
          debugPrint("new ingredint" + _ingredient.toString());
          _similar = simList
              .map((e) => ingredientFromOpenFoodFacts(e))
              .where((e) => e.id != ing.id)
              .toList();
          _loading = false;
        });
      }
    } catch (e, s) {
      debugPrint('fetch error: $e\n$s');
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final ing = _ingredient;
    if (ing == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Not found')),
        body: const Center(child: Text('Product not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(ing.name),
        leading: IconButton(
            onPressed: () => Routemaster.of(context).pop(),
            icon: Icon(Icons.arrow_back)),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: implementa logica per aggiungere al carrello
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Added to cart')),
          );
        },
        label: const Text('Add to cart'),
        icon: const Icon(Icons.add_shopping_cart_outlined),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        elevation: 4,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: Column(
        children: [
          _IngredientHeader(ingredient: ing),
          if (_similar.isNotEmpty) _SimilarList(similar: _similar),
          TabBar(
            controller: _tabCtrl,
            tabs: const [
              Tab(text: 'Health'),
              Tab(text: 'How to use'),
              Tab(text: 'Where to buy'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabCtrl,
              children: [
                _HealthTab(ing),
                _HowToUseTab(ing),
                _WhereToBuyTab(ing),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _IngredientHeader extends StatelessWidget {
  final Ingredient ingredient;
  const _IngredientHeader({required this.ingredient});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AspectRatio(
          aspectRatio: 16 / 9,
          child: Image.network(
            ingredient.coverImage ?? "",
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const ColoredBox(color: Colors.grey),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            ingredient.name,
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}

class _SimilarList extends StatelessWidget {
  final List<Ingredient> similar;
  const _SimilarList({required this.similar});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Divider(height: 1),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Text(
            'Similar products',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: 110,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            scrollDirection: Axis.horizontal,
            itemCount: similar.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final s = similar[i];
              return GestureDetector(
                onTap: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => IngredientDetailScreen(id: s.id),
                  ),
                ),
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        s.coverImage ?? "",
                        width: 70,
                        height: 70,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.broken_image),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(s.name, style: const TextStyle(fontSize: 12)),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _HealthTab extends StatelessWidget {
  final Ingredient ing;
  const _HealthTab(this.ing);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Health Score', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: (ing.healthScore ?? 0) / 100,
            minHeight: 8,
            color: Colors.green,
            backgroundColor: Colors.green.shade100,
          ),
          const SizedBox(height: 12),
          _NutritionTable(ing),
        ],
      ),
    );
  }
}

class _NutritionTable extends StatelessWidget {
  final Ingredient ing;
  const _NutritionTable(this.ing);

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> nutrition =
        Map<String, dynamic>.from(jsonDecode(ing.nutritionPer100g ?? "{}"));

    final nutrients = {
      'Energy': '${nutrition['energyKcal'] ?? '-'} kcal',
      'Proteins': '${nutrition['proteins'] ?? '-'} g',
      'Carbs': '${nutrition['carbs'] ?? '-'} g',
      'Fat': '${nutrition['fat'] ?? '-'} g',
      'Fiber': '${nutrition['fiber'] ?? '-'} g',
      'Sugar': '${nutrition['sugars'] ?? '-'} g',
    };

    return Table(
      border: TableBorder.all(color: Colors.grey.shade300),
      children: [
        const TableRow(
          children: [Text('Nutrient'), Text('Per 100 g')],
        ),
        ...nutrients.entries.map(
          (e) => TableRow(
            children: [Text(e.key), Text(e.value)],
          ),
        ),
      ],
    );
  }
}

class _HowToUseTab extends StatelessWidget {
  final Ingredient ing;
  const _HowToUseTab(this.ing);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ListView.builder(
          itemCount: ing.tips.length,
          itemBuilder: (context, index) {
            return Text(
              ing.tips[index],
              textAlign: TextAlign.center,
            );
          }),
    );
  }
}

class _WhereToBuyTab extends StatelessWidget {
  final Ingredient ing;
  const _WhereToBuyTab(this.ing);

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Where-to-buy info coming soon'));
  }
}
