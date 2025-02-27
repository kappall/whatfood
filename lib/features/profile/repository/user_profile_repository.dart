import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
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

  Stream<List<Post>> getUserSavedPosts(Set<String> savedPosts) {
    if (savedPosts.isEmpty) {
      return Stream.value([]);
    }

    return _posts
        .where('id', whereIn: savedPosts)
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

  FutureVoid deleteAccount() async {
    try {
      final user = _auth.currentUser!;
      final String uid = user.uid;

      // First delete all user's posts
      final userPosts = await _posts.where('uid', isEqualTo: uid).get();

      for (var doc in userPosts.docs) {
        await _posts.doc(doc.id).delete();
      }

      // Then delete all user's recipes
      final userRecipes = await _recipes.where('uid', isEqualTo: uid).get();

      for (var doc in userRecipes.docs) {
        await _recipes.doc(doc.id).delete();
      }

      // Delete user document
      await _users.doc(uid).delete();

      // Finally delete auth user
      await user.delete();

      return right(null);
    } on FirebaseAuthException catch (e) {
      return left(Failure(e.message ?? 'Firebase Auth Error'));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Future<void> followOrUnfollowUser(String uid, UserModel userToFollow) async {
    final isFollowing = userToFollow.followers.contains(uid);

    if (isFollowing) {
      await _users.doc(userToFollow.uid).update({
        'followers': FieldValue.arrayRemove([uid])
      });

      await _users.doc(uid).update({
        'following': FieldValue.arrayRemove([userToFollow.uid])
      });
    } else {
      await _users.doc(userToFollow.uid).update({
        'followers': FieldValue.arrayUnion([uid])
      });

      await _users.doc(uid).update({
        'following': FieldValue.arrayUnion([userToFollow.uid])
      });
    }
  }
}
