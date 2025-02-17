import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';
import 'package:whatfood/core/utils.dart';
import 'package:whatfood/features/auth/repository/auth_repository.dart';
import 'package:whatfood/models/user_model.dart';

final userProvider = StateProvider<UserModel?>((ref) => null);

final isNewLoginProvider = StateProvider<bool>((ref) => false);

final authControllerProvider = StateNotifierProvider<AuthController, bool>(
  (ref) => AuthController(
    authRepository: ref.watch(authRepositoryProvider),
    ref: ref,
  ),
);

final authStateChangeProvider = StreamProvider((ref) {
  final authController = ref.watch(authControllerProvider.notifier);
  return authController.authStateChange;
});

final getUserDataProvider = StreamProvider.family((ref, String uid) {
  final authController = ref.watch(authControllerProvider.notifier);
  return authController.getUserData(uid);
});

class AuthController extends StateNotifier<bool> {
  final AuthRepository _authRepository;
  final Ref _ref;
  AuthController({required AuthRepository authRepository, required Ref ref})
      : _authRepository = authRepository,
        _ref = ref,
        super(false);

  Stream<User?> get authStateChange => _authRepository.authStateChange;

  void signInWithGoogle(BuildContext context, bool isFromLogin) async {
    state = true;
    final user = await _authRepository.signInWithGoogle(isFromLogin);
    state = false;
    user.fold(
      (l) => showSnackBar(context, l.message),
      (userModel) {
        _ref.read(userProvider.notifier).update((state) => userModel);
        _ref.read(isNewLoginProvider.notifier).state = true;
        Routemaster.of(context).replace('/preferences');
      },
    );
  }

  void signInAsGuest(BuildContext context) async {
    state = true;
    final user = await _authRepository.signInAsGuest();
    state = false;
    user.fold(
      (l) => showSnackBar(context, l.message),
      (userModel) {
        _ref.read(userProvider.notifier).update((state) => userModel);
        Routemaster.of(context).replace('/');
      },
    );
  }

  void signInWithEmailAndPassword({
    required BuildContext context,
    required String email,
    required String password,
  }) async {
    try {
      state = true;
      final user = await _authRepository.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      user.fold(
        (l) => showSnackBar(context, l.message),
        (userModel) {
          _ref.read(userProvider.notifier).update((state) => userModel);
          _ref.read(isNewLoginProvider.notifier).state = true;
          Routemaster.of(context).replace('/preferences');
        },
      );
      state = false;
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  Stream<UserModel> getUserData(String uid) {
    return _authRepository.getUserData(uid).map((userData) {
      return userData;
    });
  }

  void logout() async {
    _ref.read(isNewLoginProvider.notifier).state = false;
    _authRepository.logOut();
  }

  Future<void> registerWithEmailAndPassword({
    required BuildContext context,
    required String email,
    required String password,
    required String name,
  }) async {
    state = true;
    final user = await _authRepository.registerWithEmailAndPassword(
      email: email,
      password: password,
      name: name,
    );

    user.fold(
      (l) => showSnackBar(context, l.message),
      (userModel) {
        Routemaster.of(context).push('/verify-email');
      },
    );
  }
}
