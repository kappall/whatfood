import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';
import 'package:shimmer/shimmer.dart';
import 'package:whatfood/core/common/error_text.dart';
import 'package:whatfood/core/common/recipe_card.dart';
import 'package:whatfood/features/recipes/controller/recipe_controller.dart';

class RecipesScreen extends ConsumerStatefulWidget {
  const RecipesScreen({super.key});

  @override
  ConsumerState<RecipesScreen> createState() => _RecipesScreenState();
}

class _RecipesScreenState extends ConsumerState<RecipesScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _query = '';
  Timer? _debounce;

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
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: _searchCtrl,
                    decoration: InputDecoration(
                      hintText: 'Search recipes...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24)),
                    ),
                    onChanged: (v) {
                      setState(() => _query = v);
                      _debounce?.cancel();
                      _debounce =
                          Timer(const Duration(milliseconds: 500), _search);
                    },
                  ),
                ),
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
    return Container(
      height: 110 + top,
      padding: EdgeInsets.only(top: top, left: 16, right: 16, bottom: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).appBarTheme.backgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Row(
            children: [
              Text(
                'Recipes',
                style: Theme.of(context)
                    .textTheme
                    .headlineLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const Spacer(),
            ],
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
    final asyncRecipes = ref.watch(recipesProvider);

    return asyncRecipes.when(
      data: (recipes) {
        final filtered = recipes
            .where((r) =>
                r.title.toLowerCase().contains(query) ||
                (r.description ?? '').toLowerCase().contains(query))
            .toList();

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: .75,
          ),
          itemCount: filtered.length,
          itemBuilder: (_, i) => RecipeCard(recipe: filtered[i]),
        );
      },
      loading: () => ShimmerGrid(),
      error: (e, __) => ErrorText(error: e.toString()),
    );
  }
}

class ShimmerGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: .75,
      ),
      itemCount: 6,
      itemBuilder: (_, __) => Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}
