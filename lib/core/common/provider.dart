import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/widgets.dart';

class MyNotifier<T> extends ChangeNotifier {
  T _value;
  bool _loggedIn = false; // synchronous storage for login status

  MyNotifier(this._value) {
    _checkAuthStatus();
  }

  T get value => _value;

  set value(T newValue) {
    if (newValue != _value) {
      _value = newValue;
      notifyListeners();
    }
  }

  // Synchronously return the stored value.
  bool get isLoggedIn => _loggedIn;

  // Asynchronously fetch auth session and update _loggedIn.
  Future<void> _checkAuthStatus() async {
    try {
      final session = await Amplify.Auth.fetchAuthSession();
      _loggedIn = session.isSignedIn;
    } on AuthException catch (e) {
      debugPrint('Error checking auth session: ${e.message}');
      _loggedIn = false;
    }
    notifyListeners();
  }
}

class MyProvider<T> extends InheritedNotifier<MyNotifier<T>> {
  const MyProvider({
    super.key,
    required MyNotifier<T> super.notifier,
    required super.child,
  });

  static MyNotifier<T>? of<T>(BuildContext context) {
    final provider =
        context.dependOnInheritedWidgetOfExactType<MyProvider<T>>();
    return provider?.notifier;
  }
}
