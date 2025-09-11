import 'package:flutter/material.dart';
import 'package:routemaster/routemaster.dart';
import 'package:whatfood/features/auth/screens/login_screen.dart';
import 'package:whatfood/features/auth/screens/signup_screen.dart';
import 'package:whatfood/features/food/screens/food_screen.dart';
import 'package:whatfood/features/home/screens/home_screen.dart';
import 'package:whatfood/features/food/screens/ingredient_detail_screen.dart';
import 'package:whatfood/features/map/screens/map_screen.dart';
import 'package:whatfood/features/onboarding/screens/onboarding_screen.dart';
import 'package:whatfood/features/personalization/screens/allergies_screen.dart';
import 'package:whatfood/features/personalization/screens/dislikes_screen.dart';
import 'package:whatfood/features/personalization/screens/goals_screen.dart';
import 'package:whatfood/features/personalization/screens/preferences_screen.dart';
import 'package:whatfood/features/private_area/screens/private_area_screen.dart';
import 'package:whatfood/features/food/screens/create_recipe_screen.dart';
import 'package:whatfood/features/food/screens/recipe_detail_page.dart';
import 'package:whatfood/features/scanner/screens/scan_screen.dart';
import 'package:whatfood/features/settings/screens/privacy_policy_screen.dart';
import 'package:whatfood/features/settings/screens/setting_screen.dart';
import 'package:whatfood/pages/app_scaffold.dart';

final loggedOutRoutes = RouteMap(
  // do not delete this, needed for logout redirecct
  onUnknownRoute: (_) => const MaterialPage(child: LoginScreen()),
  routes: {
    '/': (_) => const MaterialPage(child: LoginScreen()),
    '/signup': (_) => const MaterialPage(child: SignupScreen()),
  },
);

final loggedInRoutes = RouteMap(routes: {
  '/': (_) => CupertinoTabPage(
        child: AppScaffold(),
        paths: ['/home', '/scan', '/food', '/map'],
      ),
  '/login': (_) => MaterialPage(child: LoginScreen()),
  '/home': (_) => const MaterialPage(child: HomeScreen()),
  '/scan': (_) => const MaterialPage(child: ScanScreen()),
  '/food': (_) => const MaterialPage(child: FoodScreen()),
  '/map': (_) => const MaterialPage(child: MapScreen()),
  '/private': (_) => const MaterialPage(child: PrivateAreaScreen()),
  '/private/settings': (_) => const MaterialPage(child: SettingsScreen()),
  '/onboarding': (_) => const MaterialPage(child: OnboardingScreen()),
  '/personalize/preferences': (_) =>
      const MaterialPage(child: PreferencesScreen()),
  '/personalize/allergies': (_) => const MaterialPage(child: AllergiesScreen()),
  '/personalize/goals': (_) => const MaterialPage(child: GoalsScreen()),
  '/personalize/dislikes': (_) => const MaterialPage(child: DislikesScreen()),
  '/create-recipe': (_) => const MaterialPage(child: CreateRecipeScreen()),
  '/recipe-details/:id': (route) => MaterialPage(
        child: RecipeDetailPage(
            recipeId: Uri.decodeComponent(route.pathParameters['id']!)),
      ),
  '/ingredient/:id': (route) => MaterialPage(
        child: IngredientDetailScreen(id: route.pathParameters['id']!),
      ),
  '/settings': (_) => const MaterialPage(child: SettingsScreen()),
  '/privacy': (_) => const MaterialPage(child: PrivacyPolicyScreen()),
});
