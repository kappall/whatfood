import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:routemaster/routemaster.dart';
import 'package:whatfood/features/community/screens/community_screen.dart';
import 'package:whatfood/features/home/screens/home_screen.dart';
import 'package:whatfood/features/ingredients/screens/ingredients_screen.dart';
import 'package:whatfood/features/recipes/screens/recipes_screen.dart';
import 'package:whatfood/features/scanner/screens/scan_screen.dart';

class AppScaffold extends StatefulWidget {
  const AppScaffold({super.key});

  static const tabs = [
    '/home',
    '/scan',
    '/community',
    '/recipes',
    '/ingredients',
  ];

  @override
  State<AppScaffold> createState() => _AppScaffoldState();
}

class _AppScaffoldState extends State<AppScaffold> {
  @override
  Widget build(BuildContext context) {
    final tabState = CupertinoTabPage.of(context);
    final currentIndex = tabState.controller.index;

    return CupertinoTabScaffold(
      controller: tabState.controller,
      tabBuilder: (context, index) {
        switch (index) {
          case 0:
            return const HomeScreen();
          case 1:
            return const ScanScreen();
          case 2:
            return const CommunityScreen();
          case 3:
            return const RecipesScreen();
          case 4:
            return const IngredientsScreen();
          default:
            return const Text('Unknown Screen');
        }
      },
      tabBar: CupertinoTabBar(
        currentIndex: currentIndex,
        onTap: (index) {
          Routemaster.of(context).push(AppScaffold.tabs[index]);
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.qr_code_scanner), label: 'Scan'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Community'),
          BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long), label: 'Recipes'),
          BottomNavigationBarItem(
              icon: Icon(Icons.shopping_bag_outlined), label: 'Ingredients'),
        ],
      ),
    );
  }
}
