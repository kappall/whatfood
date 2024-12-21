import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:whatfood/firebase_options.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final TextEditingController _email;
  late final TextEditingController _password;
  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
          "Login",
        ),
      ),
      body: Center(
        child: FutureBuilder(
            future: Firebase.initializeApp(
              options: DefaultFirebaseOptions.currentPlatform,
            ),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.done:
                  {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextField(
                          controller: _email,
                          enableSuggestions: true,
                          autocorrect: false,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                              hintText: "Enter your email here",
                              hintStyle: TextStyle(color: Colors.grey)),
                        ),
                        TextField(
                          controller: _password,
                          obscureText: true,
                          enableSuggestions: false,
                          autocorrect: false,
                          decoration: InputDecoration(
                              hintText: "Enter your password here",
                              hintStyle: TextStyle(color: Colors.grey)),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () async {
                            final email = _email.text;
                            final password = _password.text;
                            try {
                              final userCredential = await FirebaseAuth.instance
                                  .signInWithEmailAndPassword(
                                      email: email, password: password);
                            } on FirebaseAuthException catch (e) {
                              // in realtà solo  l'eccezione Invalid credential è lanciata, guarda https://cloud.google.com/identity-platform/docs/admin/email-enumeration-protection?hl=it
                              setState(() {
                                switch (e.code) {
                                  case 'user-not-found':
                                    print('No user found with this email.');
                                    break;
                                  case 'wrong-password':
                                    print('Incorrect password.');
                                    break;
                                  case 'invalid-email':
                                    print('The email address is not valid.');
                                    break;
                                  default:
                                    print('Login failed: ${e.message}');
                                }
                              });
                            } catch (e) {
                              // Gestione generica di altri errori
                              setState(() {
                                print('An unexpected error occurred: $e');
                              });
                            }
                          },
                          child: const Text('Login'),
                        ),
                      ],
                    );
                  }
                default:
                  return Text("Loading...");
              }
            }),
      ),
    );
  }
}
