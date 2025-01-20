import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';
import 'package:whatfood/common/error_text.dart';
import 'package:whatfood/common/loader.dart';
import 'package:whatfood/core/providers/firebase_providers.dart';
import 'package:whatfood/firebase_options.dart';
import 'package:whatfood/models/user_model.dart';
import 'package:whatfood/pages/controller/auth_controller.dart';
import 'package:whatfood/router.dart';
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
  UserModel? userModel;
  void getData(WidgetRef, User data) async {
    userModel = await ref
        .watch(authControllerProvider.notifier)
        .getUserData(data.uid)
        .first;
    ref.read(userProvider.notifier).update((state) => userModel);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return ref.watch(authStateChangeProvider).when(
        data: (data) => MaterialApp.router(
              debugShowCheckedModeBanner: false,
              title: 'Start',
              theme: ThemeData(primarySwatch: Colors.blue),
              routerDelegate: RoutemasterDelegate(routesBuilder: (context) {
                if (data != null) {
                  getData(WidgetRef, data);
                  if (userModel != null) {
                    return loggedInRoutes;
                  }
                }
                return loggedOutRoutes;
              }),
              routeInformationParser: const RoutemasterParser(),
            ),
        error: (error, stackTrace) => ErrorText(error: error.toString()),
        loading: () => const Loader());
  }

  // Funzione che determina quale pagina mostrare come home
  /*Widget _getInitialPage() {
    //FirebaseAuth.instance.signOut(); //if logout is needed uncomment this
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      return const MainPage(isGuest: false);
    } else {
      return const StartPage();
    }
  }*/
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
