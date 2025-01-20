import 'package:flutter/material.dart';
import 'package:routemaster/routemaster.dart';
import 'package:whatfood/pages/start_page.dart';
import 'package:whatfood/features/auth/views/login_view.dart';

final loggedOutRoutes = RouteMap(routes: {
  '/login/': (_) => const MaterialPage(child: LoginView()),
  '/': (context) => MaterialPage(child: const StartPage()),
  '/main_page_guest/': (context) => MaterialPage(
        child: const MainPage(
          isGuest: true,
        ),
      ),
});

final loggedInRoutes = RouteMap(routes: {
  '/': (_) => const MaterialPage(
          child: MainPage(
        isGuest: false,
      )),
});
