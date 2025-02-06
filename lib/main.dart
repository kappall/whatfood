import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatfood/core/common/error_text.dart';
import 'package:whatfood/core/common/loader.dart';
import 'package:whatfood/features/auth/controller/auth_controller.dart';
import 'package:whatfood/firebase_options.dart';
import 'package:whatfood/models/user_model.dart';
import 'package:whatfood/router.dart';
import 'package:routemaster/routemaster.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  UserModel? userModel;

  void getData(WidgetRef ref, User data) async {
    userModel = await ref
        .watch(authControllerProvider.notifier)
        .getUserData(data.uid)
        .map((userData) {
      return userData;
    }).first;

    ref.read(userProvider.notifier).update((state) => userModel);
  }

  @override
  Widget build(BuildContext context) {
    return ref.watch(authStateChangeProvider).when(
          data: (data) {
            if (data != null) {
              getData(ref, data);

              final currentUser = ref.watch(userProvider);

              if (currentUser != null) {
                return MaterialApp.router(
                  debugShowCheckedModeBanner: false,
                  title: 'Whatfood',
                  routerDelegate: RoutemasterDelegate(
                    routesBuilder: (context) => loggedInRoute,
                  ),
                  routeInformationParser: const RoutemasterParser(),
                );
              }
            }

            return MaterialApp.router(
              debugShowCheckedModeBanner: false,
              title: 'Whatfood',
              routerDelegate: RoutemasterDelegate(
                routesBuilder: (context) => loggedOutRoute,
              ),
              routeInformationParser: const RoutemasterParser(),
            );
          },
          error: (error, stackTrace) => ErrorText(error: error.toString()),
          loading: () => const Loader(),
        );
  }
}
