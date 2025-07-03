import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';
import 'package:whatfood/features/auth/controller/auth_controller.dart';

class AllergiesScreen extends ConsumerStatefulWidget {
  const AllergiesScreen({super.key});

  @override
  ConsumerState<AllergiesScreen> createState() => _AllergiesScreenState();
}

class _AllergiesScreenState extends ConsumerState<AllergiesScreen> {
  final List<String> _selected = [];

  final options = [
    "Gluten",
    "Lactose / Diary",
    "Nuts (Peanuts, Tree Nuts)",
    "Eggs",
    "Soy",
    "Shellfish",
    "Fish",
    "Other"
  ];

  void _onContinue() {
    ref.read(userProvider.notifier).update(
          (state) => state!.copyWith(allergies: _selected),
        );
    Routemaster.of(context).push('/personalize/goals');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Allergies & Intolerances"),
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
          const Text("Please select any ingredients you must avoid:"),
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
