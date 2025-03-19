import 'package:flutter/material.dart';
import 'package:routemaster/routemaster.dart';
import 'package:whatfood/features/auth/views/login_view.dart';
import 'package:whatfood/features/auth/views/register_view.dart';
import 'package:whatfood/features/post/views/add_post_type_view.dart';
import 'package:whatfood/features/post/views/comment_view.dart';
import 'package:whatfood/features/preferences/views/preferences_view.dart';
import 'package:whatfood/features/profile/views/edit_profile_view.dart';
import 'package:whatfood/features/profile/views/user_posts_list_view.dart';
import 'package:whatfood/features/profile/views/profile_view.dart';
import 'package:whatfood/features/recipes/views/add_recipe_view.dart';
import 'package:whatfood/features/recipes/views/edit_recipe_view.dart';
import 'package:whatfood/pages/start_page.dart';

final loggedInRoutes = RouteMap(
  onUnknownRoute: (_) => MaterialPage(
      child: MainPage(
    isGuest: false,
  )),
  routes: {
    '/': (_) => const MaterialPage(child: MainPage(isGuest: false)),
    '/home': (_) => const MaterialPage(child: MainPage(isGuest: false)),
    '/preferences': (_) => const MaterialPage(
            child: PreferencesView(
          isFromProfile: true,
        )),
    '/login': (_) => const MaterialPage(child: LoginView()),
    '/register': (_) => const MaterialPage(child: RegisterView()),
    '/home/add_post_type/:type': (route) => MaterialPage(
        child: (route.pathParameters['type']!) == 'image'
            ? AddPostTypeView(
                type: route.pathParameters['type']!,
              )
            : AddRecipeView()),
    '/add-recipe': (_) => const MaterialPage(child: AddRecipeView()),
    '/edit-recipe/:id': (route) => MaterialPage(
        child: EditRecipeView(recipeId: route.pathParameters['id']!)),
    '/edit_profile/:uid': (route) => MaterialPage(
            child: EditProfileView(
          uid: route.pathParameters['uid']!,
        )),
    '/:id/comments': (route) => MaterialPage(
            child: CommentsView(
          postId: route.pathParameters['id']!,
        )),
    '/user_page/:uid': (route) => MaterialPage(
          child: SafeArea(
            child: Scaffold(
              extendBodyBehindAppBar: false,
              body:
                  ProfileView(uid: route.pathParameters['uid']!, public: true),
            ),
          ),
        ),
    '/profile': (_) => MaterialPage(child: ProfileView()),
    '/post_list/:uid': (route) =>
        MaterialPage(child: PostList(uid: route.pathParameters['uid']!)),
    '/post_list/:uid/:postid/comments': (route) => MaterialPage(
            child: CommentsView(
          postId: route.pathParameters['postid']!,
        )),
  },
);

final loggedOutRoutes = RouteMap(routes: {
  '/': (_) => const MaterialPage(child: LoginView()),
  '/login': (_) => const MaterialPage(child: LoginView()),
  '/register': (_) => const MaterialPage(child: RegisterView()),
  '/main_guest': (_) => const MaterialPage(child: MainPage(isGuest: true)),
});
