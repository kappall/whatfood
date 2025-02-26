import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';
import 'package:uuid/uuid.dart';
import 'package:whatfood/core/providers/storage_repository_provider.dart';
import 'package:whatfood/core/utils.dart';
import 'package:whatfood/features/auth/controller/auth_controller.dart';
import 'package:whatfood/features/recipes/repository/recipe_repository.dart';
import 'package:whatfood/models/recipe_model.dart';
import 'package:whatfood/features/profile/controller/user_profile_controller.dart';

final recipeControllerProvider =
    StateNotifierProvider<RecipeController, bool>((ref) {
  final recipeRepository = ref.watch(recipeRepositoryProvider);
  final storageRepository = ref.watch(storageRepositoryProvider);
  return RecipeController(
    recipeRepository: recipeRepository,
    ref: ref,
    storageRepository: storageRepository,
  );
});

final recpiesProvider = StreamProvider((ref) {
  final recipeController = ref.watch(recipeControllerProvider.notifier);

  return recipeController.fetchRecipes();
});

class RecipeController extends StateNotifier<bool> {
  final RecipeRepository _recipeRepository;
  final Ref _ref;
  final StorageRepository _storageRepository;

  RecipeController({
    required RecipeRepository recipeRepository,
    required StorageRepository storageRepository,
    required Ref ref,
  })  : _recipeRepository = recipeRepository,
        _storageRepository = storageRepository,
        _ref = ref,
        super(false);
  Stream<List<Recipe>> fetchRecipes() {
    return _recipeRepository.fetchRecipes();
  }

  void shareRecipe({
    required BuildContext context,
    required String title,
    required String description,
    required List<String> instructions,
    required List<String> ingredients,
    required String servings,
    required String cookTimeMinutes,
    required File image,
  }) async {
    state = true;
    final user = _ref.watch(userProvider);

    if (user == null) {
      showSnackBar(
        context,
        'User not logged in',
      );
      state = false;
      return;
    }

    String recipeId = const Uuid().v1();
    String coverImageUrl = '';

    try {
      final imageId = const Uuid().v1();
      final result = await _storageRepository.storeFile(
        path: 'recipes',
        id: imageId,
        file: image,
      );

      final imageUrl = result.fold(
        (l) => throw Exception(l.message),
        (r) => r,
      );

      coverImageUrl = imageUrl;

      final Recipe recipe = Recipe(
          id: recipeId,
          title: title,
          uid: user.uid,
          coverImage: coverImageUrl,
          createdAt: DateTime.now(),
          likes: [],
          description: description,
          ingredients: ingredients,
          instructions: instructions,
          servings: servings,
          cookTimeMinutes: cookTimeMinutes,
          userImage: user.profilePic,
          username: user.name);

      final res = await _recipeRepository.addRecipe(recipe);
      state = false;
      res.fold(
        (l) => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l.message)),
        ),
        (r) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Posted successfully!')),
          );
          Routemaster.of(context).popUntil((route) => route.path == '/');
        },
      );
    } catch (e) {
      state = false;
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  void deleteRecipe(String id, BuildContext context) async {
    final res = await _recipeRepository.deleteRecipe(id);
    _ref.read(userProfileControllerProvider.notifier);
    res.fold((l) => null,
        (r) => showSnackBar(context, 'Recipe Deleted successfully!'));
  }

  void likeOrUnlike(Recipe recipe) async {
    final uid = _ref.read(userProvider)!.uid;
    _recipeRepository.likeOrUnlike(recipe, uid);
  }
}
