import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatfood/button_styles.dart';
import 'package:whatfood/core/constants/costants.dart';
import 'package:whatfood/models/user_model.dart';

class ProfilePage extends ConsumerWidget {
  final User? user;
  final UserModel? userModel;

  const ProfilePage({
    required this.user,
    this.userModel,
    super.key,
  });

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
    return Column(
      children: [
        AppBar(
          title: const Text(
            'Profile',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          flexibleSpace: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(
                      userModel?.banner ?? Constants.bannerDefault,
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                top: 50,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage(
                    userModel?.profilePic ?? Constants.avatarDefault,
                  ),
                ),
              ),
            ],
          ),
        ),
        Column(
          children: [
            const SizedBox(height: 16),
            Text(
              userModel?.name ?? user?.email ?? 'Guest User',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('About'),
              onTap: () {},
            ),
          ],
        ),
        Expanded(child: Container()),
        Padding(
          padding: EdgeInsets.all(10),
          child: ElevatedButton.icon(
            onPressed: () async {
              final shouldLogOut = await showLogOutDialog(context);
              if (shouldLogOut) {
                await FirebaseAuth.instance.signOut();
                Navigator.of(context)
                    .pushNamedAndRemoveUntil('/login/', (_) => false);
              }
            },
            icon: const Icon(Icons.logout),
            label: const Text('Logout'),
            style:
                ButtonStyles.elevatedButtonStyle(backgroundColor: Colors.red),
          ),
        ),
      ],
    );
  }
}
