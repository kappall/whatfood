import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';
import 'package:whatfood/features/food/controllers/ingredient_controller.dart';
import 'package:whatfood/features/food/controllers/recipe_controller.dart';
import 'package:whatfood/features/home/utils/alternativeFood_util.dart';
import 'package:whatfood/l10n/app_localizations.dart';

extension AppText on BuildContext {
  TextStyle? get displaySmall => Theme.of(this).textTheme.displaySmall;
  TextStyle? get headlineSmall => Theme.of(this).textTheme.headlineSmall;
  TextStyle? get titleMedium => Theme.of(this).textTheme.titleMedium;
  TextStyle? get bodyMedium => Theme.of(this).textTheme.bodyMedium;
  TextStyle? get labelLarge => Theme.of(this).textTheme.labelLarge;
}

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _searchController = TextEditingController();

  void _showAlternativeSheet(String query) async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return FutureBuilder<List<dynamic>>(
          future: getFoodAlternative(query, null, ref),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Padding(
                padding: const EdgeInsets.all(32.0),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            final alternatives = snapshot.data ?? [];
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Alternative for "$query"',
                      style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 12),
                  if (alternatives.isEmpty)
                    const Text('No alternatives found.')
                  else ...[
                    for (var alt in alternatives)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                alt.name,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                            Text(
                              "${alt.kcal_per_100g.toStringAsFixed(0)} kcal/100g",
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                  ],
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                          onPressed: () {}, icon: const Icon(Icons.thumb_up)),
                      IconButton(
                          onPressed: () {}, icon: const Icon(Icons.thumb_down)),
                      IconButton(
                          onPressed: () {}, icon: const Icon(Icons.report)),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: Image.asset(
            'assets/icons/logo_green.png',
            height: 50,
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.account_circle),
              onPressed: () => Routemaster.of(context).push('/private'),
            ),
          ],
        ),
        body: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: SizedBox(height: 16)),
              SliverToBoxAdapter(
                  child: _AlternativeSection(
                      controller: _searchController,
                      onSubmit: _showAlternativeSheet)),
              SliverToBoxAdapter(child: SizedBox(height: 24)),
              SliverToBoxAdapter(child: _QuickScanSection()),
              SliverToBoxAdapter(child: SizedBox(height: 24)),
              SliverToBoxAdapter(child: _TrendingIngredientsSection()),
              SliverToBoxAdapter(child: SizedBox(height: 24)),
              SliverToBoxAdapter(child: _MealInspirationSection()),
              SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          ),
        ),
      ),
    );
  }
}

class _AlternativeSection extends StatelessWidget {
  final TextEditingController controller;
  final void Function(String) onSubmit;

  const _AlternativeSection({
    required this.controller,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                textAlign: TextAlign.center,
                style:
                    TextStyle(color: Theme.of(context).colorScheme.onSurface),
                decoration: InputDecoration(
                  hintText: 'Digita un prodotto',
                  hintStyle: TextStyle(color: Theme.of(context).hintColor),
                  border: InputBorder.none,
                  isCollapsed: true,
                ),
                onSubmitted: (value) {
                  if (value.trim().isNotEmpty) {
                    onSubmit(value.trim());
                  }
                },
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.search,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              onPressed: () {
                final text = controller.text.trim();
                if (text.isNotEmpty) {
                  onSubmit(text);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickScanSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Quick Scan', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 12),
          Material(
            borderRadius: BorderRadius.circular(20),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => Routemaster.of(context).push('/scan'),
              child: Ink(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.primary.withOpacity(0.8)
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Text('Scan Product',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600)),
                    const Spacer(),
                    const Icon(Icons.qr_code_scanner,
                        color: Colors.white, size: 32),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TrendingIngredientsSection extends ConsumerWidget {
  const _TrendingIngredientsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final asyncIngredients = ref.watch(openFoodFactsProvider(
      const OpenFoodFactsParams(
        sortBy: OpenFoodFactsSort.uniqueScansN,
        limit: 40,
      ),
    ));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
          child: Text('Trending Ingredients', style: context.headlineSmall),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Discover new flavours',
            style: context.bodyMedium?.copyWith(color: Colors.grey.shade600),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 130,
          child: asyncIngredients.when(
            loading: () => Center(child: const CircularProgressIndicator()),
            error: (err, _) => Text('Error: $err'),
            data: (ingredients) {
              debugPrint("recived ingredints: ${ingredients}");
              return ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: min(ingredients.length, 5),
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (_, i) {
                  final ing = ingredients[i];
                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () {
                        Routemaster.of(context).push('/ingredient/${ing.id}');
                      },
                      child: Ink(
                        width: 110,
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: .15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: Colors.green.withValues(alpha: .3)),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (ing.coverImage != null)
                              CircleAvatar(
                                radius: 24,
                                backgroundImage: NetworkImage(ing.coverImage!),
                              )
                            else
                              CircleAvatar(
                                radius: 24,
                                backgroundColor: Colors.green,
                                child: Text(
                                  ing.name[0].toUpperCase(),
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            const SizedBox(height: 8),
                            Text(
                              ing.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: context.labelLarge
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {
              Routemaster.of(context).push('/ingredients');
            },
            child: const Text('View all'),
          ),
        ),
      ],
    );
  }
}

class _MealInspirationSection extends ConsumerWidget {
  const _MealInspirationSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncMeals = ref.watch(
      mealInspirationProvider(MealFilter(mealType: "lunch", maxMinutes: 20)),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
          child: Text('Daily Meal Inspiration', style: context.headlineSmall),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 180,
          child: asyncMeals.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Error loading meal inspiration: $err'),
            ),
            data: (meals) {
              if (meals.isEmpty) {
                return const Center(child: Text("No recipes available yet"));
              }
              return ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: meals.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (_, i) {
                  final m = meals[i];
                  return GestureDetector(
                    onTap: () {
                      // Navigate to recipe details
                    },
                    child: Material(
                      elevation: 3,
                      borderRadius: BorderRadius.circular(20),
                      clipBehavior: Clip.antiAlias,
                      child: Container(
                        width: 200,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.white,
                              Colors.white.withOpacity(0.95),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Cover Image
                            SizedBox(
                              height: 90,
                              child: m.coverImage.isNotEmpty
                                  ? Image.network(
                                      m.coverImage,
                                      fit: BoxFit.cover,
                                    )
                                  : Container(
                                      color: Colors.grey.shade300,
                                      child: const Icon(Icons.fastfood,
                                          size: 40, color: Colors.white70),
                                    ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        m.title,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: context.titleMedium?.copyWith(
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Icon(Icons.timer,
                                            size: 16,
                                            color: Colors.grey.shade600),
                                        const SizedBox(width: 4),
                                        Flexible(
                                          child: Text(
                                            '${m.cookTimeMinutes} min',
                                            style: context.bodyMedium?.copyWith(
                                                color: Colors.grey.shade700),
                                          ),
                                        ),
                                        const Spacer(),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Colors.greenAccent
                                                .withOpacity(.2),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Flexible(
                                            child: Text(
                                              'Easy',
                                              style:
                                                  context.labelLarge?.copyWith(
                                                color: Colors.green.shade800,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
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
            },
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {
              Routemaster.of(context).push('food');
            },
            child: const Text('Explore recipes'),
          ),
        ),
      ],
    );
  }
}
