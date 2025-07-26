import 'package:flutter/material.dart';
import 'package:routemaster/routemaster.dart';
import 'package:whatfood/features/private_area/tabs/diary_tab.dart';
import 'package:whatfood/features/private_area/tabs/profile_tab.dart';
import 'package:whatfood/features/private_area/tabs/stats_tab.dart';

class PrivateAreaScreen extends StatelessWidget {
  const PrivateAreaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Your Area'),
          actions: [
            IconButton(
              onPressed: () => Routemaster.of(context).push('settings'),
              icon: const Icon(Icons.settings_outlined),
            )
          ],
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.person), text: 'Profile'),
              Tab(icon: Icon(Icons.bar_chart), text: 'Stats'),
              Tab(icon: Icon(Icons.calendar_month), text: 'Diary'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            ProfileTab(),
            StatsTab(),
            DiaryTab(),
          ],
        ),
        floatingActionButton: Builder(
          builder: (context) => FloatingActionButton.extended(
            onPressed: () => _openBottomDrawer(context),
            icon: const Icon(Icons.menu),
            label: const Text('More'),
          ),
        ),
      ),
    );
  }

  void _openBottomDrawer(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      showDragHandle: true,
      useSafeArea: true,
      builder: (_) => const _BottomDrawerSheet(),
    );
  }
}

class _BottomDrawerSheet extends StatelessWidget {
  const _BottomDrawerSheet();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.picture_as_pdf),
            title: const Text('Health documents'),
            onTap: () => Routemaster.of(context).push('documents'),
          ),
          ListTile(
            leading: const Icon(Icons.share),
            title: const Text('Share my stats'),
            onTap: () {/* TODO */},
          )
        ],
      ),
    );
  }
}
