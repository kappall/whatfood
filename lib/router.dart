import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:routemaster/routemaster.dart';
import 'package:whatfood/features/auth/views/login_view.dart';
import 'package:whatfood/features/auth/views/register_view.dart';
import 'package:whatfood/features/auth/views/verify_email_view.dart';
import 'package:whatfood/features/post/views/add_post_view.dart';
import 'package:whatfood/features/post/views/add_post_type_view.dart';
import 'package:whatfood/features/post/views/comment_view.dart';
import 'package:whatfood/features/preferences/views/preferences_view.dart';
import 'package:whatfood/features/profile/views/edit_profile_view.dart';
import 'package:whatfood/features/profile/views/user_posts_list_view.dart';
import 'package:whatfood/features/profile/views/profile_view.dart';
import 'package:whatfood/features/recipes/views/add_recipe_view.dart';
import 'package:whatfood/pages/start_page.dart';

final loggedInRoute = RouteMap(
  onUnknownRoute: (_) => MaterialPage(
      child: MainPage(
    isGuest: false,
  )),
  routes: {
    '/': (_) => const MaterialPage(child: MainPage(isGuest: false)),
    '/:preferences': (route) => MaterialPage(
        child: route.pathParameters['preferences'] == 'no'
            ? PreferencesView(isFromProfile: false)
            : MainPage(isGuest: false)),
    '/home': (_) => const MaterialPage(child: MainPage(isGuest: false)),
    '/preferences': (_) => const MaterialPage(
            child: PreferencesView(
          isFromProfile: true,
        )),
    '/login': (_) => const MaterialPage(child: LoginView()),
    '/register': (_) => const MaterialPage(child: RegisterView()),
    '/home/add_post': (_) => const MaterialPage(child: AddPostView()),
    '/home/add_post/add_post_type/:type': (route) => MaterialPage(
          child: AddPostTypeView(
            type: route.pathParameters['type']!,
          ),
        ),
    '/add-recipe': (_) => const MaterialPage(child: AddRecipeView()),
    '/edit_profile/:uid': (route) => MaterialPage(
            child: EditProfileView(
          uid: route.pathParameters['uid']!,
        )),
    '/post/:id/comments': (route) => MaterialPage(
            child: CommentsView(
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
                body: ProfileView(
                    uid: route.pathParameters['uid']!, public: false),
              ),
            ),
          ),
        ),
    '/profile': (_) => MaterialPage(child: ProfileView()),
    '/post_list/:uid': (route) =>
        MaterialPage(child: PostList(uid: route.pathParameters['uid']!)),
  },
);

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
