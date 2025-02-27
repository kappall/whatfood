import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';
import 'package:whatfood/core/common/error_text.dart';
import 'package:whatfood/core/common/loader.dart';
import 'package:whatfood/core/common/post_card_for_grid.dart';
import 'package:whatfood/features/auth/controller/auth_controller.dart';
import 'package:whatfood/features/profile/controller/user_profile_controller.dart';

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
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabChange);
  }

  void _handleTabChange() {
    if (_mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _mounted = false;
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  void navigateToEditUser(BuildContext context) {
    Routemaster.of(context).push('/edit_profile/${widget.uid}');
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

  void deleteUser(WidgetRef ref) {
    ref.read(userProfileControllerProvider.notifier).deleteUser();
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
            deleteUser(ref);
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

  @override
  Widget build(BuildContext context) {
    final String uid =
        widget.uid.isEmpty ? ref.read(userProvider)!.uid : widget.uid;
    return ref.watch(getUserDataProvider(uid)).when(
          data: (user) => Scaffold(
            appBar: AppBar(
              title: Text(user.name),
              actions: [if (!widget.public) popUpMenu(context, ref)],
            ),
            body: Column(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundImage: NetworkImage(user.profilePic),
                            radius: 45,
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.name,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (user.bio.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    user.bio,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ),
                              if (!widget.public)
                                Padding(
                                  padding: const EdgeInsets.only(top: 16),
                                  child: Row(
                                    children: [
                                      FilledButton(
                                        onPressed: () =>
                                            navigateToEditUser(context),
                                        style: FilledButton.styleFrom(
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
                        unselectedLabelColor: Colors.grey,
                        controller: _tabController,
                        indicatorWeight: 3,
                        indicatorSize: TabBarIndicatorSize.tab,
                        tabs: const [
                          Tab(
                            icon: Icon(Icons.grid_on),
                            iconMargin: EdgeInsets.only(bottom: 4),
                          ),
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
                    children: [
                      UserPosts(uid: uid),
                      const Center(
                        child: Text('Your shopping cart'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          error: (error, stackTrace) => ErrorText(error: error.toString()),
          loading: () => const Loader(),
        );
  }
}

class UserPosts extends ConsumerWidget {
  final String uid;
  const UserPosts({super.key, required this.uid});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(getUserPostsProvider(uid)).when(
          data: (posts) {
            return GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
              ),
              itemCount: posts.length,
              itemBuilder: (context, index) {
                final post = posts[index];
                return PostCard(post: post);
              },
            );
          },
          error: (error, stackTrace) => ErrorText(error: error.toString()),
          loading: () => const Loader(),
        );
  }
}
