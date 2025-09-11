import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:routemaster/routemaster.dart';
import 'package:whatfood/features/food/screens/food_screen.dart';
import 'package:whatfood/features/home/screens/home_screen.dart';
import 'package:whatfood/features/map/screens/map_screen.dart';
import 'package:whatfood/features/scanner/screens/scan_screen.dart';
import 'package:whatfood/l10n/app_localizations.dart';

class AppScaffold extends StatefulWidget {
  const AppScaffold({super.key});

  static const tabs = [
    '/home',
    '/scan',
    '/food',
    '/map',
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
            return const FoodScreen();
          case 3:
            return const MapScreen();
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
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
        items: List.generate(4, (index) {
          final icons = [
            Icons.home,
            Icons.qr_code_scanner,
            Icons.local_dining,
            Icons.map,
          ];
          final labels = [
            'Home',
            'Scanner',
            l10n.recipesLabel,
            'Map'
          ]; // TODO: change labels intenational

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
                      fontWeight: index == currentIndex
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: index == currentIndex
                          ? Theme.of(context).colorScheme.onPrimaryContainer
                          : Theme.of(context).colorScheme.onPrimaryContainer),
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
        color: isActive
            ? Theme.of(context).colorScheme.onSurface
            : Theme.of(context).colorScheme.onInverseSurface,
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
        color: isActive
            ? Theme.of(context).colorScheme.onPrimary
            : Theme.of(context).colorScheme.onSurface,
      ),
    );
  }
}
