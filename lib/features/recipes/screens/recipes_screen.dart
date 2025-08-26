import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';
import 'package:shimmer/shimmer.dart';
import 'package:whatfood/core/common/error_text.dart';
import 'package:whatfood/core/common/recipe_card.dart';
import 'package:whatfood/features/recipes/controller/recipe_controller.dart';
import 'package:whatfood/l10n/app_localizations.dart';

class RecipesScreen extends ConsumerStatefulWidget {
  const RecipesScreen({super.key});

  @override
  ConsumerState<RecipesScreen> createState() => _RecipesScreenState();
}

class _RecipesScreenState extends ConsumerState<RecipesScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    // TODO
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Material(
        child: Stack(
          children: [
            Column(
              children: [
                _Header(
                    searchCtrl: _searchCtrl,
                    onChanged: (v) => setState(() => _query = v)),
                Expanded(
                  child: _RecipeGrid(
                    query: _query.toLowerCase(),
                  ),
                ),
              ],
            ),
            Positioned(
              bottom: 16 + MediaQuery.of(context).padding.bottom,
              right: 16,
              child: FloatingActionButton(
                heroTag: 'add-recipe-fab',
                shape: const CircleBorder(),
                backgroundColor: Colors.green,
                onPressed: () => Routemaster.of(context).push('/create-recipe'),
                child: const Icon(Icons.add, color: Colors.white, size: 32),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.searchCtrl, required this.onChanged});
  final TextEditingController searchCtrl;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    final l10n = AppLocalizations.of(context)!;
    return Container(
      height: 120 + top,
      padding: EdgeInsets.only(top: top, left: 16, right: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).appBarTheme.backgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.recipesLabel,
            style: Theme.of(context)
                .textTheme
                .headlineLarge
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: searchCtrl,
              decoration: InputDecoration(
                hintText: 'Search recipes...',
                prefixIcon: const Icon(Icons.search),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
              ),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}

class _RecipeGrid extends ConsumerWidget {
  const _RecipeGrid({required this.query});
  final String query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncUserRecipes = ref.watch(recipesProvider);
    final apiRecipes = ref.watch(apiRecipesProvider(query));

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Recipes from other users',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                asyncUserRecipes.when(
                  data: (recipes) {
                    final filtered = recipes
                        .where((r) =>
                            r.title
                                .toLowerCase()
                                .contains(query.toLowerCase()) ||
                            (r.description ?? '')
                                .toLowerCase()
                                .contains(query.toLowerCase()))
                        .toList();

                    if (filtered.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.all(16),
                        child: Text('No matching recipes found.'),
                      );
                    }

                    return SizedBox(
                      height: 250,
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        scrollDirection: Axis.horizontal,
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 16),
                        itemBuilder: (_, i) => GestureDetector(
                          onTap: () {
                            print('User recipe tapped: ${filtered[i].id}');
                            Routemaster.of(context).push(
                                '/recipe-details/${Uri.encodeComponent(filtered[i].id)}');
                          },
                          child: SizedBox(
                            width: 200,
                            child: RecipeCard(recipe: filtered[i]),
                          ),
                        ),
                      ),
                    );
                  },
                  loading: () => const Padding(
                    padding: EdgeInsets.all(16),
                    child: SizedBox(
                      height: 250,
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  ),
                  error: (e, _) => Padding(
                    padding: const EdgeInsets.all(16),
                    child: ErrorText(error: e.toString()),
                  ),
                ),
              ],
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 32, 16, 8),
              child: Text('Suggested Recipes',
                  style: Theme.of(context).textTheme.titleLarge),
            ),
          ),
          apiRecipes.when(
            data: (recipes) {
              if (recipes.isEmpty) {
                return const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('No external recipes found.'),
                  ),
                );
              }
              return SliverToBoxAdapter(
                child: SizedBox(
                  height: 220,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: recipes.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 16),
                    itemBuilder: (context, i) {
                      final recipe = recipes[i];
                      return GestureDetector(
                        onTap: () => Routemaster.of(context).push(
                            '/recipe-details/${Uri.encodeComponent(recipe.id)}'),
                        child: SizedBox(
                          width: 160,
                          child: Material(
                            color: Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    recipe.coverImage,
                                    height: 140,
                                    width: 160,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                      color: Colors.grey,
                                      height: 140,
                                      width: 160,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  recipe.title,
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
            loading: () => const SliverToBoxAdapter(
                child: Center(
                    child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ))),
            error: (e, _) => SliverToBoxAdapter(
                child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text('API error: $e'),
            )),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsetsGeometry.only(bottom: 100),
              child: SizedBox(
                height: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ShimmerGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 220,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.7,
      ),
      itemCount: 6,
      itemBuilder: (_, __) => Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 4 / 3,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 12,
              width: double.infinity,
              color: Colors.white,
              margin: const EdgeInsets.symmetric(vertical: 4),
            ),
            Container(
              height: 12,
              width: 80,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}
