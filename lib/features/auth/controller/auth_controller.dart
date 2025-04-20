import 'dart:async';
import 'dart:developer';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';
import 'package:whatfood/core/constants/costants.dart';
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

final authStateChangeProvider = StreamProvider((ref) {
  final authController = ref.watch(authControllerProvider.notifier);
  return authController.authStateChange.map((user) {
    if (user != null) {
      ref.read(userProvider.notifier).update((_) => user);
    }
    return user;
  });
});

final getUserDataProvider = StreamProvider.family((ref, String uid) {
  final authController = ref.watch(authControllerProvider.notifier);
  return authController.getUserData(uid);
});

class AuthController extends StateNotifier<bool> {
  final AuthRepository _authRepository;
  final Ref _ref;
  StreamSubscription? _authSubscription;

  AuthController({required AuthRepository authRepository, required Ref ref})
      : _authRepository = authRepository,
        _ref = ref,
        super(false) {
    _initializeAuthState();
  }

  void _initializeAuthState() {
    _authSubscription = _authRepository.authStateChange.listen(
      (user) {
        _ref.read(userProvider.notifier).update((_) => user);
      },
      onError: (error) {
        debugPrint('Auth state error: $error');
        _ref.read(userProvider.notifier).update((_) => null);
      },
    );
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  Stream<User?> get authStateChange => _authRepository.authStateChange;

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

  Stream<User> getUserData(String uid) {
    return _authRepository.getUserData(uid).map((userdata) => userdata);
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
      (signUpResult) {
        try {
          if (signUpResult.nextStep.signUpStep ==
              AuthSignUpStep.confirmSignUp) {
            final userModel = User(
              name: name,
              email: email,
              profilePic: Constants.avatarDefault,
              banner: Constants.bannerDefault,
              id: signUpResult.userId!,
              preferences: [],
              savedPosts: [],
              postsCount: 0,
              dailyIntake: 0,
              followers: [],
              following: [],
              bio: '',
            );

            _showVerificationDialog(context, userModel, password);
          }
        } catch (e) {
          debugPrint(e.toString());
        }
      },
    );
  }

  void _showVerificationDialog(
      BuildContext context, User user, String password) {
    final verificationController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Email Verification'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Insert the code sent to your email'),
            TextField(
              controller: verificationController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Verification Code',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              debugPrint("deleting: ${user.email}");
              _authRepository.deleteUnconfirmedUser(user.email);
              if (context.mounted) {
                Navigator.of(context).pop();
              }
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              try {
                final confirmResult = await Amplify.Auth.confirmSignUp(
                  username: user.email,
                  confirmationCode: verificationController.text.trim(),
                );

                if (confirmResult.isSignUpComplete) {
                  final email = user.email;
                  await _authRepository.saveUserData(user);

                  final signInResult = await Amplify.Auth.signIn(
                    username: email,
                    password: password,
                  );
                  if (signInResult.isSignedIn) {
                    Navigator.of(context).pop();
                    if (context.mounted) {
                      Routemaster.of(context).replace('/preferences');
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Sign in failed after confirmation.')),
                    );
                  }
                }
              } on AuthException catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(e.message)),
                );
              } catch (e) {
                _authRepository.deleteUnconfirmedUser(user.email);
                debugPrint("Exeption: ${e.toString()}");
              }
            },
            child: const Text('Verify'),
          ),
        ],
      ),
    );
  }
}
