import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';
import 'package:whatfood/features/food/controllers/recipe_controller.dart';
import 'package:whatfood/models/Recipe.dart';

class RecipeDetailPage extends ConsumerStatefulWidget {
  final String recipeId;
  const RecipeDetailPage({super.key, required this.recipeId});

  @override
  ConsumerState<RecipeDetailPage> createState() => _RecipeDetailPageState();
}

class _RecipeDetailPageState extends ConsumerState<RecipeDetailPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  int _servings = 1;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final recipeAsync = ref.watch(recipeByIdProvider(widget.recipeId));

    return recipeAsync.when(
      loading: () => _buildSkeleton(),
      error: (e, _) => _buildError(e.toString()),
      data: (recipe) {
        if (recipe == null) return _buildError('Recipe not found');
        _servings = int.tryParse(recipe.servings ?? '1') ?? 1;

        return Scaffold(
          extendBodyBehindAppBar: true,
          floatingActionButton: _FloatingMenu(recipe: recipe),
          body: SafeArea(
            top: false,
            child: CustomScrollView(
              slivers: [
                _buildSliverHeader(recipe),
                _buildActionChips(),
                _buildSliverTabs(),
                SliverFillRemaining(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _Overview(recipe: recipe, servings: _servings),
                      _Instructions(recipe: recipe),
                      _Nutrition(recipe: recipe),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSliverHeader(Recipe recipe) => SliverAppBar(
        pinned: true,
        stretch: true,
        collapsedHeight: 72,
        expandedHeight: 320,
        leading: Center(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: CircleAvatar(
              backgroundColor: Colors.black26,
              child: BackButton(color: Colors.white),
            ),
          ),
        ),
        flexibleSpace: FlexibleSpaceBar(
          stretchModes: [StretchMode.blurBackground],
          titlePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          title: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              recipe.title ?? 'Recipe',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(color: Colors.white),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          background: Hero(
            tag: 'recipe-${widget.recipeId}',
            child: Image.network(
              recipe.coverImage ?? '',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  ColoredBox(color: Colors.grey[300]!),
            ),
          ),
        ),
      );

  Widget _buildActionChips() => SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
          child: Wrap(
            spacing: 8,
            alignment: WrapAlignment.center,
            children: [
              ActionChip(
                label: const Text('Save'),
                avatar: const Icon(Icons.bookmark_outline, size: 18),
                onPressed: () {},
              ),
              ActionChip(
                label: const Text('Share'),
                avatar: const Icon(Icons.share, size: 18),
                onPressed: () {},
              ),
              ActionChip(
                label: const Text('Comment'),
                avatar: const Icon(Icons.comment, size: 18),
                onPressed: () {},
              ),
            ],
          ),
        ),
      );

  Widget _buildSliverTabs() => SliverPersistentHeader(
        pinned: true,
        delegate: _TabDelegate(
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(icon: Icon(Icons.info_outline), text: 'Overview'),
              Tab(icon: Icon(Icons.list_alt), text: 'Instructions'),
              Tab(icon: Icon(Icons.health_and_safety), text: 'Nutrition'),
            ],
          ),
        ),
      );

  Widget _buildSkeleton() => const Scaffold(
        body: Center(child: CircularProgressIndicator.adaptive()),
      );

  Widget _buildError(String msg) => Scaffold(
        body: Center(
          child: Text(msg, style: Theme.of(context).textTheme.titleMedium),
        ),
      );
}

class _Overview extends StatefulWidget {
  final Recipe recipe;
  final int servings;
  const _Overview({required this.recipe, required this.servings});

  @override
  State<_Overview> createState() => _OverviewState();
}

class _OverviewState extends State<_Overview> {
  late int _servings;
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _servings = widget.servings;
    _controller = TextEditingController(text: _servings.toString());
  }

  void _updateServings(int newServings) {
    final clamped = newServings.clamp(1, 12);
    setState(() {
      _servings = clamped;
      _controller.text = clamped.toString();
      _controller.selection = TextSelection.fromPosition(
          TextPosition(offset: _controller.text.length));
    });
  }

  @override
  Widget build(BuildContext context) {
    final scale =
        _servings / (int.tryParse(widget.recipe.servings ?? '1') ?? 1);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.recipe.description != null) ...[
                  Text(widget.recipe.description!,
                      style: Theme.of(context).textTheme.bodyLarge),
                  const SizedBox(height: 24),
                ],
                Text('Servings',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: () => _updateServings(_servings - 1),
                    ),
                    SizedBox(
                      width: 50,
                      child: TextField(
                        controller: _controller,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 8),
                        ),
                        onChanged: (value) {
                          final parsed = int.tryParse(value);
                          if (parsed != null) {
                            _updateServings(parsed);
                          }
                        },
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () => _updateServings(_servings + 1),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text('Ingredients',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 12),
                ...?widget.recipe.ingredients?.map((e) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text('• ${e.name.trim()}',
                          style: Theme.of(context).textTheme.bodyLarge),
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Instructions extends StatelessWidget {
  final Recipe recipe;
  const _Instructions({required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const ClampingScrollPhysics(),
            itemCount: recipe.instructions?.length ?? 0,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (_, i) => Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor:
                      Theme.of(context).colorScheme.primaryContainer,
                  child: Text('${i + 1}',
                      style: Theme.of(context).textTheme.labelSmall),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(recipe.instructions![i],
                      style: Theme.of(context).textTheme.bodyLarge),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Nutrition extends StatelessWidget {
  final Recipe recipe;
  const _Nutrition({required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Card(
            elevation: 0,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Health Score',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 12),
                  Text('--', style: Theme.of(context).textTheme.displaySmall),
                  const SizedBox(height: 24),
                  Table(
                    border: TableBorder.all(color: Colors.transparent),
                    children: [
                      _row('Calories', '-- kcal'),
                      _row('Protein', '-- g'),
                      _row('Carbs', '-- g'),
                      _row('Fat', '-- g'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  TableRow _row(String label, String value) => TableRow(children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text(label),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text(value, textAlign: TextAlign.end),
        ),
      ]);
}

class _FloatingMenu extends StatelessWidget {
  final Recipe recipe;
  const _FloatingMenu({required this.recipe});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.small(
      onPressed: () => _showMenu(context),
      child: const Icon(Icons.more_horiz),
    );
  }

  void _showMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Edit'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.flag_outlined),
              title: const Text('Report'),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}

class _TabDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;
  _TabDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height + 8;
  @override
  double get maxExtent => _tabBar.preferredSize.height + 8;

  @override
  Widget build(_, __, ___) {
    return Container(
      color: Colors.transparent,
      alignment: Alignment.center,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_) => false;
}
