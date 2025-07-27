import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';
import 'package:whatfood/features/auth/controller/auth_controller.dart';
import 'package:whatfood/main.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final auth = ref.read(authControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        leading: IconButton(
            onPressed: () => Routemaster.of(context).push('/private'),
            icon: Icon(Icons.arrow_back)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Settings',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            SwitchListTile(
              title: const Text('Dark Mode'),
              value: themeMode == ThemeMode.dark,
              onChanged: (value) {
                ref.read(themeModeProvider.notifier).state =
                    value ? ThemeMode.dark : ThemeMode.light;
              },
            ),
            ListTile(
              leading: const Icon(Icons.policy),
              title: const Text('Privacy Policy'),
              onTap: () {
                Routemaster.of(context).push('/privacy');
              },
            ),
            const Divider(height: 32),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Log Out'),
              onTap: () async {
                final confirm = await _showConfirmDialog(context,
                    title: 'Log out',
                    message: 'Are you sure you want to log out?');
                if (confirm!) {
                  await auth.logout();
                  //Routemaster.of(context).replace('/login');
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_forever, color: Colors.red),
              title: const Text('Delete Account',
                  style: TextStyle(color: Colors.red)),
              onTap: () async {
                final confirm = await _showConfirmDialog(context,
                    title: 'Delete Account',
                    message:
                        'This action is irreversible. Are you sure you want to delete your account?');
                if (confirm!) {
                  try {
                    await auth.deleteAccount();
                    Routemaster.of(context).replace('/signup');
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error deleting account: $e')));
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<bool?> _showConfirmDialog(BuildContext context,
      {required String title, required String message}) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel')),
          ElevatedButton(
              style:
                  ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Confirm')),
        ],
      ),
    );
  }
}
