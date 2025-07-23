import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';
import 'package:shimmer/shimmer.dart';
import 'package:whatfood/core/common/error_text.dart';
import 'package:whatfood/core/common/loader.dart';
import 'package:whatfood/features/ingredients/controller/ingredient_controller.dart';
import 'package:whatfood/features/ingredients/widgets/ingredient_card.dart';
import 'package:whatfood/models/Ingredient.dart';

class IngredientsScreen extends ConsumerStatefulWidget {
  const IngredientsScreen({super.key});

  @override
  ConsumerState<IngredientsScreen> createState() => _IngredientsScreenState();
}

class _IngredientsScreenState extends ConsumerState<IngredientsScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Stack(
        children: [
          Column(
            children: [
              _Header(
                searchCtrl: _searchCtrl,
                onChanged: (v) => setState(() => _query = v),
              ),
              Expanded(
                child: _IngredientGrid(query: _query),
              ),
            ],
          ),
        ],
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
            color: Colors.black.withValues(alpha: 0.05),
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
                'Ingredients',
                style: Theme.of(context)
                    .textTheme
                    .headlineLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 44,
            child: Material(
              borderRadius: BorderRadius.circular(22),
              child: TextField(
                controller: searchCtrl,
                onChanged: onChanged,
                decoration: InputDecoration(
                  hintText: 'Search ingredients...',
                  prefixIcon: const Icon(Icons.search, size: 24),
                  filled: true,
                  fillColor: Colors.green.withValues(alpha: 0.4),
                  contentPadding: EdgeInsets.zero,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(22),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IngredientGrid extends ConsumerWidget {
  const _IngredientGrid({required this.query});
  final String query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncIngredients = ref.watch(ingredientsProvider);

    return asyncIngredients.when(
      data: (ingredients) {
        final filtered = ingredients
            .where((i) =>
                i.name.toLowerCase().contains(query) ||
                (i.description ?? '').toLowerCase().contains(query))
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
          itemBuilder: (_, i) => _IngredientCard(ingredient: filtered[i]),
        );
      },
      loading: () => const _ShimmerGrid(),
      error: (e, __) => ErrorText(error: e.toString()),
    );
  }
}

class _ShimmerGrid extends StatelessWidget {
  const _ShimmerGrid();

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

class _IngredientCard extends ConsumerWidget {
  const _IngredientCard({required this.ingredient});
  final Ingredient ingredient;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder(
      future: Amplify.Storage.getUrl(
        path: StoragePath.fromString(ingredient.coverImage!),
      ).result,
      builder: (_, snap) {
        final url = snap.hasData ? snap.data!.url.toString() : null;
        return IngredientCard(
          ingredient: ingredient,
          imageUrl: url,
        );
      },
    );
  }
}
