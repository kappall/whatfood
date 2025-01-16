import 'package:flutter/material.dart';
import 'package:whatfood/views/login_view.dart';
import 'package:whatfood/views/register_view.dart';
import 'pages/start_page.dart';

void main() {
  runApp(MaterialApp(
    title: 'Start',
    theme: ThemeData(primarySwatch: Colors.blue),
    home: const StartPage(),
    routes: {
      '/login/': (context) => const LoginView(),
      '/register/': (context) => const RegisterView(),
      '/main_page/': (context) => const MainPage(
            isGuest: false,
          ),
      '/main_page_guest/': (context) => const MainPage(
            isGuest: true,
          ),
    },
  ));
}
