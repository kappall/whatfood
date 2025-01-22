import 'package:flutter/material.dart';
import 'package:routemaster/routemaster.dart';
import 'package:whatfood/features/auth/views/register_view.dart';
import 'package:whatfood/pages/start_page.dart';
import 'package:whatfood/features/auth/views/login_view.dart';

final loggedOutRoutes = RouteMap(
  onUnknownRoute: (route) => const Redirect('/'),
  routes: {
    '/login/': (_) => const MaterialPage(child: LoginView()),
    '/register/': (_) => const MaterialPage(child: RegisterView()),
    '/': (_) => MaterialPage(child: const StartPage()),
  },
);

final loggedInRoutes = RouteMap(routes: {
  '/': (_) => const MaterialPage(child: MainPage(isGuest: false)),
});
final guestRoutes = RouteMap(routes: {
  '/': (_) => const MaterialPage(
          child: MainPage(
        isGuest: true,
      )),
});
