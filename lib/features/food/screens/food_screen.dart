import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';
import 'package:whatfood/core/common/recipe_card.dart';
import 'package:whatfood/features/food/widgets/ingredient_card.dart';
import 'package:whatfood/features/food/controllers/recipe_controller.dart';
import 'package:whatfood/features/food/controllers/ingredient_controller.dart';
import 'package:whatfood/l10n/app_localizations.dart';
import 'package:whatfood/models/Recipe.dart';

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
            expandedHeight: 60,
            floating: true,
            pinned: true,
            title: Text(
              'Discover Food',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            backgroundColor: Theme.of(context).primaryColor,
          ),

          SliverToBoxAdapter(
            child: Container(
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
              padding: const EdgeInsets.all(16),
              child: TextField(
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
                        if (!_showIngredients) {
                          _filters.clear();
                        }
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
              : _buildRecipesList(ref, context, _query),
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

  Widget _buildRecipesList(WidgetRef ref, BuildContext context, String query) {
    final asyncRecipes = ref.watch(recipesProvider);
    final apiRecipes = ref.watch(apiRecipesProvider(query));

    return asyncRecipes.when(
      data: (localRecipes) {
        return apiRecipes.when(
          data: (remoteRecipes) {
            // Combine local and API recipes
            final allRecipes = <Recipe>[...localRecipes, ...remoteRecipes];

            if (allRecipes.isEmpty) {
              return const SliverToBoxAdapter(
                child: Center(child: Text('No recipes found')),
              );
            }

            // Apply filters using _query and _filters from the class
            final filtered = allRecipes
                .where((r) =>
                    r.title.toLowerCase().contains(_query.toLowerCase()) &&
                    (_filters.isEmpty || _filters.contains(r.category)))
                .toList();

            if (filtered.isEmpty) {
              return const SliverToBoxAdapter(
                child: Center(child: Text('No recipes match your criteria')),
              );
            }

            return SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final recipe = filtered[index];
                  final isFromApi = remoteRecipes.contains(recipe);

                  return Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: RecipeCard(
                      recipe: recipe,
                      // Optional: Add a subtle indicator for API recipes
                      // You can modify RecipeCard to accept this parameter
                    ),
                  );
                },
                childCount: filtered.length,
              ),
            );
          },
          loading: () {
            // Show local recipes while API loads
            if (localRecipes.isEmpty) {
              return const SliverToBoxAdapter(
                child: Center(child: CircularProgressIndicator()),
              );
            }

            final filtered = localRecipes
                .where((r) =>
                    r.title.toLowerCase().contains(_query.toLowerCase()) &&
                    (_filters.isEmpty || _filters.contains(r.category)))
                .toList();

            if (filtered.isEmpty) {
              return const SliverToBoxAdapter(
                child: Center(child: CircularProgressIndicator()),
              );
            }

            return SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    children: [
                      if (index == 0) // Show loading indicator at top
                        Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .primaryColor
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Theme.of(context)
                                  .primaryColor
                                  .withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Loading more recipes...',
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      RecipeCard(recipe: filtered[index]),
                    ],
                  ),
                ),
                childCount: filtered.length,
              ),
            );
          },
          error: (apiError, _) {
            // Show local recipes even if API fails
            final filtered = localRecipes
                .where((r) =>
                    r.title.toLowerCase().contains(_query.toLowerCase()) &&
                    (_filters.isEmpty || _filters.contains(r.category)))
                .toList();

            if (filtered.isEmpty) {
              return const SliverToBoxAdapter(
                child: Center(child: Text('No recipes found')),
              );
            }

            return SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    children: [
                      if (index == 0) // Show warning message at top
                        Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.orange.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.orange.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.warning_amber_rounded,
                                color: Colors.orange.shade700,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Could not load online recipes. Showing local recipes only.',
                                  style: TextStyle(
                                    color: Colors.orange.shade700,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      RecipeCard(recipe: filtered[index]),
                    ],
                  ),
                ),
                childCount: filtered.length,
              ),
            );
          },
        );
      },
      loading: () => const SliverToBoxAdapter(
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (localError, _) {
        // If local recipes fail, try to show API recipes only
        return apiRecipes.when(
          data: (remoteRecipes) {
            final filtered = remoteRecipes
                .where((r) =>
                    r.title.toLowerCase().contains(_query.toLowerCase()) &&
                    (_filters.isEmpty || _filters.contains(r.category)))
                .toList();

            if (filtered.isEmpty) {
              return const SliverToBoxAdapter(
                child: Center(child: Text('No recipes found')),
              );
            }

            return SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    children: [
                      if (index == 0)
                        Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.blue.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.cloud_outlined,
                                color: Colors.blue.shade700,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Showing online recipes only.',
                                  style: TextStyle(
                                    color: Colors.blue.shade700,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      RecipeCard(recipe: filtered[index]),
                    ],
                  ),
                ),
                childCount: filtered.length,
              ),
            );
          },
          loading: () => const SliverToBoxAdapter(
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (apiError, _) => SliverToBoxAdapter(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline_rounded,
                    size: 64,
                    color: Colors.red.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Unable to load recipes',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Please check your connection and try again',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      ref.invalidate(recipesProvider);
                      ref.invalidate(apiRecipesProvider(query));
                    },
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Retry'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
