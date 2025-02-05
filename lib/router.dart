import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:routemaster/routemaster.dart';
import 'package:whatfood/features/auth/views/login_view.dart';
import 'package:whatfood/features/auth/views/register_view.dart';
import 'package:whatfood/features/auth/views/verify_email_view.dart';
import 'package:whatfood/features/post/pages/add_post_page.dart';
import 'package:whatfood/features/post/pages/add_post_type_page.dart';
import 'package:whatfood/pages/start_page.dart';

final allRoutes = RouteMap(routes: {
  '/': (_) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return MaterialPage(child: const LoginView());
    } else if (!user.emailVerified) {
      return MaterialPage(child: const VerifyEmailView());
    } else {
      return MaterialPage(child: const MainPage(isGuest: false));
    }
  },
  '/login': (_) => const MaterialPage(child: LoginView()),
  '/register': (_) => const MaterialPage(child: RegisterView()),
  '/main_guest': (_) => const MaterialPage(child: MainPage(isGuest: true)),
  '/main_page': (_) => const MaterialPage(child: MainPage(isGuest: false)),
  '/main_page/add_post': (_) => const MaterialPage(child: AddPostPage()),
  '/main_page/add_post/:type': (route) => MaterialPage(
        child: AddPostTypePage(
          type: route.pathParameters['type'] ?? '',
        ),
      ),
});
