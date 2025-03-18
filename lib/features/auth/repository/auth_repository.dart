import 'dart:convert';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:uuid/uuid.dart';
import 'package:whatfood/core/constants/costants.dart';
import 'package:whatfood/core/type_def.dart';
import 'package:whatfood/core/failure.dart';
import 'package:whatfood/models/User.dart';

final authRepositoryProvider = Provider(
  (ref) => AuthRepository(),
);

class AuthRepository {
  Future<String?> getCurrentUserId() async {
    try {
      var user = await Amplify.Auth.getCurrentUser();
      return user.userId;
    } catch (e) {
      return null;
    }
  }

  FutureEither<User> signInAsGuest() async {
    try {
      final username = 'guest_user';
      final password = 'guest_placeholder_password';

      SignInResult signInResult = await Amplify.Auth.signIn(
        username: username,
        password: password,
      );

      if (signInResult.isSignedIn) {
        User userModel = User(
            name: 'Guest',
            profilePic: Constants.avatarDefault,
            banner: Constants.bannerDefault,
            id: Uuid().v4(),
            preferences: [],
            savedPosts: [],
            postsCount: 0,
            dailyIntake: 0,
            followers: [],
            following: [],
            bio: '',
            email: 'Guest email placeholder');

        return right(userModel);
      } else {
        return left(Failure("Sign in not complete"));
      }
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  FutureEither<User> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final result = await Amplify.Auth.signIn(
        username: email,
        password: password,
      );

      if (result.isSignedIn) {
        final userId = (await Amplify.Auth.getCurrentUser()).userId;
        User? userModel = await getUserData(userId);

        if (userModel == null) {
          return left(Failure("User data not found."));
        }

        return right(userModel);
      } else {
        return left(Failure("Sign-in failed"));
      }
    } on AuthException catch (e) {
      return left(Failure(e.message));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  FutureEither<SignUpResult> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final signUpResult = await Amplify.Auth.signUp(
        username: email,
        password: password,
        options: SignUpOptions(
          userAttributes: {
            AuthUserAttributeKey.email: email,
            AuthUserAttributeKey.name: name,
          },
        ),
      );
      return right(signUpResult);
    } on AuthException catch (e) {
      return left(Failure(e.message));
    } catch (e) {
      print(e.toString());
      return left(Failure(e.toString()));
    }
  }

  Future<void> saveUserData(User user) async {
    try {
      // Definizione della mutation con variabili GraphQL
      const String graphQLDocument = '''
    mutation CreateUser(\$input: CreateUserInput!) {
      createUser(input: \$input) {
        id
      }
    }
    ''';

      // Costruzione dell'oggetto di variabili da passare alla mutation
      final Map<String, dynamic> variables = {
        "input": {
          "id": user.id,
          "name": user.name,
          "email": user.email,
          "profilePic": user.profilePic,
          "banner": user.banner,
          "preferences": user.preferences.toList(),
          "savedPosts": user.savedPosts.toList(),
          "postsCount": user.postsCount,
          "dailyIntake": user.dailyIntake,
          "followers": user.followers.toList(),
          "following": user.following.toList(),
          "bio": user.bio,
        }
      };

      // Creazione della richiesta GraphQL con variabili
      var operation = Amplify.API.mutate(
        request: GraphQLRequest<String>(
          document: graphQLDocument,
          variables: variables, // Passiamo le variabili separatamente
        ),
      );

      // Attendi la risposta dell'API
      final response = await operation.response;

      // Gestione degli errori di GraphQL
      if (response.errors.isNotEmpty) {
        throw Exception(response.errors.first.message);
      }

      debugPrint("User data saved successfully!");
    } catch (e) {
      debugPrint("Error saving user: $e");
      rethrow;
    }
  }

  Future<User?> getUserData(String userId) async {
    try {
      String graphQLDocument = '''
      query GetUser {
        getUser(id: "$userId") {
          id
          name
          email
          profilePic
          banner
          preferences
          savedPosts
          postsCount
          dailyIntake
          followers
          following
          bio
        }
      }
    ''';

      var operation = Amplify.API.query(
        request: GraphQLRequest<String>(document: graphQLDocument),
      );

      var response = await operation.response;
      //debugPrint(response.data.toString());
      var data = response.data;

      if (data == null) {
        return null;
      }
      var json = jsonDecode(data)['getUser'];
      final user = User.fromJson(json);
      return user;
    } catch (e) {
      print("Error fetching user: $e");
      return null;
    }
  }

  Future<bool> isUserSignedIn() async {
    try {
      final userId = await getCurrentUserId();
      return userId != null;
    } catch (e) {
      return false;
    }
  }

  Future<void> signOut() async {
    try {
      await Amplify.Auth.signOut();
    } catch (e) {
      print('Error signing out: $e');
    }
  }
}
