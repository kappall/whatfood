import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:whatfood/core/constants/firebase_constants.dart';
import 'package:whatfood/core/failure.dart';
import 'package:whatfood/core/providers/firebase_providers.dart';
import 'package:whatfood/core/type_def.dart';
import 'package:whatfood/models/comment_model.dart';
import 'package:whatfood/models/post_model.dart';
import 'package:whatfood/models/user_model.dart';

final postRepositoryProvider = Provider((ref) {
  return PostRepository(
    firestore: ref.watch(firestoreProvider),
  );
});

class PostRepository {
  final FirebaseFirestore _firestore;
  PostRepository({required FirebaseFirestore firestore})
      : _firestore = firestore;

  CollectionReference get _posts =>
      _firestore.collection(FirebaseConstants.postsCollection);
  CollectionReference get _comments =>
      _firestore.collection(FirebaseConstants.commentsCollection);
  CollectionReference get _users =>
      _firestore.collection(FirebaseConstants.usersCollection);

  FutureVoid addPost(Post post) async {
    try {
      final batch = _firestore.batch();

      batch.set(_posts.doc(post.id), post.toMap());

      batch.update(_users.doc(post.uid), {
        'postsCount': FieldValue.increment(1),
      });

      await batch.commit();
      return right(null);
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Stream<List<Post>> fetchPosts() {
    return _posts
        .orderBy(
          'createdAt',
          descending: true,
        )
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => Post.fromMap(doc.data() as Map<String, dynamic>),
              )
              .toList(),
        );
  }

  Stream<Post> fetchPostById(String postId) {
    return _posts
        .doc(postId)
        .snapshots()
        .map((event) => Post.fromMap(event.data() as Map<String, dynamic>));
  }

  FutureVoid addComment(Comment comment) async {
    try {
      await _comments.doc(comment.id).set(comment.toMap());

      return right(_posts.doc(comment.postId).update({
        'commentCount': FieldValue.increment(1),
      }));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  FutureVoid deleteComment(String commentId, String postId) async {
    try {
      await _comments.doc(commentId).delete();

      return right(_posts.doc(postId).update({
        'commentCount': FieldValue.increment(-1),
      }));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Stream<List<Comment>> getCommentsOfPost(String postId) {
    return _comments
        .where('postId', isEqualTo: postId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (event) => event.docs
              .map(
                (e) => Comment.fromMap(
                  e.data() as Map<String, dynamic>,
                ),
              )
              .toList(),
        );
  }

  FutureVoid deletePost(String id, String uid) async {
    try {
      final batch = _firestore.batch();

      batch.delete(_posts.doc(id));

      batch.update(_users.doc(uid), {
        'postsCount': FieldValue.increment(-1),
      });
      await batch.commit();
      return right(null);
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  void likeOrUnlike(Post post, String uid) async {
    if (post.likes.contains(uid)) {
      _posts.doc(post.id).update({
        'likes': FieldValue.arrayRemove([uid])
      });
    } else {
      _posts.doc(post.id).update({
        'likes': FieldValue.arrayUnion([uid])
      });
    }
  }

  Future<void> addOrRemoveBookmark(Post post, UserModel user) async {
    if (user.savedPosts.contains(post.id)) {
      _users.doc(user.uid).update({
        'savedPosts': FieldValue.arrayRemove([post.id])
      });
    } else {
      _users.doc(user.uid).update({
        'savedPosts': FieldValue.arrayUnion([post.id])
      });
    }
  }

  Stream<Post> getPostById(String id) {
    return _posts
        .doc(id)
        .snapshots()
        .map((e) => Post.fromMap(e.data() as Map<String, dynamic>));
  }

  Future<String> getUserName(String uid) async {
    final doc = await _users.doc(uid).get();
    final data = doc.data() as Map<String, dynamic>?;
    return data?['name'] ?? 'Unknown';
  }
}
