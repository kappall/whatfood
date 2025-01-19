import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatfood/firebase_options.dart';
import 'package:whatfood/views/login_view.dart';
import 'package:whatfood/views/register_view.dart';
import 'pages/start_page.dart';
import 'package:google_api_availability/google_api_availability.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initializeGoogleProvider();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Start',
      theme: ThemeData(primarySwatch: Colors.blue),
      // Verifica se l'utente è già loggato
      home: _getInitialPage(),
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
    );
  }

  // Funzione che determina quale pagina mostrare come home
  Widget _getInitialPage() {
    FirebaseAuth.instance.signOut(); //if logout is needed uncomment this
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      return const MainPage(isGuest: false);
    } else {
      return const StartPage();
    }
  }
}

Future<void> _initializeGoogleProvider() async {
  if (Platform.isAndroid) {
    GooglePlayServicesAvailability availability = await GoogleApiAvailability
        .instance
        .checkGooglePlayServicesAvailability();
    if (availability != GooglePlayServicesAvailability.success) {
      await GoogleApiAvailability.instance.makeGooglePlayServicesAvailable();
    }
  }
}
