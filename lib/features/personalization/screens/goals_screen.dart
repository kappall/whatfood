import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';
import 'package:whatfood/features/auth/controller/auth_controller.dart';

class GoalsScreen extends ConsumerStatefulWidget {
  const GoalsScreen({super.key});

  @override
  ConsumerState<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends ConsumerState<GoalsScreen> {
  String? _selectedDietaryGoal;
  String? _selectedCookingSkill;
  final List<String> _selectedCookingFor = [];

  final options1 = [
    "Weight Loss",
    "Muscle Gain",
    "Eat Healthier Generally",
    "Manage a specific condition (e.g., Diabetes)"
  ];

  final options2 = [
    "Just myself",
    "Adults",
    "Young Children (1-5 years)",
    "Older Children (6-12 years)",
    "Teenagers",
  ];

  final options3 = [
    "Beginner (I need simple steps)",
    "Intermediate (Comfortable with basics)",
    "Advanced (I love a challenge!)"
  ];

  void _onContinue() {
    final List<String> allPreferences = [];
    if (_selectedDietaryGoal != null) {
      allPreferences.add(_selectedDietaryGoal!);
    }
    if (_selectedCookingSkill != null) {
      allPreferences.add(_selectedCookingSkill!);
    }
    allPreferences.addAll(_selectedCookingFor);

    ref.read(userProvider.notifier).update(
          (state) => state!.copyWith(preferences: allPreferences),
        );
    Routemaster.of(context).push('/personalize/dislikes');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dietary Goals & Lifestyle"),
        actions: [
          TextButton(
            onPressed: () => Routemaster.of(context).replace('/'),
            child: const Text("Skip for now"),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("What's your primary dietary goal?"),
                  ...options1.map((e) => RadioListTile<String>(
                        value: e,
                        groupValue: _selectedDietaryGoal,
                        title: Text(e),
                        onChanged: (String? value) {
                          setState(() {
                            _selectedDietaryGoal = value;
                          });
                        },
                      )),
                ],
              ),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text("Who are you cooking for?"),
                  ...options2.map((e) => CheckboxListTile(
                        value: _selectedCookingFor.contains(e),
                        title: Text(e),
                        onChanged: (_) {
                          setState(() {
                            if (_selectedCookingFor.contains(e)) {
                              _selectedCookingFor.remove(e);
                            } else {
                              _selectedCookingFor.add(e);
                            }
                          });
                        },
                      )),
                ],
              ),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text("What's your cooking skill level?"),
                  ...options3.map((e) => RadioListTile<String>(
                        value: e,
                        groupValue: _selectedCookingSkill,
                        title: Text(e),
                        onChanged: (String? value) {
                          setState(() {
                            _selectedCookingSkill = value;
                          });
                        },
                      )),
                ],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _onContinue,
              child: const Text("Continue"),
            ),
          ],
        ),
      ),
    );
  }
}
