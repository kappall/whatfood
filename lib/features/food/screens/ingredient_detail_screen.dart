import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    with TickerProviderStateMixin {
  late final TabController _tabController;
  late final AnimationController _fabController;
  late final AnimationController _headerController;
  late final Animation<double> _fabAnimation;
  late final Animation<double> _headerAnimation;

  final ScrollController _scrollController = ScrollController();
  Ingredient? _ingredient;
  List<Ingredient> _similar = [];
  bool _loading = true;
  bool _isScrolled = false;
  bool _isInCart = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fabController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _headerController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _fabAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fabController, curve: Curves.easeInOut),
    );
    _headerAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _headerController, curve: Curves.easeInOut),
    );

    _scrollController.addListener(_onScroll);
    _fetch();
  }

  void _onScroll() {
    final isScrolled = _scrollController.offset > 200;
    if (isScrolled != _isScrolled) {
      setState(() => _isScrolled = isScrolled);
      if (isScrolled) {
        _headerController.forward();
      } else {
        _headerController.reverse();
      }
    }
  }

  Future<void> _fetch() async {
    try {
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
          debugPrint("new ingredient$_ingredient");
          _similar = simList
              .map((e) => ingredientFromOpenFoodFacts(e))
              .where((e) => e.id != ing.id)
              .take(6)
              .toList();
          _loading = false;
        });
        _fabController.forward();
      }
    } catch (e, s) {
      debugPrint('fetch error: $e\n$s');
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _fabController.dispose();
    _headerController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return _buildSkeleton();
    }

    final ing = _ingredient;
    if (ing == null) {
      return _buildError('Product not found');
    }

    return Theme(
      data: Theme.of(context).copyWith(
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle.light,
        ),
      ),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        floatingActionButton: _FloatingActions(
          ingredient: ing,
          animation: _fabAnimation,
          onAddToCart: () {
            HapticFeedback.mediumImpact();
            setState(() => _isInCart = !_isInCart);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content:
                    Text(_isInCart ? 'Added to cart' : 'Removed from cart'),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          },
          isInCart: _isInCart,
        ),
        body: NestedScrollView(
          controller: _scrollController,
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            _buildSliverHeader(ing),
          ],
          body: SafeArea(
            child: Column(
              children: [
                _buildHealthScoreBar(ing),
                if (_similar.isNotEmpty) _buildSimilarSection(),
                _buildTabs(),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _HealthTab(ing),
                      _HowToUseTab(ing),
                      _WhereToBuyTab(ing),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSliverHeader(Ingredient ingredient) {
    return SliverAppBar(
      expandedHeight: 400,
      floating: false,
      pinned: true,
      stretch: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      leading: AnimatedBuilder(
        animation: _headerAnimation,
        builder: (context, child) {
          return Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _isScrolled
                  ? Theme.of(context).colorScheme.surface.withOpacity(0.9)
                  : Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
              border: _isScrolled
                  ? Border.all(
                      color: Theme.of(context)
                          .colorScheme
                          .outline
                          .withOpacity(0.2))
                  : null,
            ),
            child: IconButton(
              onPressed: () => Routemaster.of(context).pop(),
              icon: Icon(
                Icons.arrow_back_ios_new,
                color: _isScrolled
                    ? Theme.of(context).colorScheme.onSurface
                    : Colors.white,
              ),
            ),
          );
        },
      ),
      actions: [
        AnimatedBuilder(
          animation: _headerAnimation,
          builder: (context, child) {
            return Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _isScrolled
                    ? Theme.of(context).colorScheme.surface.withOpacity(0.9)
                    : Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
                border: _isScrolled
                    ? Border.all(
                        color: Theme.of(context)
                            .colorScheme
                            .outline
                            .withOpacity(0.2))
                    : null,
              ),
              child: IconButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  // Share functionality
                },
                icon: Icon(
                  Icons.share_outlined,
                  color: _isScrolled
                      ? Theme.of(context).colorScheme.onSurface
                      : Colors.white,
                ),
              ),
            );
          },
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [
          StretchMode.zoomBackground,
          StretchMode.blurBackground,
        ],
        background: Stack(
          fit: StackFit.expand,
          children: [
            Hero(
              tag: 'ingredient-${widget.id}',
              child: Container(
                decoration: BoxDecoration(
                  image: ingredient.coverImage != null
                      ? DecorationImage(
                          image: NetworkImage(ingredient.coverImage!),
                          fit: BoxFit.cover,
                          onError: (_, __) {},
                        )
                      : null,
                ),
                child: ingredient.coverImage == null
                    ? Container(
                        color: Theme.of(context).colorScheme.surfaceVariant,
                        child: Icon(
                          Icons.eco_outlined,
                          size: 80,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurfaceVariant
                              .withOpacity(0.5),
                        ),
                      )
                    : null,
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.transparent,
                    Colors.black.withOpacity(0.3),
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 24,
              right: 24,
              bottom: 80,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .secondary
                          .withOpacity(0.9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'INGREDIENT',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSecondary,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    ingredient.name,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthScoreBar(Ingredient ingredient) {
    final healthScore = ingredient.healthScore ?? 0;
    final scoreColor = healthScore >= 70
        ? Colors.green
        : healthScore >= 40
            ? Colors.orange
            : Colors.red;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            scoreColor.withOpacity(0.1),
            scoreColor.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: scoreColor.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.health_and_safety_outlined,
                color: scoreColor,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Health Score',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      '$healthScore/100',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: scoreColor,
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: healthScore / 100,
              minHeight: 12,
              backgroundColor: scoreColor.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimilarSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Row(
            children: [
              Icon(
                Icons.flight_class_outlined,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Similar Products',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 140,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: _similar.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, i) {
              final similar = _similar[i];
              return GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => IngredientDetailScreen(id: similar.id),
                    ),
                  );
                },
                child: Container(
                  width: 100,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(16),
                          ),
                          child: Image.network(
                            similar.coverImage ?? "",
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color:
                                  Theme.of(context).colorScheme.surfaceVariant,
                              child: Icon(
                                Icons.eco_outlined,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text(
                          similar.name,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildTabs() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest
            .withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(12),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: Theme.of(context).colorScheme.onPrimary,
        unselectedLabelColor: Theme.of(context).colorScheme.onSurfaceVariant,
        labelStyle: const TextStyle(fontWeight: FontWeight.w600),
        tabs: const [
          Tab(text: 'Nutrition'),
          Tab(text: 'Usage Tips'),
          Tab(text: 'Buy'),
        ],
      ),
    );
  }

  Widget _buildSkeleton() {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 400,
            backgroundColor: Colors.grey.shade300,
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                for (int i = 0; i < 5; i++) ...[
                  Container(
                    height: 20,
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(String msg) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              msg,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _FloatingActions extends StatelessWidget {
  final Ingredient ingredient;
  final Animation<double> animation;
  final VoidCallback onAddToCart;
  final bool isInCart;

  const _FloatingActions({
    required this.ingredient,
    required this.animation,
    required this.onAddToCart,
    required this.isInCart,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.scale(
          scale: animation.value,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FloatingActionButton.small(
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  _showNutritionDetails(context);
                },
                backgroundColor:
                    Theme.of(context).colorScheme.secondaryContainer,
                foregroundColor:
                    Theme.of(context).colorScheme.onSecondaryContainer,
                child: const Icon(Icons.analytics_outlined),
              ),
              const SizedBox(height: 12),
              FloatingActionButton.extended(
                onPressed: onAddToCart,
                backgroundColor: isInCart
                    ? Theme.of(context).colorScheme.tertiary
                    : Theme.of(context).colorScheme.primary,
                foregroundColor: isInCart
                    ? Theme.of(context).colorScheme.onTertiary
                    : Theme.of(context).colorScheme.onPrimary,
                icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    isInCart
                        ? Icons.shopping_cart
                        : Icons.add_shopping_cart_outlined,
                    key: ValueKey(isInCart),
                  ),
                ),
                label: Text(isInCart ? 'In Cart' : 'Add to Cart'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showNutritionDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.8,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Icon(
                      Icons.analytics_outlined,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Detailed Nutrition',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _NutritionTable(ingredient),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HealthTab extends StatelessWidget {
  final Ingredient ingredient;
  const _HealthTab(this.ingredient);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Nutritional Information',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 20),
          _NutritionTable(ingredient),
        ],
      ),
    );
  }
}

class _NutritionTable extends StatelessWidget {
  final Ingredient ingredient;
  const _NutritionTable(this.ingredient);

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> nutrition = Map<String, dynamic>.from(
        jsonDecode(ingredient.nutritionPer100g ?? "{}"));

    final nutrients = [
      _NutrientData('Energy', '${nutrition['energyKcal'] ?? '-'} kcal',
          Icons.flash_on, Colors.orange),
      _NutrientData('Proteins', '${nutrition['proteins'] ?? '-'} g',
          Icons.fitness_center, Colors.red),
      _NutrientData('Carbohydrates', '${nutrition['carbs'] ?? '-'} g',
          Icons.grain, Colors.amber),
      _NutrientData(
          'Fat', '${nutrition['fat'] ?? '-'} g', Icons.opacity, Colors.yellow),
      _NutrientData(
          'Fiber', '${nutrition['fiber'] ?? '-'} g', Icons.eco, Colors.green),
      _NutrientData(
          'Sugar', '${nutrition['sugars'] ?? '-'} g', Icons.cake, Colors.pink),
    ];

    return Column(
      children: nutrients
          .map((nutrient) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: nutrient.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: nutrient.color.withOpacity(0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: nutrient.color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(
                        nutrient.icon,
                        color: nutrient.color,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        nutrient.name,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                      ),
                    ),
                    Text(
                      nutrient.value,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: nutrient.color,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
              ))
          .toList(),
    );
  }
}

class _NutrientData {
  final String name;
  final String value;
  final IconData icon;
  final Color color;

  const _NutrientData(this.name, this.value, this.icon, this.color);
}

class _HowToUseTab extends StatelessWidget {
  final Ingredient ingredient;
  const _HowToUseTab(this.ingredient);

  @override
  Widget build(BuildContext context) {
    if (ingredient.tips.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.tips_and_updates_outlined,
              size: 64,
              color: Theme.of(context)
                  .colorScheme
                  .onSurfaceVariant
                  .withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No usage tips available',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: ingredient.tips.length,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
                Theme.of(context)
                    .colorScheme
                    .secondaryContainer
                    .withOpacity(0.3),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  Icons.lightbulb_outline,
                  color: Theme.of(context).colorScheme.onPrimary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  ingredient.tips[index],
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        height: 1.5,
                      ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _WhereToBuyTab extends StatelessWidget {
  final Ingredient ingredient;
  const _WhereToBuyTab(this.ingredient);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
          24, 24, 24, 100), // Extra bottom padding for FAB
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
                Theme.of(context)
                    .colorScheme
                    .tertiaryContainer
                    .withOpacity(0.3),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.store_outlined,
                size: 64,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'Store Locations',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Find where to buy this ingredient near you',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  // TODO: Implement store locator
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Store locator coming soon!'),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.location_on_outlined),
                label: const Text('Find Stores'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
