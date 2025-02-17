import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';
import 'package:whatfood/core/common/loader.dart';
import 'package:whatfood/features/auth/controller/auth_controller.dart';
import 'package:whatfood/features/preferences/widgets/IntollerancesList.dart';
import 'package:whatfood/features/preferences/controller/preferences_controller.dart';

class PreferencesView extends ConsumerWidget {
  const PreferencesView({super.key, required this.isFromProfile});
  final bool isFromProfile;

  void navigateToHome(BuildContext context) {
    Routemaster.of(context).replace('/home');
  }

  void savePreferences(
      BuildContext context, WidgetRef ref, Set<String> preferences) {
    ref.read(preferencesControllerProvider.notifier).savePreferences(
          context: context,
          preferences: preferences,
        );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);

    if (user == null) {
      return const Scaffold(
        body: Center(child: Loader()),
      );
    }

    final isLoading = ref.watch(preferencesControllerProvider);
    Set<String> intolerances = user.preferences;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('Food Preferences'),
          actions: [
            if (!isFromProfile)
              TextButton(
                onPressed: () => navigateToHome(context),
                child: const Text(
                  'Skip',
                  style: TextStyle(color: Colors.white, fontSize: 15),
                ),
              )
          ],
          backgroundColor: Colors.green,
          elevation: 2,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'What foods can\'t you eat?',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              IntollerancesList(
                intollerances: intolerances,
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : FilledButton(
                    onPressed: () {
                      savePreferences(context, ref, intolerances);
                      if (isFromProfile) {
                        Routemaster.of(context).pop();
                      } else {
                        navigateToHome(context);
                      }
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    child: const Text(
                      'Save',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
