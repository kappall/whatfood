import 'dart:convert';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:whatfood/core/failure.dart';

final preferencesRepositoryProvider = Provider(
  (ref) => PreferencesRepository(),
);

class PreferencesRepository {
  Future<Either<Failure, void>> updateUserPreferences({
    required String uid,
    required List<String> newPreferences,
  }) async {
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
