import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';
import 'package:whatfood/features/auth/controller/auth_controller.dart';
import 'package:whatfood/features/auth/views/login_view.dart';
import 'package:whatfood/features/auth/views/register_view.dart';
import 'package:whatfood/features/auth/views/verify_email_view.dart';
import 'package:whatfood/features/post/pages/add_post_page.dart';
import 'package:whatfood/features/post/pages/add_post_type_page.dart';
import 'package:whatfood/features/post/pages/comment_page.dart';
import 'package:whatfood/features/preferences/views/preferences_view.dart';
import 'package:whatfood/features/profile/pages/edit_profile_page.dart';
import 'package:whatfood/features/profile/pages/profile_page.dart';
import 'package:whatfood/pages/start_page.dart';

class HomeRouteWidget extends ConsumerWidget {
  const HomeRouteWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isNewLogin = ref.watch(isNewLoginProvider);
    if (isNewLogin) {
      return const PreferencesView(
        isFromProfile: false,
      );
    }
    return const MainPage(isGuest: false);
  }
}

final loggedInRoute = RouteMap(
    onUnknownRoute: (_) => const MaterialPage(child: MainPage(isGuest: false)),
    routes: {
      '/': (_) => const MaterialPage(child: HomeRouteWidget()),
      '/home': (_) => const MaterialPage(child: MainPage(isGuest: false)),
      '/preferences': (_) => const MaterialPage(
              child: PreferencesView(
            isFromProfile: true,
          )),
      '/login': (_) => const MaterialPage(child: LoginView()),
      '/register': (_) => const MaterialPage(child: RegisterView()),
      '/add_post': (_) => const MaterialPage(child: AddPostPage()),
      '/add_post/add_post_type/:type': (route) => MaterialPage(
            child: AddPostTypePage(
              type: route.pathParameters['type']!,
            ),
          ),
      '/edit_profile/:uid': (route) => MaterialPage(
              child: EditProfilePage(
            uid: route.pathParameters['uid']!,
          )),
      '/post/:id/comments': (route) => MaterialPage(
              child: CommentsPage(
            postId: route.pathParameters['id']!,
          )),
      '/user_page/:uid': (route) => MaterialPage(
            child: SafeArea(
              child: Scaffold(
                extendBodyBehindAppBar: true,
                body: NestedScrollView(
                  headerSliverBuilder: (context, innerBoxIsScrolled) {
                    return [
                      SliverAppBar(
                        backgroundColor: Colors.grey[100],
                        elevation: 0,
                        title: const Text("User Profile"),
                      )
                    ];
                  },
                  body: ProfilePage(
                      uid: route.pathParameters['uid']!, public: true),
                ),
              ),
            ),
          ),
    });

final loggedOutRoute = RouteMap(routes: {
  '/': (_) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const MaterialPage(child: LoginView());
    } else {
      return const MaterialPage(child: VerifyEmailView());
    }
  },
  '/login': (_) => const MaterialPage(child: LoginView()),
  '/verify-email': (_) => const MaterialPage(child: VerifyEmailView()),
  '/register': (_) => const MaterialPage(child: RegisterView()),
  '/main_guest': (_) => const MaterialPage(child: MainPage(isGuest: true)),
});
