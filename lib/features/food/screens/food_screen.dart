import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';
import 'package:whatfood/core/common/recipe_card.dart';
import 'package:whatfood/features/food/widgets/ingredient_card.dart';
import 'package:whatfood/features/food/controllers/recipe_controller.dart';
import 'package:whatfood/features/food/controllers/ingredient_controller.dart';
import 'package:whatfood/l10n/app_localizations.dart';

class FoodScreen extends ConsumerStatefulWidget {
  const FoodScreen({super.key});

  @override
  ConsumerState<FoodScreen> createState() => _FoodScreenState();
}

class _FoodScreenState extends ConsumerState<FoodScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _query = '';
  Timer? _debounce;
  final List<String> _filters = [];
  bool _showIngredients = true;

  @override
  void dispose() {
    _searchCtrl.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    var params = OpenFoodFactsParams();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 180,
            floating: true,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Theme.of(context).primaryColor,
                      Theme.of(context).primaryColor.withValues(alpha: 0.8),
                    ],
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Discover Food',
                      style:
                          Theme.of(context).textTheme.headlineLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _searchCtrl,
                      decoration: InputDecoration(
                        hintText: 'Search recipes or ingredients...',
                        filled: true,
                        fillColor: Colors.white,
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onChanged: (v) {
                        setState(() => _query = v);
                        _debounce?.cancel();
                        _debounce = Timer(
                          const Duration(milliseconds: 500),
                          () => setState(() {}),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),

          // Toggle and Filters
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Toggle between Ingredients and Recipes
                  SegmentedButton<bool>(
                    selected: {_showIngredients},
                    onSelectionChanged: (Set<bool> newSelection) {
                      setState(() {
                        _showIngredients = newSelection.first;
                      });
                    },
                    segments: const [
                      ButtonSegment(
                        value: true,
                        icon: Icon(Icons.egg_outlined),
                        label: Text('Ingredients'),
                      ),
                      ButtonSegment(
                        value: false,
                        icon: Icon(Icons.restaurant_menu),
                        label: Text('Recipes'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Horizontal filter chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        FilterChip(
                          label: const Text('All'),
                          selected: _filters.isEmpty,
                          onSelected: (selected) {
                            setState(() => _filters.clear());
                          },
                        ),
                        const SizedBox(width: 8),
                        ...(_showIngredients
                                ? ['Dairy', 'Grains', 'Protein', 'Vegetables']
                                : ['Breakfast', 'Lunch', 'Dinner', 'Snacks'])
                            .map(
                          (filter) => Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              label: Text(filter),
                              selected: _filters.contains(filter),
                              onSelected: (selected) {
                                setState(() {
                                  if (selected) {
                                    _filters.add(filter);
                                    params =
                                        params.copyWith(categories: _filters);
                                    ref
                                        .read(openFoodFactsParamsProvider
                                            .notifier)
                                        .state = params;
                                  } else {
                                    _filters.remove(filter);
                                    params =
                                        params.copyWith(categories: _filters);
                                    ref
                                        .read(openFoodFactsParamsProvider
                                            .notifier)
                                        .state = params;
                                  }
                                });
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content Grid
          _showIngredients
              ? _buildIngredientsList()
              : _buildRecipesList(ref, context),
        ],
      ),
      floatingActionButton: !_showIngredients
          ? FloatingActionButton.extended(
              onPressed: () => Routemaster.of(context).push('/create-recipe'),
              label: const Text('Add Recipe'),
              icon: const Icon(Icons.add),
              backgroundColor: Colors.green,
            )
          : null,
    );
  }

  Widget _buildIngredientsList() {
    final params = ref.watch(openFoodFactsParamsProvider);
    final asyncIngredients = ref.watch(
      openFoodFactsProvider(
        params,
      ),
    );

    return asyncIngredients.when(
      data: (ingredients) {
        if (ingredients.isEmpty) {
          return const SliverToBoxAdapter(
            child: Center(child: Text('No ingredients found')),
          );
        }
        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: IngredientCard(
                ingredient: ingredients[index],
                imageUrl: ingredients[index].coverImage,
              ),
            ),
            childCount: ingredients.length,
          ),
        );
      },
      loading: () => const SliverToBoxAdapter(
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => SliverToBoxAdapter(
        child: Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildRecipesList(WidgetRef ref, BuildContext context) {
    final asyncRecipes = ref.watch(recipesProvider);

    return asyncRecipes.when(
      data: (recipes) {
        if (recipes.isEmpty) {
          return const SliverToBoxAdapter(
            child: Center(child: Text('No recpies found')),
          );
        }
        final filtered = recipes
            .where((r) =>
                r.title.toLowerCase().contains(_query.toLowerCase()) &&
                (_filters.isEmpty || _filters.contains(r.category)))
            .toList();

        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: RecipeCard(recipe: filtered[index]),
            ),
            childCount: filtered.length,
          ),
        );
      },
      loading: () => const SliverToBoxAdapter(
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => SliverToBoxAdapter(
        child: Center(child: Text('Error: $e')),
      ),
    );
  }
}
