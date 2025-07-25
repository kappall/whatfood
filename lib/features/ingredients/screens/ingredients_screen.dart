import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';
import 'package:shimmer/shimmer.dart';
import 'package:whatfood/core/common/error_text.dart';
import 'package:whatfood/core/common/loader.dart';
import 'package:whatfood/features/ingredients/controller/ingredient_controller.dart';
import 'package:whatfood/features/ingredients/widgets/ingredient_card.dart';

class IngredientsScreen extends ConsumerStatefulWidget {
  const IngredientsScreen({super.key});

  @override
  ConsumerState<IngredientsScreen> createState() => _IngredientsScreenState();
}

class _IngredientsScreenState extends ConsumerState<IngredientsScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';
  final List<String> _filters = [];

  @override
  Widget build(BuildContext context) {
    final asyncIng = ref.read(openFoodFactsProvider(
        OpenFoodFactsParams(query: _query, filters: _filters)));

    return Material(
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Stack(
          children: [
            Column(
              children: [
                AppBar(
                  title: const Text('Ingredients'),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.add_box_outlined),
                      onPressed: () => _showSuggestDialog(context),
                      tooltip: 'Suggest Ingredient',
                    ),
                  ],
                ),
                // Search
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: _searchCtrl,
                    decoration: InputDecoration(
                      hintText: 'Search ingredients...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24)),
                    ),
                    onChanged: (v) => setState(() => _query = v.trim()),
                  ),
                ),

                // Filter Chips
                SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: ['Vegan', 'Gluten‑free', 'Keto', 'Paleo']
                        .map((label) => Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: FilterChip(
                                label: Text(label),
                                selected: _filters.contains(label),
                                onSelected: (sel) {
                                  setState(() {
                                    sel
                                        ? _filters.add(label)
                                        : _filters.remove(label);
                                  });
                                },
                              ),
                            ))
                        .toList(),
                  ),
                ),

                const SizedBox(height: 8),

                // Grid
                Expanded(
                  child: asyncIng.when(
                    data: (list) => GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 16,
                              crossAxisSpacing: 16,
                              childAspectRatio: .75),
                      itemCount: list.length,
                      itemBuilder: (_, i) => IngredientCard(
                        ingredient: list[i],
                        imageUrl: 'temp',
                      ),
                    ),
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Center(child: Text('Error: $e')),
                  ),
                ),
              ],
            ),
            Positioned(
              bottom: 16 + MediaQuery.of(context).padding.bottom,
              right: 16,
              child: FloatingActionButton.extended(
                onPressed: () => _showSuggestDialog(context),
                icon: const Icon(Icons.lightbulb_outline),
                label: const Text('Suggest'),
              ),
            )
          ],
        ),
      ),
    );
  }

  void _showSuggestDialog(BuildContext ctx) {
    showDialog(
      context: ctx,
      builder: (_) {
        final ctrl = TextEditingController();
        return AlertDialog(
          title: const Text('Suggest an Ingredient'),
          content: TextField(
              controller: ctrl,
              decoration: const InputDecoration(hintText: 'e.g. Sacha Inchi')),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                // salva su backend Amplify DataStore o semplicemente in un box Hive per moderazione
                Navigator.pop(ctx);
                ScaffoldMessenger.of(ctx).showSnackBar(
                    const SnackBar(content: Text('Suggestion sent!')));
              },
              child: const Text('Send'),
            ),
          ],
        );
      },
    );
  }
}
