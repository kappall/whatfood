import 'package:amplify_analytics_pinpoint/amplify_analytics_pinpoint.dart';
import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_datastore/amplify_datastore.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatfood/amplifyconfiguration.dart';
import 'package:whatfood/core/common/error_text.dart';
import 'package:whatfood/core/common/loader.dart';
import 'package:whatfood/core/common/provider.dart';
import 'package:whatfood/features/auth/controller/auth_controller.dart';
import 'package:whatfood/features/auth/repository/auth_repository.dart';
import 'package:whatfood/models/ModelProvider.dart';
import 'package:whatfood/router.dart';
import 'package:routemaster/routemaster.dart';
import 'package:whatfood/theme/theme.dart';

Future<void> configureAmplify() async {
  try {
    final auth = AmplifyAuthCognito();
    final datastore = AmplifyDataStore(modelProvider: ModelProvider.instance);
    final api = AmplifyAPI();

    await Amplify.addPlugins([
      auth,
      datastore,
      api,
    ]);

    await Amplify.configure(amplifyconfig);
    debugPrint('Successfully configured Amplify');
  } catch (e) {
    debugPrint('Error configuring Amplify: $e');
  }
}

Future<bool> isUserLoggedIn() async {
  try {
    final session = await Amplify.Auth.fetchAuthSession();
    return session.isSignedIn;
  } on AuthException catch (e) {
    debugPrint('Error checking auth session: ${e.message}');
    return false;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureAmplify();

  final bool loggedIn = await isUserLoggedIn();
  debugPrint('User logged in: $loggedIn');

  runApp(MyApp(loggedIn: loggedIn));
}

class MyApp extends ConsumerStatefulWidget {
  final bool loggedIn;
  const MyApp({super.key, required this.loggedIn});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  Widget build(BuildContext context) {
    final MyNotifier<AuthController> authControllerNotifier =
        MyNotifier<AuthController>(
      AuthController(
        authRepository: AuthRepository(),
      ),
    );
    return MyProvider<AuthController>(
      notifier: authControllerNotifier,
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'Whatfood',
        theme: darkTheme,
        routerDelegate: RoutemasterDelegate(routesBuilder: (context) {
          final authController = MyProvider.of<AuthController>(context);
          final loggedIn = authController?.isLoggedIn ?? false;
          return loggedIn ? loggedInRoutes : loggedOutRoutes;
        }),
        routeInformationParser: const RoutemasterParser(),
      ),
    );
  }
}
