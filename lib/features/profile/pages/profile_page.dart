import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';
import 'package:whatfood/button_styles.dart';
import 'package:whatfood/core/common/error_text.dart';
import 'package:whatfood/core/common/loader.dart';
import 'package:whatfood/features/auth/controller/auth_controller.dart';

class ProfilePage extends ConsumerWidget {
  final String uid;

  const ProfilePage({
    required this.uid,
    super.key,
  });

  void navigateToEditUser(BuildContext context) {
    Routemaster.of(context).push('/main_page/edit_profile/$uid');
  }

  Future<bool> showLogOutDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Sign out',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text('Are you sure you want to sign out?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Log out',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    ).then((value) => value ?? false);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: ref.watch(getUserDataProvider(uid)).when(
            data: (user) => SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      Image.network(
                        user.banner,
                        height: 250,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                      Positioned(
                        bottom: 60,
                        left: 30,
                        child: CircleAvatar(
                          backgroundImage: NetworkImage(user.profilePic),
                          radius: 45,
                        ),
                      ),
                      Positioned(
                        bottom: 5,
                        left: 10,
                        child: OutlinedButton(
                          onPressed: () => navigateToEditUser(context),
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 25),
                          ),
                          child: const Text(
                            'Edit Profile',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      )
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.name,
                          style: const TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Divider(thickness: 2),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text('Additional content goes here'),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () async {
                          final shouldLogout = await showLogOutDialog(context);
                          if (shouldLogout) {
                            FirebaseAuth.instance.signOut();
                          }
                        },
                        style: ButtonStyles.elevatedButtonStyle(
                          size: const Size(120, 40),
                          backgroundColor: Colors.red,
                        ),
                        child: const Text('Logout'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            error: (error, stackTrace) => ErrorText(error: error.toString()),
            loading: () => const Loader(),
          ),
    );
  }
}
