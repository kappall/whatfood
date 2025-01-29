import 'package:flutter/material.dart';
import 'package:routemaster/routemaster.dart';
import 'package:uuid/uuid.dart';
import 'package:whatfood/features/auth/views/register_view.dart';
import 'package:whatfood/pages/start_page.dart';
import 'package:whatfood/features/auth/views/login_view.dart';
/*
final loggedOutRoutes = RouteMap(
  routes: {
    '/': (_) => MaterialPage(child: StartPage()),
    '/login/': (_) => const MaterialPage(child: LoginView()),
    '/register/': (_) => const MaterialPage(child: RegisterView()),
    '/userId/:userId': (data) {
      final userId = data.pathParameters['userId'];
      return MaterialPage(child: MainPage(userId: userId));
    },
  },
);

final loggedInRoutes = RouteMap(
  routes: {
    '/': (data) {
      final userId = data.pathParameters['userId'];
      debugPrint(userId);
      return MaterialPage(child: MainPage(userId: userId));
    },
  },
);
final guestRoutes = RouteMap(routes: {
  '/': (_) => const MaterialPage(
          child: MainPage(
        userId: null,
      )),
});
*/