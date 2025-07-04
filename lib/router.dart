import 'package:flutter/material.dart';
import 'package:routemaster/routemaster.dart';
import 'package:whatfood/features/auth/screens/login_screen.dart';
import 'package:whatfood/features/auth/screens/signup_screen.dart';
import 'package:whatfood/features/onboarding/screens/onboarding_screen.dart';
import 'package:whatfood/features/personalization/screens/allergies_screen.dart';
import 'package:whatfood/features/personalization/screens/dislikes_screen.dart';
import 'package:whatfood/features/personalization/screens/goals_screen.dart';
import 'package:whatfood/features/personalization/screens/preferences_screen.dart';
import 'package:whatfood/pages/app_scaffold.dart';

final loggedOutRoutes = RouteMap(
  routes: {
    '/': (_) => const MaterialPage(child: LoginScreen()),
    '/onboarding': (_) => const MaterialPage(child: OnboardingScreen()),
    '/signup': (_) => const MaterialPage(child: SignupScreen()),
  },
);

final loggedInRoutes = RouteMap(routes: {
  '/': (_) => const MaterialPage(child: AppScaffold()),
  '/onboarding': (_) => const MaterialPage(child: OnboardingScreen()),
  '/personalize/preferences': (_) =>
      const MaterialPage(child: PreferencesScreen()),
  '/personalize/allergies': (_) => const MaterialPage(child: AllergiesScreen()),
  '/personalize/goals': (_) => const MaterialPage(child: GoalsScreen()),
  '/personalize/dislikes': (_) => const MaterialPage(child: DislikesScreen()),
});
