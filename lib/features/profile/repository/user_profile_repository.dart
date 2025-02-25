import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:whatfood/core/constants/firebase_constants.dart';
import 'package:whatfood/core/failure.dart';
import 'package:whatfood/core/providers/firebase_providers.dart';
import 'package:whatfood/core/type_def.dart';
import 'package:whatfood/models/post_model.dart';
import 'package:whatfood/models/recipe_model.dart';
import 'package:whatfood/models/user_model.dart';

final userProfileRepositoryProvider = Provider((ref) {
  return UserProfileRepository(
      firestore: ref.watch(firestoreProvider), auth: ref.read(authProvider));
});

class UserProfileRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  UserProfileRepository(
      {required FirebaseFirestore firestore, required FirebaseAuth auth})
      : _firestore = firestore,
        _auth = auth;

  CollectionReference get _users =>
      _firestore.collection(FirebaseConstants.usersCollection);
  CollectionReference get _recipes =>
      _firestore.collection(FirebaseConstants.recipesCollection);
  CollectionReference get _posts =>
      _firestore.collection(FirebaseConstants.postsCollection);

  FutureVoid editProfile(UserModel user) async {
    try {
      return right(_users.doc(user.uid).update(user.toMap()));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Stream<List<Post>> getUserPosts(String uid) {
    return _posts
        .where('uid', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (event) => event.docs
              .map(
                (e) => Post.fromMap(
                  e.data() as Map<String, dynamic>,
                ),
              )
              .toList(),
        );
  }

  void logOut() async {
    await _auth.signOut();
  }

  FutureVoid deleteAcoount() async {
    try {
      final user = _auth.currentUser!;
      String uid = user.uid;
      await _auth.signOut();
      await _auth.currentUser!.delete();
      final List<Post> userPosts = await _posts
          .where('uid', isEqualTo: uid)
          .snapshots()
          .map(
            (event) => event.docs
                .map(
                  (e) => Post.fromMap(
                    e.data() as Map<String, dynamic>,
                  ),
                )
                .toList(),
          )
          .first;
      for (var post in userPosts) {
        await _posts.doc(post.id).delete();
      }
      final List<Recipe> userRecipes = await _recipes
          .where('uid', isEqualTo: uid)
          .snapshots()
          .map(
            (event) => event.docs
                .map(
                  (e) => Recipe.fromMap(
                    e.data() as Map<String, dynamic>,
                  ),
                )
                .toList(),
          )
          .first;
      for (var post in userRecipes) {
        await _recipes.doc(post.id).delete();
      }
      _users.doc(uid).delete();
      return right(null);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }
}
