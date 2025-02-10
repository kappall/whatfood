import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';
import 'package:whatfood/core/common/loader.dart';
import 'package:whatfood/core/utils.dart';
import 'package:whatfood/features/auth/controller/auth_controller.dart';

class VerifyEmailView extends ConsumerStatefulWidget {
  const VerifyEmailView({super.key});

  @override
  ConsumerState<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends ConsumerState<VerifyEmailView> {
  bool _isLoading = false;

  Future<void> _checkVerification() async {
    setState(() => _isLoading = true);
    try {
      await FirebaseAuth.instance.currentUser?.reload();
      final user = FirebaseAuth.instance.currentUser;
      debugPrint(user.toString());

      if (user?.emailVerified ?? false) {
        if (mounted) {
          // Forza il rebuild dello stato di autenticazione
          ref.invalidate(authStateChangeProvider);
          Routemaster.of(context).replace('/');
        }
      } else {
        showSnackBar(context, 'Email non ancora verificata');
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _resendVerification() async {
    setState(() => _isLoading = true);
    try {
      await FirebaseAuth.instance.currentUser?.sendEmailVerification();
      showSnackBar(context, 'Email di verifica inviata');
    } catch (e) {
      showSnackBar(context, 'Errore durante l\'invio: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authControllerProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Verify Email'),
        backgroundColor: Colors.green,
        centerTitle: true,
      ),
      body: isLoading
          ? const Loader()
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Align(
                    alignment: Alignment.center,
                    child: Text(
                      "Verify your email address",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "We’ve sent a verification email to your address. Please check your inbox and verify to continue.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                  const SizedBox(height: 80),
                  FilledButton(
                      onPressed: _isLoading ? null : _resendVerification,
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.lightGreen,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(
                            vertical: 15, horizontal: 40),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator()
                          : const Text('Resend Email',
                              style: TextStyle(
                                  fontSize: 18, color: Colors.white))),
                  const SizedBox(height: 30),
                  TextButton(
                    onPressed: _isLoading ? null : _checkVerification,
                    child: const Text(
                      'I have verified my email',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.lightGreen,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
