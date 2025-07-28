import 'dart:async';
import 'dart:convert';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:http/http.dart' as http;
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

  Stream<User?> get authStateChange {
    final controller = StreamController<User?>();

    // Initial check
    isUserSignedIn().then((isSignedIn) async {
      if (isSignedIn) {
        final userId = await getCurrentUserId();
        if (userId != null) {
          final user = await getUserData(userId).first;
          controller.add(user);
        } else {
          controller.add(null);
        }
      } else {
        controller.add(null);
      }
    });

    // Listen to Amplify Hub events for auth state changes
    final subscription = Amplify.Hub.listen(HubChannel.Auth, (event) async {
      switch (event.type) {
        case AuthHubEventType.signedIn:
          final userId = await getCurrentUserId();
          if (userId != null) {
            final user = await getUserData(userId).first;
            controller.add(user);
          }
          break;
        case AuthHubEventType.signedOut:
          controller.add(null);
          break;
        default:
          break;
      }
    });

    // Clean up when the stream is cancelled
    controller.onCancel = () {
      subscription.cancel();
      controller.close();
    };

    return controller.stream;
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
            profilePic: null,
            banner: Constants.bannerDefault,
            id: Uuid().v4(),
            preferences: [],
            allergies: [],
            dislikes: [],
            goals: [],
            isOnboarded: false,
            email: 'Guest email placeholder',
            dailyIntake: 0);

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
        User? userModel = await getUserData(userId).first;

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
      return left(Failure(e.toString()));
    }
  }

  Future<void> deleteUnconfirmedUser(String email) async {
    final response = await http.post(
      Uri.parse(
          'https://nnszaho8de.execute-api.eu-north-1.amazonaws.com/delete-user'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': email}),
    );

    if (response.statusCode == 200) {
      print('User deleted');
    } else {
      print('Failed to delete user: ${response.body}');
    }
  }

  Future<void> saveUserData(User user) async {
    try {
      const String graphQLDocument = '''
    mutation CreateUser(\$input: CreateUserInput!) {
      createUser(input: \$input) {
        id
      }
    }
    ''';

      final Map<String, dynamic> variables = {
        "input": {
          "id": user.id,
          "name": user.name,
          "email": user.email,
          "profilePic": user.profilePic,
          "banner": user.banner,
          "preferences": user.preferences.toList(),
          "allergies": user.allergies.toList(),
          "goals": user.goals.toList(),
          "dislikes": user.dislikes.toList(),
          "dailyIntake": user.dailyIntake,
          "isOnboarded": user.isOnboarded,
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

  Stream<User> getUserData(String userId) {
    final controller = StreamController<User>();

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
          allergies
          goals
          dislikes
          dailyIntake
          isOnboarded
        }
      }
    ''';

      var operation = Amplify.API.query(
        request: GraphQLRequest<String>(document: graphQLDocument),
      );

      operation.response.then((response) {
        if (response.data == null) {
          return;
        }

        try {
          var json = jsonDecode(response.data!)['getUser'];
          final user = User.fromJson(json);
          controller.add(user);
        } catch (e) {
          debugPrint("Error parsing user data: $e");
          controller.addError(e);
        }
      }).catchError((error) {
        debugPrint("Error fetching user: $error");
        controller.addError(error);
      }).whenComplete(() {
        controller.close();
      });
    } catch (e) {
      controller.addError(e);
      controller.close();
    }

    return controller.stream;
  }

  Future<bool> isUserSignedIn() async {
    try {
      final session = await Amplify.Auth.fetchAuthSession();
      return session.isSignedIn;
    } on AuthException catch (e) {
      debugPrint('Error checking auth session: ${e.message}');
      return false;
    }
  }

  Future<void> deleteAccount(String uid) async {
    const String graphQLDocument = '''
      mutation DeleteUser(\$id: ID!) {
        deleteUser(input: { id: \$id }) {
          id
        }
      }
      ''';
    try {
      final response = await Amplify.API
          .mutate(
            request: GraphQLRequest<String>(
              document: graphQLDocument,
              variables: {'id': uid},
            ),
          )
          .response;

      if (response.hasErrors) {
        throw Exception(response.errors.first.message);
      }
      await Amplify.Auth.deleteUser();
    } catch (e) {
      rethrow;
    }
  }
}
