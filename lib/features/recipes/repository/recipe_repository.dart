import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:whatfood/core/constants/firebase_constants.dart';
import 'package:whatfood/core/failure.dart';
import 'package:whatfood/core/providers/firebase_providers.dart';
import 'package:whatfood/core/type_def.dart';
import 'package:whatfood/models/recipe_model.dart';

final recipeRepositoryProvider = Provider((ref) {
  return RecipeRepository(
    firestore: ref.watch(firestoreProvider),
  );
});

class RecipeRepository {
  final FirebaseFirestore _firestore;
  RecipeRepository({required FirebaseFirestore firestore})
      : _firestore = firestore;

  CollectionReference get _recipes =>
      _firestore.collection(FirebaseConstants.recipesCollection);
  CollectionReference get _comments =>
      _firestore.collection(FirebaseConstants.commentsCollection);
  CollectionReference get _users =>
      _firestore.collection(FirebaseConstants.usersCollection);

  FutureVoid addRecipe(Recipe recipe) async {
    try {
      return right(_recipes.doc(recipe.id).set(recipe.toMap()));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Stream<List<Recipe>> fetchRecipes() {
    return _recipes
        .orderBy(
          'createdAt',
          descending: true,
        )
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => Recipe.fromMap(doc.data() as Map<String, dynamic>),
              )
              .toList(),
        );
  }

  FutureVoid deleteRecipe(String id) async {
    try {
      return right(_recipes.doc(id).delete());
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  void likeOrUnlike(Recipe recipe, String uid) async {
    if (recipe.likes.contains(uid)) {
      _recipes.doc(recipe.id).update({
        'likes': FieldValue.arrayRemove([uid])
      });
    } else {
      _recipes.doc(recipe.id).update({
        'likes': FieldValue.arrayUnion([uid])
      });
    }
  }

  Stream<Recipe> getRecipeById(String id) {
    return _recipes
        .doc(id)
        .snapshots()
        .map((e) => Recipe.fromMap(e.data() as Map<String, dynamic>));
  }
}
