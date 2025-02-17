import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';
import 'package:whatfood/button_styles.dart';
import 'package:whatfood/core/common/error_text.dart';
import 'package:whatfood/core/common/loader.dart';
import 'package:whatfood/core/common/post_card.dart';
import 'package:whatfood/features/auth/controller/auth_controller.dart';
import 'package:whatfood/features/profile/controller/user_profile_controller.dart';

class ProfilePage extends ConsumerWidget {
  final String uid;
  final bool public;

  const ProfilePage({
    required this.uid,
    required this.public,
    super.key,
  });

  void navigateToEditUser(BuildContext context) {
    Routemaster.of(context).push('/edit_profile/$uid');
  }

  void navigateToPreferences(BuildContext context) {
    Routemaster.of(context).push('/preferences');
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
    return ref.watch(getUserDataProvider(uid)).when(
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
                      bottom: public ? 30 : 60,
                      left: 30,
                      child: CircleAvatar(
                        backgroundImage: NetworkImage(user.profilePic),
                        radius: 45,
                      ),
                    ),
                    if (!public)
                      Positioned(
                        bottom: 5,
                        left: 10,
                        child: Row(
                          children: [
                            FilledButton(
                              onPressed: () => navigateToEditUser(context),
                              style: FilledButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 25),
                              ),
                              child: const Text('Edit Profile'),
                            ),
                            const SizedBox(width: 10),
                            FilledButton(
                              onPressed: () => navigateToPreferences(context),
                              style: FilledButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 25),
                              ),
                              child: const Text('Food Preferences'),
                            ),
                          ],
                        ),
                      )
                  ],
                ),
                if (!public)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              user.name,
                              style: const TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                final shouldLogout =
                                    await showLogOutDialog(context);
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
                        const Divider(thickness: 2),
                      ],
                    ),
                  ),
                ref.watch(getUserPostsProvider(uid)).when(
                      data: (posts) => ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: posts.length,
                        itemBuilder: (BuildContext context, int index) {
                          final post = posts[index];
                          return PostCard(post: post);
                        },
                      ),
                      error: (error, stackTrace) =>
                          ErrorText(error: error.toString()),
                      loading: () => const Loader(),
                    ),
              ],
            ),
          ),
          error: (error, stackTrace) => ErrorText(error: error.toString()),
          loading: () => const Loader(),
        );
  }
}
