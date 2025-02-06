import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:whatfood/core/constants/costants.dart';
import 'package:whatfood/core/constants/firebase_constants.dart';
import 'package:whatfood/core/providers/firebase_providers.dart';
import 'package:whatfood/core/type_def.dart';
import 'package:whatfood/models/user_model.dart';
import 'package:whatfood/core/failure.dart';
import 'package:rxdart/rxdart.dart';

final authRepositoryProvider = Provider(
  (ref) => AuthRepository(
    firestore: ref.read(firestoreProvider),
    auth: ref.read(authProvider),
    googleSignIn: ref.read(googleSignInProvider),
  ),
);

class AuthRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;

  AuthRepository({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
    required GoogleSignIn googleSignIn,
  })  : _auth = auth,
        _firestore = firestore,
        _googleSignIn = googleSignIn;

  CollectionReference get _users =>
      _firestore.collection(FirebaseConstants.usersCollection);

  Stream<User?> get authStateChange => _auth.authStateChanges();

  FutureEither<UserModel> signInWithGoogle(bool isFromLogin) async {
    try {
      UserCredential userCredential;

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      final googleAuth = await googleUser?.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      if (isFromLogin) {
        userCredential = await _auth.signInWithCredential(credential);
      } else {
        userCredential =
            await _auth.currentUser!.linkWithCredential(credential);
      }

      UserModel userModel;

      if (userCredential.additionalUserInfo!.isNewUser) {
        userModel = UserModel(
          name: userCredential.user!.displayName ?? 'No Name',
          profilePic: userCredential.user!.photoURL ?? Constants.avatarDefault,
          banner: Constants.bannerDefault,
          uid: userCredential.user!.uid,
          isAuthenticated: true,
        );
        await _users.doc(userCredential.user!.uid).set(userModel.toMap());
      } else {
        userModel = await getUserData(userCredential.user!.uid).first;
      }
      return right(userModel);
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  FutureEither<UserModel> signInAsGuest() async {
    try {
      var userCredential = await _auth.signInAnonymously();

      UserModel userModel = UserModel(
        name: 'Guest',
        profilePic: Constants.avatarDefault,
        banner: Constants.bannerDefault,
        uid: userCredential.user!.uid,
        isAuthenticated: false,
      );

      await _users.doc(userCredential.user!.uid).set(userModel.toMap());

      return right(userModel);
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Stream<UserModel> getUserData(String uid) {
    return _users.doc(uid).snapshots().map((event) {
      final data = event.data();

      if (data == null) {
        throw Exception("User document for uid: $uid not found in Firestore.");
      }

      try {
        return UserModel.fromMap(data as Map<String, dynamic>);
      } catch (e) {
        throw Exception("Error parsing user data: $e");
      }
    });
  }

  void logOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
