import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatfood/amplifyconfiguration.dart';
import 'package:whatfood/core/common/error_text.dart';
import 'package:whatfood/core/common/loader.dart';
import 'package:whatfood/features/auth/controller/auth_controller.dart';
import 'package:whatfood/models/User.dart';
import 'package:whatfood/router.dart';
import 'package:routemaster/routemaster.dart';
import 'package:whatfood/theme/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Amplify.addPlugins([
      AmplifyAuthCognito(),
      AmplifyAPI(),
    ]);
    await Amplify.configure(amplifyconfig);
    debugPrint("Amplify successfully configured");
  } catch (e) {
    debugPrint("Error configuring Amplify: $e");
  }

  runApp(
    ProviderScope(child: MyApp()),
  );
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  User? userModel;

  void getData(WidgetRef ref, User user) async {
    userModel =
        await ref.watch(authControllerProvider.notifier).getUserData(user.uid);
    ref.read(userProvider.notifier).update((state) => userModel);
  }

  @override
  Widget build(BuildContext context) {
    return ref.watch(getUserDataProvider).when(
          data: (user) => MaterialApp.router(
            debugShowCheckedModeBanner: false,
            title: 'Whatfood',
            theme: darkTheme,
            routerDelegate: RoutemasterDelegate(routesBuilder: (context) {
              if (user == null || !user.isVerified) {
                return loggedOutRoute;
              }
              getData(ref, user);
              return loggedInRoute;
            }),
            routeInformationParser: const RoutemasterParser(),
          ),
          error: (error, stackTrace) => ErrorText(error: error.toString()),
          loading: () => const Loader(),
        );
  }
}
