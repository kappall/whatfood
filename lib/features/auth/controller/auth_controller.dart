import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';
import 'package:whatfood/core/utils.dart';
import 'package:whatfood/features/auth/repository/auth_repository.dart';
import 'package:whatfood/models/User.dart';

final userProvider = StateProvider<User?>((ref) => null);

final authControllerProvider = StateNotifierProvider<AuthController, bool>(
  (ref) => AuthController(
    authRepository: ref.watch(authRepositoryProvider),
    ref: ref,
  ),
);

final getUserDataProvider = FutureProvider<User?>((ref) async {
  final authRepo = ref.watch(authRepositoryProvider);
  final userId = await authRepo.getCurrentUserId();

  if (userId == null) {
    return null;
  }

  return authRepo.getUserData(userId);
});

class AuthController extends StateNotifier<bool> {
  final AuthRepository _authRepository;
  final Ref _ref;
  AuthController({required AuthRepository authRepository, required Ref ref})
      : _authRepository = authRepository,
        _ref = ref,
        super(false);

  // void signInWithGoogle(BuildContext context, bool isFromLogin) async {
  //   state = true;
  //   final user = await _authRepository.signInWithGoogle(isFromLogin);
  //   state = false;
  //   user.fold(
  //     (l) => showSnackBar(context, l.message),
  //     (userModel) {
  //       _ref.read(userProvider.notifier).update((state) => userModel);
  //       Routemaster.of(context).push('preferences');
  //     },
  //   );
  // }

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
      state = false;
      user.fold(
        (l) {
          log('Errore: ${l.message}');
          showSnackBar(context, l.message);
        },
        (userModel) {
          Routemaster.of(context).push('/preferences');
          debugPrint("got here");
        },
      );
    } catch (e) {
      if (context.mounted) {
        showSnackBar(context, e.toString());
      }
    }
  }

  Future<User?> getUserData(String uid) {
    return _authRepository.getUserData(uid);
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
        Routemaster.of(context).push('/preferences');
      },
    );
  }
}
