import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:whatfood/core/constants/costants.dart';
import 'package:whatfood/core/constants/firebase_constants.dart';
import 'package:whatfood/core/providers/firebase_providers.dart';
import 'package:whatfood/core/type_def.dart';
import 'package:whatfood/models/user_model.dart';
import 'package:whatfood/pages/controller/failure.dart';

final authRepositoryProvider = Provider((ref) => AuthRepository(
    firestore: ref.read(firestoreProvider),
    auth: ref.read(authProvider),
    googleSignIn: ref.read(googleSignInProvider)));

class AuthRepository {
  FirebaseFirestore _firestore;
  FirebaseAuth _auth;
  GoogleSignIn _googleSignIn;

  AuthRepository({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
    required GoogleSignIn googleSignIn,
  })  : _auth = auth,
        _firestore = firestore,
        _googleSignIn = googleSignIn;

  CollectionReference get _users =>
      _firestore.collection(FirebaseConstants.usersCollection);

  FutureEither<UserModel> signInWithGoogle(bool isFromLogin) async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      final googleAuth = await googleUser?.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );
      UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      if (isFromLogin) {
        userCredential = await _auth.signInWithCredential(credential);
      } else {
        userCredential =
            await _auth.currentUser!.linkWithCredential(credential);
      }

      UserModel userModel;
      final user = userCredential.user;
      if (userCredential.additionalUserInfo!.isNewUser) {
        userModel = UserModel(
            name: user!.displayName ?? 'Anonymus',
            profilePic: user.photoURL ?? Constants.avatarDefault,
            banner: Constants.bannerDefault,
            uid: user.uid,
            isAuthenticated: true);

        await _users.doc(user.uid).set(userModel.toMap());
      } else {
        userModel = await getUserData(user!.uid).first;
      }
      return right(userModel);
    } on FirebaseException catch (e) {
      return left(Failure('Firebase exception occurred: ${e.message}'));
    } catch (e) {
      return left(Failure('Unexpected error: ${e.toString()}'));
    }
  }

  Stream<UserModel> getUserData(String uid) {
    return _users.doc(uid).snapshots().map(
        (event) => UserModel.fromMap(event.data() as Map<String, dynamic>));
  }
}
