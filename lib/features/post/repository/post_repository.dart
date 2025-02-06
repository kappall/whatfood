import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:whatfood/core/constants/firebase_constants.dart';
import 'package:whatfood/core/failure.dart';
import 'package:whatfood/core/providers/firebase_providers.dart';
import 'package:whatfood/core/type_def.dart';

import 'package:whatfood/models/post_model.dart';

final postRepositoryProvider = Provider((ref) {
  return PostRepository(firebaseFirestore: ref.watch(firestoreProvider));
});

class PostRepository {
  final FirebaseFirestore _firebaseFirestore;
  PostRepository({
    required firebaseFirestore,
  }) : _firebaseFirestore = firebaseFirestore;

  CollectionReference get _posts =>
      _firebaseFirestore.collection(FirebaseConstants.postsCollection);

  FutureVoid addPost(Post post) async {
    try {
      return right(_posts.doc(post.id).set(post.toMap()));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }
}
