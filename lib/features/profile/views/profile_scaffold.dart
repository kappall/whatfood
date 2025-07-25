import 'dart:convert';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';
import 'package:shimmer/shimmer.dart';
import 'package:whatfood/core/common/error_text.dart';
import 'package:whatfood/core/common/loader.dart';
import 'package:whatfood/features/auth/controller/auth_controller.dart';
import 'package:whatfood/features/profile/controller/user_profile_controller.dart';
import 'package:whatfood/features/profile/views/profile_view.dart';
import 'package:whatfood/models/Post.dart';
import 'package:whatfood/models/User.dart';

class ProfileScaffold extends ConsumerWidget {
  const ProfileScaffold({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider)!;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Profile'),
          centerTitle: true,
          leading: Builder(
            builder: (ctx) => IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(ctx).openDrawer(),
            ),
          ),
        ),
        drawer: _ProfileDrawer(),
        body: const ProfileScreen(), // reuse the same UI
      ),
    );
  }
}

class _ProfileDrawer extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.primary.withOpacity(.7),
                ],
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundImage:
                      NetworkImage(ref.read(userProvider)!.profilePic),
                  radius: 28,
                ),
                const SizedBox(height: 8),
                Text(ref.read(userProvider)!.name,
                    style: const TextStyle(color: Colors.white)),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Preferences'),
            onTap: () {
              Routemaster.of(context).push('preferences');
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Log out'),
            onTap: () => _logoutConfirm(context, ref),
          ),
        ],
      ),
    );
  }

  void _logoutConfirm(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Log out'),
        content: const Text('Are you sure?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
    if (ok == true) {
      Navigator.pop(context); // close drawer
      ref.read(userProfileControllerProvider.notifier).logout();
    }
  }
}
