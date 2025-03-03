import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:whatfood/core/constants/firebase_constants.dart';
import 'package:whatfood/core/providers/firebase_providers.dart';
import 'package:whatfood/core/failure.dart';

final preferencesRepositoryProvider = Provider(
  (ref) => PreferencesRepository(
    firestore: ref.read(firestoreProvider),
    auth: ref.read(authProvider),
    googleSignIn: ref.read(googleSignInProvider),
  ),
);

class PreferencesRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  PreferencesRepository({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
    required GoogleSignIn googleSignIn,
  })  : _auth = auth,
        _firestore = firestore;

  CollectionReference get _users =>
      _firestore.collection(FirebaseConstants.usersCollection);

  Stream<User?> get authStateChange => _auth.authStateChanges();

  Future<Either<Failure, void>> updateUserPreferences({
    required String uid,
    required Set<String> newPreferences,
  }) async {
    try {
      await _users.doc(uid).update({
        'preferences': newPreferences.toList(),
      });
      return right(null);
    } on FirebaseException catch (e) {
      return left(Failure(e.message ?? "Unknown Firebase error"));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }
}
