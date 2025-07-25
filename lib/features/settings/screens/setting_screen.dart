import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';
import 'package:whatfood/main.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Provider che gestisce ThemeMode
    final themeMode = ref.watch(themeModeProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text("Setting"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Settings',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),

          // Tema chiaro/scuro
          SwitchListTile(
            title: const Text('Dark Mode'),
            value: themeMode == ThemeMode.dark,
            onChanged: (value) {
              ref.read(themeModeProvider.notifier).state =
                  value ? ThemeMode.dark : ThemeMode.light;
            },
          ),

          // Privacy Policy
          ListTile(
            leading: const Icon(Icons.policy),
            title: const Text('Privacy Policy'),
            onTap: () {
              Routemaster.of(context).push('/privacy');
            },
          ),
        ]),
      ),
    );
  }
}
