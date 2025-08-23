import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_datastore/amplify_datastore.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:whatfood/amplifyconfiguration.dart';
import 'package:whatfood/core/common/error_text.dart';
import 'package:whatfood/core/common/loader.dart';
import 'package:whatfood/core/services/hive_encryption_service.dart';
import 'package:whatfood/features/auth/controller/auth_controller.dart';
import 'package:whatfood/l10n/app_localizations.dart';
import 'package:whatfood/models/ModelProvider.dart';
import 'package:whatfood/models/diary_entry.dart';
import 'package:whatfood/router.dart';
import 'package:routemaster/routemaster.dart';

final themeModeProvider = StateProvider<ThemeMode>((_) => ThemeMode.system);

Future<void> configureAmplify() async {
  try {
    final auth = AmplifyAuthCognito();
    final datastore = AmplifyDataStore(modelProvider: ModelProvider.instance);
    final api = AmplifyAPI();
    final storage = AmplifyStorageS3();

    await Amplify.addPlugins([
      auth,
      datastore,
      api,
      storage,
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
  //Amplify.Auth.signOut();

  final bool loggedIn = await isUserLoggedIn();
  debugPrint('User logged in: $loggedIn');

  final dir = await getApplicationDocumentsDirectory();
  Hive.init(dir.path);

  Hive.registerAdapter(DiaryEntryAdapter());
  Hive.registerAdapter(MealTypeAdapter());

  final cipher = await HiveEncryptionService.getCipher();
  //await Hive.deleteBoxFromDisk('foodDiary');
  await Hive.openBox<DiaryEntry>(
    'foodDiary',
    encryptionCipher: cipher,
  );

  runApp(
    ProviderScope(child: MyApp(loggedIn: loggedIn)),
  );
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
    return ref.watch(authStateChangeProvider).when(
          data: (user) => MaterialApp.router(
            debugShowCheckedModeBanner: false,
            title: 'Whatfood',
            themeMode: ref.watch(themeModeProvider),
            theme: _buildLightTheme(),
            darkTheme: _buildDarkTheme(),
            routerDelegate: RoutemasterDelegate(
              routesBuilder: (context) {
                if (user != null) {
                  return loggedInRoutes;
                }
                return loggedOutRoutes;
              },
            ),
            routeInformationParser: const RoutemasterParser(),
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en'),
              Locale('it'),
            ],
            locale: const Locale('it'),
          ),
          error: (error, stackTrace) => MaterialApp(
            home: Scaffold(
              body: ErrorText(
                error: error.toString(),
              ),
            ),
          ),
          loading: () => const MaterialApp(
            home: Scaffold(
              body: Loader(),
            ),
          ),
        );
  }

  ThemeData _buildLightTheme() {
    final scheme = ColorScheme.fromSeed(
      seedColor: Colors.green.shade700,
      brightness: Brightness.light,
    );

    return ThemeData(
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.background,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        elevation: 2,
        iconTheme: IconThemeData(color: scheme.onSurface),
        titleTextStyle: TextStyle(
          color: scheme.onSurface,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        selectedItemColor: scheme.primary,
        unselectedItemColor: scheme.onSurface.withOpacity(0.6),
      ),
    );
  }

  ThemeData _buildDarkTheme() {
    final scheme = ColorScheme.fromSeed(
      seedColor: Colors.green.shade300,
      brightness: Brightness.dark,
    );

    return ThemeData(
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.background,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        elevation: 2,
        iconTheme: IconThemeData(color: scheme.onSurface),
        titleTextStyle: TextStyle(
          color: scheme.onSurface,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        selectedItemColor: scheme.primary,
        unselectedItemColor: scheme.onSurface.withOpacity(0.6),
      ),
    );
  }
}
