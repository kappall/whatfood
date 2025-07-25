import 'package:flutter/material.dart';
import 'package:routemaster/routemaster.dart';
import 'package:whatfood/features/auth/screens/login_screen.dart';
import 'package:whatfood/features/auth/screens/signup_screen.dart';
import 'package:whatfood/features/community/screens/community_screen.dart';
import 'package:whatfood/features/community/screens/create_post_screen.dart';
import 'package:whatfood/features/home/screens/home_screen.dart';
import 'package:whatfood/features/ingredients/screens/ingredients_screen.dart';
import 'package:whatfood/features/onboarding/screens/onboarding_screen.dart';
import 'package:whatfood/features/personalization/screens/allergies_screen.dart';
import 'package:whatfood/features/personalization/screens/dislikes_screen.dart';
import 'package:whatfood/features/personalization/screens/goals_screen.dart';
import 'package:whatfood/features/personalization/screens/preferences_screen.dart';
import 'package:whatfood/features/private_area/screens/private_area_screen.dart';
import 'package:whatfood/features/profile/views/profile_view.dart';
import 'package:whatfood/features/recipes/screens/create_recipe_screen.dart';
import 'package:whatfood/features/recipes/screens/recipes_screen.dart';
import 'package:whatfood/features/scanner/screens/scan_screen.dart';
import 'package:whatfood/features/settings/screens/setting_screen.dart';
import 'package:whatfood/pages/app_scaffold.dart';

final loggedOutRoutes = RouteMap(
  routes: {
    '/': (_) => const MaterialPage(child: LoginScreen()),
    '/onboarding': (_) => const MaterialPage(child: OnboardingScreen()),
    '/signup': (_) => const MaterialPage(child: SignupScreen()),
  },
);

final loggedInRoutes = RouteMap(routes: {
  '/': (_) => CupertinoTabPage(
        child: AppScaffold(),
        paths: ['/home', '/scan', '/recipes', '/ingredients'],
      ),
  '/home': (_) => const MaterialPage(child: HomeScreen()),
  '/scan': (_) => const MaterialPage(child: ScanScreen()),
  '/recipes': (_) => const MaterialPage(child: RecipesScreen()),
  '/ingredients': (_) => const MaterialPage(child: IngredientsScreen()),
  '/private': (_) => const MaterialPage(child: PrivateAreaScreen()),
  '/private/settings': (_) => const MaterialPage(child: SettingsScreen()),
  '/onboarding': (_) => const MaterialPage(child: OnboardingScreen()),
  '/personalize/preferences': (_) =>
      const MaterialPage(child: PreferencesScreen()),
  '/personalize/allergies': (_) => const MaterialPage(child: AllergiesScreen()),
  '/personalize/goals': (_) => const MaterialPage(child: GoalsScreen()),
  '/personalize/dislikes': (_) => const MaterialPage(child: DislikesScreen()),
  '/create-post': (_) => const MaterialPage(child: CreatePostScreen()),
  '/create-recipe': (_) => const MaterialPage(child: CreateRecipeScreen())
});
