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

final authStateChangeProvider = StreamProvider<User?>((ref) {
  return ref.watch(authControllerProvider.notifier).authStateChange;
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

  User? get currentUser => _authRepository.currentUser;

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

  Future<void> signInWithGoogle(BuildContext context) async {/* impl */}
  Future<void> signInWithApple(BuildContext context) async {/* impl */}
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
          if (!userModel.isOnboarded) {
            Routemaster.of(context).replace('/onboarding');
          } else {
            Routemaster.of(context).replace('/');
          }
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
      (l) {
        showSnackBar(context, l.message);
        state = false;
      },
      (signUpResult) {
        try {
          if (signUpResult.nextStep.signUpStep ==
              AuthSignUpStep.confirmSignUp) {
            final userModel = User(
              name: name,
              email: email,
              profilePic: null,
              banner: Constants.bannerDefault,
              id: signUpResult.userId!,
              preferences: [],
              allergies: [],
              goals: [],
              dislikes: [],
              dailyIntake: 0,
              isOnboarded: false,
            );

            _showVerificationDialog(context, userModel, password);
          }
        } catch (e) {
          debugPrint(e.toString());
        } finally {
          state = false;
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
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Email Verification'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Insert the code sent to your email'),
            TextField(
              controller: verificationController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Verification Code'),
            ),
          ],
        ),
        actions: [
          // ---------- CANCEL ----------
          TextButton(
            onPressed: () async {
              debugPrint('deleting: ${user.email}');
              await _authRepository.deleteUnconfirmedUser(user.email);
              await Amplify.Auth.signOut();
              if (dialogCtx.mounted) {
                Navigator.of(dialogCtx).pop(); // close dialog
              }
            },
            child: const Text('Cancel'),
          ),

          // ---------- VERIFY ----------
          TextButton(
            onPressed: () async {
              try {
                final confirmResult = await Amplify.Auth.confirmSignUp(
                  username: user.email,
                  confirmationCode: verificationController.text.trim(),
                );

                if (dialogCtx.mounted) Navigator.of(dialogCtx).pop();

                if (!confirmResult.isSignUpComplete) {
                  throw Exception('Sign-up not complete');
                }

                await _authRepository.saveUserData(user);

                final signInResult = await Amplify.Auth.signIn(
                  username: user.email,
                  password: password,
                );

                if (!signInResult.isSignedIn) {
                  throw Exception('Sign-in failed after confirmation');
                }

                if (context.mounted) {
                  Routemaster.of(context).replace('/onboarding');
                }
              } catch (e, stack) {
                debugPrint('Exception during verification: $e');
                debugPrint('Stack trace: $stack');

                await _authRepository.deleteUnconfirmedUser(user.email);

                if (dialogCtx.mounted) Navigator.of(dialogCtx).pop();

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Verification failed: $e')),
                  );
                }
              }
            },
            child: const Text('Verify'),
          ),
        ],
      ),
    );
  }

  Future<void> logout() async {
    await Amplify.Auth.signOut();
    state = false;
  }

  Future<void> deleteAccount() async {
    try {
      final user = await Amplify.Auth.getCurrentUser();
      final userId = user.userId;
      await _authRepository.deleteAccount(userId);
      debugPrint('User data deleted from DynamoDB');
    } catch (e) {
      debugPrint('Error deleting user data: $e');
      rethrow;
    }
  }
}
