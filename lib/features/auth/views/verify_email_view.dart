import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:routemaster/routemaster.dart';
import 'package:whatfood/core/utils.dart';

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({super.key});

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Verify Email'),
        backgroundColor: Colors.green,
        centerTitle: true,
      ),
      body: Padding(
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
            const SizedBox(height: 30),
            FilledButton(
              onPressed: () async {
                final user = FirebaseAuth.instance.currentUser;
                await user?.sendEmailVerification();
                if (!context.mounted) return;
                showSnackBar(context, 'Verification email sent!');
              },
              style: FilledButton.styleFrom(
                backgroundColor: Colors.lightGreen,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
              ),
              child: const Text(
                'Resend Email',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
            const SizedBox(height: 30),
            TextButton(
              onPressed: () async {
                await FirebaseAuth.instance.currentUser?.reload();
                final user = FirebaseAuth.instance.currentUser;
                if (!context.mounted) return;

                if (user?.emailVerified ?? false) {
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(user?.uid)
                      .update({
                    'isAuthenticated': true,
                  });
                  if (!context.mounted) return;
                  Routemaster.of(context).push(
                    '/main_page/',
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Email not verified yet.',
                        style: TextStyle(color: Colors.white),
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text(
                'I have verified my email',
                style: TextStyle(fontSize: 16, color: Colors.lightGreen),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
