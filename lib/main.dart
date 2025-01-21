import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';
import 'package:whatfood/core/common/error_text.dart';
import 'package:whatfood/core/common/loader.dart';
import 'package:whatfood/firebase_options.dart';
import 'package:whatfood/models/user_model.dart';
import 'package:whatfood/features/auth/controller/auth_controller.dart';
import 'package:whatfood/router.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    checkAuthState();
  }

  void checkAuthState() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      await getUserData(currentUser);
    }
    setState(() {
      isLoading = false;
    });
  }

  Future<void> getUserData(User user) async {
    userModel = await ref
        .read(authControllerProvider.notifier)
        .getUserData(user.uid)
        .first;
    ref.read(userProvider.notifier).update((state) => userModel);
  }

  @override
  Widget build(BuildContext context) {
    return ref.watch(authStateChangeProvider).when(
          data: (data) => MaterialApp.router(
            debugShowCheckedModeBanner: false,
            title: 'Whatfood',
            theme: ThemeData(primarySwatch: Colors.blue),
            routerDelegate: RoutemasterDelegate(
              routesBuilder: (context) {
                if (data != null) {
                  if (userModel == null) {
                    getUserData(data);
                    return RouteMap(routes: {
                      '/': (_) => const MaterialPage(child: Loader())
                    });
                  }
                  return loggedInRoutes;
                }
                return loggedOutRoutes;
              },
            ),
            routeInformationParser: const RoutemasterParser(),
          ),
          error: (error, stackTrace) => ErrorText(error: error.toString()),
          loading: () => const Loader(),
        );
  }
}
