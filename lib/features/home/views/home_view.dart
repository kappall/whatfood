import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatfood/features/auth/controller/auth_controller.dart';
import 'package:whatfood/features/home/views/for_you_view.dart';
import 'package:whatfood/features/home/widgets/add_post_modal.dart';
import 'package:whatfood/features/post/controller/post_controller.dart';
import 'package:whatfood/models/MealType.dart';
import 'package:whatfood/models/User.dart';

class HomeView extends ConsumerStatefulWidget {
  const HomeView({super.key});

  @override
  ConsumerState<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends ConsumerState<HomeView>
    with SingleTickerProviderStateMixin {
  late User userModel;
  late TabController _tabController;
  late PageController _pageController;
  bool _mounted = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _pageController = PageController();
    _tabController.addListener(_handleTabChange);
    userModel = ref.read(userProvider)!;
  }

  void _handleTabChange() {
    if (_mounted) {
      setState(() {
        _pageController.animateToPage(
          _tabController.index,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      });
    }
  }

  @override
  void dispose() {
    _mounted = false;
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _showFilterMenu(BuildContext context) {
    final currentFilter = ref.read(mealFilterProvider);

    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(0, 80, 0, 0),
      items: [
        PopupMenuItem<MealType?>(
          value: null,
          child: Row(
            children: [
              Icon(
                Icons.clear_all,
                color: currentFilter == null ? Colors.green : null,
              ),
              const SizedBox(width: 8),
              Text(
                'All Posts',
                style: TextStyle(
                  fontWeight: currentFilter == null
                      ? FontWeight.bold
                      : FontWeight.normal,
                  color: currentFilter == null ? Colors.green : null,
                ),
              ),
            ],
          ),
        ),
        ...MealType.values.map(
          (type) => PopupMenuItem<MealType?>(
            value: type,
            child: Row(
              children: [
                Icon(
                  _getMealTypeIcon(type),
                  color: currentFilter == type ? Colors.green : null,
                ),
                const SizedBox(width: 8),
                Text(
                  type.name,
                  style: TextStyle(
                    fontWeight: currentFilter == type
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: currentFilter == type ? Colors.green : null,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ).then((selectedType) {
      ref.read(mealFilterProvider.notifier).state = selectedType;
    });
  }

  IconData _getMealTypeIcon(MealType type) {
    switch (type) {
      case MealType.BREAKFAST:
        return Icons.breakfast_dining;
      case MealType.LUNCH:
        return Icons.lunch_dining;
      case MealType.DINNER:
        return Icons.dinner_dining;
      case MealType.SNACK:
        return Icons.cookie;
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedFilter = ref.watch(mealFilterProvider);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50),
        child: AppBar(
          backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
          iconTheme: Theme.of(context).iconTheme,
          titleTextStyle: Theme.of(context).textTheme.headlineMedium,
          bottom: TabBar(
            splashFactory: NoSplash.splashFactory,
            labelColor: Theme.of(context).textTheme.bodyLarge?.color,
            controller: _tabController,
            indicatorColor: Colors.transparent,
            tabs: [
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () => _showFilterMenu(context),
                      icon: Icon(
                        Icons.filter_list,
                        color: selectedFilter != null ? Colors.green : null,
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        "For You",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _tabController.index == 0
                              ? Theme.of(context).textTheme.bodyLarge?.color
                              : Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Inspiration",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _tabController.index == 1
                              ? Theme.of(context).textTheme.bodyLarge?.color
                              : Colors.grey,
                        ),
                      ),
                    ), /*
                    IconButton(
                      onPressed: () => themeNotifier.toggleTheme(),
                      icon: Icon(
                        Icons.brightness_6,
                      ),
                    )*/
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: PageView(
        controller: _pageController,
        scrollDirection: Axis.horizontal,
        physics: const PageScrollPhysics(),
        onPageChanged: (index) {
          if (_mounted) {
            _tabController.animateTo(index);
          }
        },
        children: const [
          ForYouView(),
          Center(child: Text('Inspiration Page')),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        shape: CircleBorder(),
        onPressed: () async {
          await showModalBottomSheet(
            context: context,
            isScrollControlled: false,
            useSafeArea: true,
            backgroundColor: Colors.transparent,
            builder: (context) => AddPostModal(),
          );
        },
        backgroundColor: Colors.green,
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 40,
        ),
      ),
    );
  }
}
