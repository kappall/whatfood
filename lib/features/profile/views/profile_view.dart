import 'dart:convert';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';
import 'package:whatfood/core/common/error_text.dart';
import 'package:whatfood/core/common/loader.dart';
import 'package:whatfood/core/common/post_card_for_grid.dart';
import 'package:whatfood/features/auth/controller/auth_controller.dart';
import 'package:whatfood/features/profile/controller/user_profile_controller.dart';
import 'package:whatfood/models/Post.dart';
import 'package:whatfood/models/User.dart';

class ProfileView extends ConsumerStatefulWidget {
  final String uid;
  final bool public;

  const ProfileView({
    this.uid = '',
    this.public = false,
    super.key,
  });

  @override
  ConsumerState<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends ConsumerState<ProfileView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _mounted = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: widget.public ? 1 : 2, vsync: this);
    _tabController.addListener(_handleTabChange);
  }

  void _handleTabChange() {
    // no set state for optimization
    // set state whould make the user post reload, dosen't make any sense
  }

  @override
  void dispose() {
    _mounted = false;
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  void navigateToEditUser(BuildContext context, User user) {
    final userJson = jsonEncode(user.toJson());
    final encodedUser = Uri.encodeComponent(userJson);
    Routemaster.of(context).push('edit_profile/$encodedUser');
  }

  void navigateToPreferences(BuildContext context) {
    Routemaster.of(context).push('preferences');
  }

  Future<bool> showOutDialog(
      BuildContext context, String title, String prompt) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text(prompt),
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
                'confirm',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    ).then((value) => value ?? false);
  }

  void logout(WidgetRef ref) {
    ref.read(userProfileControllerProvider.notifier).logout();
  }

  void deleteUser(BuildContext context, WidgetRef ref) {
    ref.read(userProfileControllerProvider.notifier).deleteUser(context);
  }

  Widget popUpMenu(BuildContext context, WidgetRef ref) {
    return PopupMenuButton<String>(
      offset: const Offset(0, 50),
      icon: Icon(Icons.settings),
      onSelected: (String value) async {
        if (value == 'logout') {
          final shouldLogout = await showOutDialog(
              context, 'Sign Out', 'Are you sure you want to sign out?');
          if (shouldLogout) {
            logout(ref);
          }
        } else if (value == 'delete') {
          final shouldDelete = await showOutDialog(context, 'Delete Account',
              'This action is irreversible. Are you sure you want to delete your account?');
          if (shouldDelete) {
            // ignore: use_build_context_synchronously
            deleteUser(context, ref);
          }
        } else if (value == 'Edit preferences') {
          navigateToPreferences(context);
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        PopupMenuItem<String>(
          value: 'logout',
          child: Row(
            children: [
              Icon(Icons.exit_to_app, color: Colors.green),
              SizedBox(width: 8),
              Text(
                "Log out",
                style: TextStyle(color: Colors.green),
              ),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete, color: Colors.redAccent),
              SizedBox(width: 8),
              Text(
                "Delete Account",
                style: TextStyle(color: Colors.redAccent),
              ),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'Edit preferences',
          child: Row(
            children: [
              Icon(Icons.settings, color: Colors.blueAccent),
              SizedBox(width: 8),
              Text(
                "Edit Preferences",
                style: TextStyle(color: Colors.blueAccent),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void followOrUnfollowUser(BuildContext context, User user) {
    ref
        .read(userProfileControllerProvider.notifier)
        .followOrUnfollowUser(context, user);
  }

  @override
  Widget build(BuildContext context) {
    final String uid =
        widget.uid.isEmpty ? ref.read(userProvider)!.id : widget.uid;
    final String currUid = ref.read(userProvider)!.id;
    return ref.watch(getUserDataProvider(uid)).when(
          data: (user) {
            return Scaffold(
              appBar: AppBar(
                centerTitle: false,
                title: Text(
                  user.name + (widget.public ? '\'s Page' : ''),
                  style: TextStyle(fontSize: 16),
                ),
                actions: [if (!widget.public) popUpMenu(context, ref)],
              ),
              body: Column(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                CircleAvatar(
                                  backgroundImage:
                                      NetworkImage(user.profilePic),
                                  radius: 45,
                                ),
                                Row(
                                  children: [
                                    Column(
                                      children: [
                                        Text((user.postsCount).toString()),
                                        Text('posts')
                                      ],
                                    ),
                                    const SizedBox(width: 16),
                                    Column(
                                      children: [
                                        Text(
                                            (user.followers.length).toString()),
                                        Text('followers')
                                      ],
                                    ),
                                    const SizedBox(width: 16),
                                    Column(
                                      children: [
                                        Text(
                                            (user.following.length).toString()),
                                        Text('following')
                                      ],
                                    )
                                  ],
                                ),
                              ],
                            ),
                            if (user.bio!.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 16),
                                child: Row(
                                  children: [
                                    Text(
                                      user.bio!,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            Padding(
                              padding: const EdgeInsets.only(top: 16),
                              child: Row(
                                children: [
                                  if (currUid != uid) ...[
                                    FilledButton(
                                      onPressed: () =>
                                          followOrUnfollowUser(context, user),
                                      style: FilledButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 25),
                                      ),
                                      child: Text(
                                        user.followers.contains(currUid)
                                            ? 'Unfollow'
                                            : 'Follow',
                                      ),
                                    ),
                                    SizedBox(width: 16),
                                  ],
                                  if (!widget.public)
                                    FilledButton(
                                      onPressed: () =>
                                          navigateToEditUser(context, user),
                                      style: FilledButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 25),
                                      ),
                                      child: const Text('Edit Profile'),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Divider(thickness: 1),
                      Container(
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Theme.of(context).dividerColor,
                              width: 1,
                            ),
                          ),
                        ),
                        child: TabBar(
                          labelColor:
                              Theme.of(context).textTheme.bodyLarge?.color,
                          indicatorColor: Colors.white,
                          unselectedLabelColor: Colors.grey,
                          controller: _tabController,
                          indicatorWeight: 3,
                          indicatorSize: TabBarIndicatorSize.tab,
                          tabs: [
                            Tab(
                              icon: Icon(Icons.grid_on),
                              iconMargin: EdgeInsets.only(bottom: 4),
                            ),
                            if (!widget.public)
                              Tab(
                                icon: Icon(Icons.bookmark_outline),
                                iconMargin: EdgeInsets.only(bottom: 4),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Flexible(
                    fit: FlexFit.loose,
                    child: TabBarView(
                      controller: _tabController,
                      physics:
                          widget.public ? NeverScrollableScrollPhysics() : null,
                      children: [
                        ref.watch(getUserPostsProvider(uid)).when(
                              data: (posts) {
                                debugPrint("generating potst");
                                return UserPosts(uid: uid, posts: posts);
                              },
                              error: (error, stackTrace) {
                                debugPrint(error.toString());
                                return ErrorText(error: error.toString());
                              },
                              loading: () => const Loader(),
                            ),
                        if (!widget.public)
                          Builder(builder: (context) {
                            final userModel = ref.read(userProvider)!;
                            return ref
                                .read(getUserSavedPostsProvider(userModel))
                                .when(
                                  data: (posts) {
                                    return UserSavedPosts(
                                      posts: posts,
                                    );
                                  },
                                  error: (error, stackTrace) {
                                    debugPrint(error.toString());
                                    return ErrorText(error: error.toString());
                                  },
                                  loading: () => const Loader(),
                                );
                          }),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
          error: (error, stackTrace) {
            debugPrint(stackTrace.toString());
            return ErrorText(error: error.toString());
          },
          loading: () => const Loader(),
        );
  }
}

class UserSavedPosts extends ConsumerWidget {
  final List<Post> posts;
  const UserSavedPosts({super.key, required this.posts});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
      ),
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts[index];
        return FutureBuilder(
            future: Amplify.Storage.getUrl(
              path: StoragePath.fromString(post.imageUrl),
            ).result,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Loader();
              }
              if (snapshot.hasError) {
                return ErrorText(error: snapshot.error.toString());
              }
              if (!snapshot.hasData) {
                return const Loader();
              }
              String imageUrl = snapshot.data!.url.toString();
              return PostCard(
                post: post,
                imageUrl: imageUrl,
              );
            });
      },
    );
  }
}

class UserPosts extends ConsumerWidget {
  final String uid;
  final List<Post> posts;
  const UserPosts({super.key, required this.uid, required this.posts});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
      ),
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts[index];
        return FutureBuilder(
            future: Amplify.Storage.getUrl(
              path: StoragePath.fromString(post.imageUrl),
            ).result,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Loader();
              }
              if (snapshot.hasError) {
                return ErrorText(error: snapshot.error.toString());
              }
              if (!snapshot.hasData) {
                return const Loader();
              }
              String imageUrl = snapshot.data!.url.toString();
              return PostCard(post: post, imageUrl: imageUrl);
            });
      },
    );
  }
}
