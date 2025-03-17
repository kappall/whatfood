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

Future<Map<String, dynamic>> getUserData() async {
  final attributes = await Amplify.Auth.fetchUserAttributes();
  return Map.fromEntries(
    attributes.map((attr) => MapEntry(attr.userAttributeKey.key, attr.value)),
  );
}

class AuthController extends StateNotifier<bool> {
  final AuthRepository _authRepository;
  AuthController({required AuthRepository authRepository})
      : _authRepository = authRepository,
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

  // void signInAsGuest(BuildContext context) async {
  //   state = true;
  //   final user = await _authRepository.signInAsGuest();
  //   state = false;
  //   user.fold(
  //     (l) => showSnackBar(context, l.message),
  //     (userModel) {
  //       _ref.read(userProvider.notifier).update((state) => userModel);
  //       Routemaster.of(context).replace('/');
  //     },
  //   );
  // }

  Future<void> signInWithEmailAndPassword({
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
      (signUpResult) {
        try {
          debugPrint(signUpResult.toString());
          if (signUpResult.nextStep.signUpStep ==
              AuthSignUpStep.confirmSignUp) {
            debugPrint("here");

            final userModel = User(
              name: name,
              email: email,
              profilePic: Constants.avatarDefault,
              banner: Constants.bannerDefault,
              uid: signUpResult.userId!,
              preferences: [],
              savedPosts: [],
              postsCount: 0,
              dailyIntake: 0,
              followers: [],
              following: [],
              isVerified: false,
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
            const Text('Inser the code sent to your email'),
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
                    if (Navigator.of(context).canPop()) {
                      Navigator.of(context).pop();
                    }
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
              }
            },
            child: const Text('Verify'),
          ),
        ],
      ),
    );
  }
}
