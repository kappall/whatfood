import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';
import 'package:whatfood/features/auth/controller/auth_controller.dart';
import 'package:whatfood/core/common/loader.dart';
import 'package:whatfood/l10n/app_localizations.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure = true;

  void _emailLogin() {
    if (_formKey.currentState!.validate()) {
      ref.read(authControllerProvider.notifier).signInWithEmailAndPassword(
            email: _emailCtrl.text.trim(),
            password: _passwordCtrl.text.trim(),
            context: context,
          );
    }
  }

  Future<void> _googleLogin() async {
    await ref.read(authControllerProvider.notifier).signInWithGoogle(context);
  }

  Future<void> _appleLogin() async {
    await ref.read(authControllerProvider.notifier).signInWithApple(context);
  }

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final loading = ref.watch(authControllerProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary.withValues(alpha: .9),
                  Theme.of(context).colorScheme.primary.withValues(alpha: .6),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(height: 8),
                          Text(
                            l10n.loginTitle,
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),

                          /* email */
                          TextFormField(
                            controller: _emailCtrl,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.email_outlined),
                              labelText: 'Email',
                              border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(12))),
                            ),
                            validator: (v) =>
                                v!.isEmpty ? '${l10n.enterField}email' : null,
                          ),
                          const SizedBox(height: 16),

                          /* password */
                          TextFormField(
                            controller: _passwordCtrl,
                            obscureText: _obscure,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.lock_outline),
                              labelText: 'Password',
                              border: const OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(12))),
                              suffixIcon: IconButton(
                                icon: Icon(_obscure
                                    ? Icons.visibility
                                    : Icons.visibility_off),
                                onPressed: () =>
                                    setState(() => _obscure = !_obscure),
                              ),
                            ),
                            validator: (v) => v!.isEmpty
                                ? '${l10n.enterField}password'
                                : null,
                          ),
                          const SizedBox(height: 34),

                          /* email login */
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size.fromHeight(48),
                                side:
                                    const BorderSide(color: Colors.lightGreen),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: loading ? null : _emailLogin,
                              child: loading
                                  ? const Loader()
                                  : const Text('Login',
                                      style:
                                          TextStyle(color: Colors.lightGreen)),
                            ),
                          ),
                          const SizedBox(height: 24),
                          const Divider(thickness: .5),
                          const SizedBox(height: 12),
                          OutlinedButton.icon(
                            onPressed: loading ? null : _googleLogin,
                            icon: Image.asset('assets/icons/google.png',
                                height: 24),
                            label: const Text('Login with Google'),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size.fromHeight(48),
                              side: const BorderSide(color: Color(0xFF4285F4)),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              foregroundColor: const Color(0xFF4285F4),
                            ),
                          ),
                          const SizedBox(height: 12),
                          if (Platform.isIOS)
                            OutlinedButton.icon(
                              onPressed: loading ? null : _appleLogin,
                              icon: Image.asset('assets/icons/apple.png',
                                  height: 24),
                              label: const Text(
                                'Login with Apple',
                              ),
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size.fromHeight(48),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                          const SizedBox(height: 12),
                          TextButton(
                            onPressed: () =>
                                Routemaster.of(context).replace('/signup'),
                            child: const Text(
                              "Don't have an account? Sign up",
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
