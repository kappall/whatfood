import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';
import 'package:whatfood/features/post/controller/post_controller.dart';
import 'package:whatfood/models/Post.dart';
import 'package:amplify_flutter/amplify_flutter.dart';

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

  void _showAlternativeSheet(String query) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Alternative for "$query"',
                  style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 12),
              const Text('Hamburger'), // placeholder risposta
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                      onPressed: () {}, icon: const Icon(Icons.thumb_up)),
                  IconButton(
                      onPressed: () {}, icon: const Icon(Icons.thumb_down)),
                  IconButton(onPressed: () {}, icon: const Icon(Icons.report)),
                ],
              ),
            ],
          ),
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
          title: const Text('Whatfood'),
          actions: [
            IconButton(
              icon: const Icon(Icons.account_circle),
              onPressed: () => Routemaster.of(context).push('/private'),
            ),
          ],
        ),
        bottomNavigationBar: CupertinoTabBar(
          currentIndex: 0,
          onTap: (i) {},
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(
                icon: Icon(Icons.qr_code_scanner), label: 'Scan'),
            BottomNavigationBarItem(
                icon: Icon(Icons.receipt_long), label: 'Recipes'),
            BottomNavigationBarItem(
                icon: Icon(Icons.shopping_bag_outlined), label: 'Ingredients'),
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

  const _AlternativeSection({required this.controller, required this.onSubmit});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Looking for an alternative to...',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    hintText: 'e.g. Beef',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () {
                  if (controller.text.trim().isNotEmpty) {
                    onSubmit(controller.text.trim());
                  }
                },
              ),
            ],
          ),
        ],
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

class _TrendingIngredientsSection extends StatelessWidget {
  const _TrendingIngredientsSection();

  @override
  Widget build(BuildContext context) {
    final list = [
      {'n': 'Turmeric', 'c': Colors.orangeAccent},
      {'n': 'Quinoa', 'c': Colors.amber},
      {'n': 'Kale', 'c': Colors.teal},
    ];

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
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, i) {
              final item = list[i];
              return Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () {/* TODO */},
                  child: Ink(
                    width: 110,
                    decoration: BoxDecoration(
                      color: (item['c'] as Color).withOpacity(.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: (item['c'] as Color).withOpacity(.3)),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: item['c'] as Color,
                          child: Text(
                            (item['n'] as String)[0],
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(item['n'] as String,
                            style: context.labelLarge
                                ?.copyWith(fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {
              Routemaster.of(context).push('ingredients');
            },
            child: const Text('View all'),
          ),
        ),
      ],
    );
  }
}

class _MealInspirationSection extends StatelessWidget {
  const _MealInspirationSection();

  @override
  Widget build(BuildContext context) {
    final meals = [
      {'t': 'Gnocco Fritto', 'i': '🥟', 'time': '1 h', 'lvl': 'Easy'},
      {'t': 'Frisella', 'i': '🥖', 'time': '10 m', 'lvl': 'Easy'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
          child: Text('Daily Meal Inspiration', style: context.headlineSmall),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Based on your pantry',
            style: context.bodyMedium?.copyWith(color: Colors.grey.shade600),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 140,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: meals.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, i) {
              final m = meals[i];
              return Material(
                borderRadius: BorderRadius.circular(20),
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () {/* TODO */},
                  child: Ink(
                    width: 200,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blueAccent,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(.05),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(m['i']!, style: const TextStyle(fontSize: 28)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                m['t']!,
                                style: context.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w600),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            Icon(Icons.timer,
                                size: 16, color: Colors.grey.shade600),
                            const SizedBox(width: 4),
                            Text(m['time']!, style: context.bodyMedium),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.greenAccent.withOpacity(.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                m['lvl']!,
                                style: context.labelLarge?.copyWith(
                                  color: Colors.green.shade800,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {
              Routemaster.of(context).push('recipes');
            },
            child: const Text('Explore recipes'),
          ),
        ),
      ],
    );
  }
}
