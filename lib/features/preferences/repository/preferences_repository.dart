import 'dart:convert';

import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:whatfood/core/providers/aws_providers.dart';
import 'package:whatfood/core/failure.dart';

final preferencesRepositoryProvider = Provider(
  (ref) => PreferencesRepository(
    auth: ref.read(authProvider),
    googleSignIn: ref.read(googleSignInProvider),
  ),
);

class PreferencesRepository {
  final AmplifyAuthCognito _auth;

  PreferencesRepository({
    required AmplifyAuthCognito auth,
    required GoogleSignIn googleSignIn,
  }) : _auth = auth;

  Future<Either<Failure, void>> updateUserPreferences({
    required String uid,
    required List<String> newPreferences,
  }) async {
    // Definisci la mutation con variabili
    String updateMutation = '''
    mutation UpdateUserPreferences(\$id: ID!, \$preferences: [String!]!) {
      updateUser(input: { id: "$uid", preferences: ${jsonEncode(newPreferences)} }) {
        id
        preferences
      }
    }
  ''';

    // Crea una GraphQLRequest
    final request = GraphQLRequest<String>(document: updateMutation);

    try {
      await Amplify.API.mutate(request: request).response;
      // Controlla eventuali errori o gestisci la risposta
      return right(null);
    } on ApiException catch (e) {
      return left(Failure(e.message));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }
}
