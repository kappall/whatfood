import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';
import 'package:whatfood/features/auth/controller/auth_controller.dart';

class PreferencesScreen extends ConsumerStatefulWidget {
  const PreferencesScreen({super.key});

  @override
  ConsumerState<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends ConsumerState<PreferencesScreen> {
  final List<String> _selected = [];

  final options = [
    "Vegetarian",
    "Vegan",
    "Pescatarian",
    "No Red Meat",
    "Kosher",
    "Halal",
    "Other"
  ];

  void _onContinue() {
    ref.read(userProvider.notifier).update(
          (state) => state!.copyWith(preferences: _selected),
        );
    Routemaster.of(context).push('/personalize/allergies');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Dietary Preferences"),
        actions: [
          TextButton(
            onPressed: () => Routemaster.of(context).replace('/'),
            child: const Text("Skip for now"),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text("Which of these describe your eating habits?"),
          ...options.map((e) => CheckboxListTile(
                value: _selected.contains(e),
                title: Text(e),
                onChanged: (_) {
                  setState(() {
                    if (_selected.contains(e)) {
                      _selected.remove(e);
                    } else {
                      _selected.add(e);
                    }
                  });
                },
              )),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _onContinue,
            child: const Text("Continue"),
          ),
        ],
      ),
    );
  }
}
