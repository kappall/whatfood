import 'package:flutter/material.dart';
import 'package:routemaster/routemaster.dart';
import 'package:whatfood/features/auth/screens/login_screen.dart';
import 'package:whatfood/features/auth/screens/signup_screen.dart';
import 'package:whatfood/features/home/views/home_view.dart';
import 'package:whatfood/features/onboarding/screens/onboarding_screen.dart';

final loggedOutRoutes = RouteMap(
  routes: {
    '/': (_) => const MaterialPage(child: LoginScreen()),
    '/onboarding': (_) => const MaterialPage(child: OnboardingScreen()),
    '/signup': (_) => const MaterialPage(child: SignupScreen()),
  },
);

final loggedInRoutes = RouteMap(routes: {
  '/': (_) => const MaterialPage(child: HomeScreen()),
  '/onboarding': (_) => const MaterialPage(child: OnboardingScreen()),
});
