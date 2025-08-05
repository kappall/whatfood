import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:routemaster/routemaster.dart';
import 'package:whatfood/features/home/screens/home_screen.dart';
import 'package:whatfood/features/ingredients/screens/ingredients_screen.dart';
import 'package:whatfood/features/recipes/screens/recipes_screen.dart';
import 'package:whatfood/features/scanner/screens/scan_screen.dart';
import 'package:whatfood/l10n/app_localizations.dart';

class AppScaffold extends StatefulWidget {
  const AppScaffold({super.key});

  static const tabs = [
    '/home',
    '/scan',
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
    final l10n = AppLocalizations.of(context)!;

    return CupertinoTabScaffold(
      controller: tabState.controller,
      tabBuilder: (context, index) {
        switch (index) {
          case 0:
            return const HomeScreen();
          case 1:
            return const ScanScreen();
          case 2:
            return const RecipesScreen();
          case 3:
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
        height: 70,
        backgroundColor: Colors.white.withValues(alpha: 0.7),
        items: List.generate(4, (index) {
          final icons = [
            Icons.home,
            Icons.qr_code_scanner,
            Icons.receipt_long,
            Icons.shopping_bag_outlined,
          ];
          final labels = [
            'Home',
            'Scanner',
            l10n.recipesLabel,
            l10n.ingredientsLabel
          ];

          return BottomNavigationBarItem(
            icon: Column(
              children: [
                _CircleIcon(
                    icon: icons[index], isActive: index == currentIndex),
                const SizedBox(
                  height: 2,
                ),
                Text(
                  labels[index],
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color:
                          index == currentIndex ? Colors.black : Colors.grey),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _CircleIcon extends StatelessWidget {
  final IconData icon;
  final bool isActive;

  const _CircleIcon({required this.icon, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 50,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive ? Colors.black : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Icon(
        icon,
        size: 22,
        color: isActive ? Colors.white : Colors.black,
      ),
    );
  }
}
