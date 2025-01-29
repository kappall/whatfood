import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatfood/button_styles.dart';
import 'package:whatfood/core/constants/costants.dart';
import 'package:whatfood/models/user_model.dart'; // Importa il modello UserModel

class ProfileDrawer extends ConsumerWidget {
  final User? user;
  final UserModel? userModel; // Aggiungi UserModel come parametro

  const ProfileDrawer({
    required this.user,
    this.userModel, // Passa i dati dell'utente
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
              child: const Text('Log out'),
            ),
          ],
        );
      },
    ).then((value) => value ?? false);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con l'immagine dell'utente e il banner
            UserAccountsDrawerHeader(
              currentAccountPicture: CircleAvatar(
                backgroundImage: NetworkImage(
                  userModel?.profilePic ?? Constants.avatarDefault,
                ),
              ),
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(
                    userModel?.banner ?? Constants.bannerDefault,
                  ),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.black.withAlpha(120),
                    BlendMode.darken,
                  ),
                ),
              ),
              accountName: Text(
                userModel?.name ?? user?.email ?? 'Guest User',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
              accountEmail: null,
            ),

            // Opzioni di navigazione
            if (user !=
                null) // Mostra queste opzioni solo se l'utente è loggato
              Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.person, color: Colors.black),
                    title: const Text('Profilo'),
                    onTap: () {
                      // Navigazione alla schermata del profilo
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.settings, color: Colors.black),
                    title: const Text('Impostazioni'),
                    onTap: () {
                      // Navigazione alla schermata delle impostazioni
                    },
                  ),
                  const Divider(),
                ],
              ),

            const Spacer(),
            if (user !=
                null) // Mostra il pulsante di logout solo se l'utente è loggato
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final shouldLogOut = await showLogOutDialog(context);
                    if (shouldLogOut) {
                      await FirebaseAuth.instance.signOut();
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        '/login/',
                        (_) => false,
                      );
                    }
                  },
                  icon: const Icon(Icons.logout, color: Colors.white),
                  label: const Text('Logout',
                      style: TextStyle(color: Colors.white)),
                  style: ButtonStyles.elevatedButtonStyle(
                      backgroundColor: Colors.red),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
