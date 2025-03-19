// import 'package:amplify_flutter/amplify_flutter.dart';
// import 'package:flutter/widgets.dart';
// import 'package:whatfood/core/providers/aws_providers.dart';
// import 'package:whatfood/core/providers/storage_repository_provider.dart';
// import 'package:whatfood/features/auth/controller/auth_controller.dart';
// import 'package:whatfood/features/auth/repository/auth_repository.dart';
// import 'package:whatfood/features/post/controller/post_controller.dart';
// import 'package:whatfood/features/post/repository/post_repository.dart';
// import 'package:whatfood/features/recipes/controller/recipe_controller.dart';
// import 'package:whatfood/features/recipes/repository/recipe_repository.dart';

// class MyNotifier<T> extends ChangeNotifier {
//   T _value;
//   bool _loggedIn = false; // synchronous storage for login status

//   MyNotifier(this._value) {
//     _checkAuthStatus();
//   }

//   T get value => _value;

//   set value(T newValue) {
//     if (newValue != _value) {
//       _value = newValue;
//       notifyListeners();
//     }
//   }

//   // Synchronously return the stored value.
//   bool get isLoggedIn => _loggedIn;

//   // Asynchronously fetch auth session and update _loggedIn.
//   Future<void> _checkAuthStatus() async {
//     try {
//       final session = await Amplify.Auth.fetchAuthSession();
//       _loggedIn = session.isSignedIn;
//     } on AuthException catch (e) {
//       debugPrint('Error checking auth session: ${e.message}');
//       _loggedIn = false;
//     }
//     notifyListeners();
//   }
// }

// class MyProvider<T> extends InheritedNotifier<MyNotifier<T>> {
//   const MyProvider({
//     super.key,
//     required MyNotifier<T> super.notifier,
//     required super.child,
//   });

//   static MyNotifier<T>? of<T>(BuildContext context) {
//     final provider =
//         context.dependOnInheritedWidgetOfExactType<MyProvider<T>>();
//     return provider?.notifier;
//   }
// }

// class ProvidersWrapper extends StatelessWidget {
//   final Widget child;

//   const ProvidersWrapper({
//     super.key,
//     required this.child,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return MyProvider(
//       notifier: MyNotifier<AWSServices>(AWSServices()),
//       child: MyProvider<AuthController>(
//         notifier: MyNotifier<AuthController>(
//           AuthController(authRepository: AuthRepository()),
//         ),
//         child: MyProvider<PostController>(
//           notifier: MyNotifier<PostController>(
//             PostController(
//               postRepository: PostRepository(),
//               storageRepository: StorageRepository(),
//             ),
//           ),
//           child: MyProvider<RecipeController>(
//             notifier: MyNotifier<RecipeController>(
//               RecipeController(
//                   recipeRepository: RecipeRepository(),
//                   storageRepository: StorageRepository()),
//             ),
//             child: child,
//           ),
//         ),
//       ),
//     );
//   }
// }
