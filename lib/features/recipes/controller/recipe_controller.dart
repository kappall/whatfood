import 'dart:io';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';
import 'package:uuid/uuid.dart';
import 'package:whatfood/core/providers/storage_repository_provider.dart';
import 'package:whatfood/core/utils.dart';
import 'package:whatfood/features/auth/controller/auth_controller.dart';
import 'package:whatfood/features/recipes/repository/recipe_repository.dart';
import 'package:whatfood/models/Recipe.dart';
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

final recpiesProvider = FutureProvider((ref) {
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
  Future<List<Recipe>> fetchRecipes() {
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

    String recipeId = const Uuid().v4();
    String coverImageUrl = '';

    try {
      final imageId = const Uuid().v4();
      final result = await _storageRepository.uploadImage(
        image,
        recipeId,
      );

      final imageUrl = result;

      coverImageUrl = imageUrl;

      final Recipe recipe = Recipe(
          id: recipeId,
          title: title,
          uid: user.uid,
          coverImage: coverImageUrl,
          createdAt: TemporalDateTime.now(),
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
/*
  void likeOrUnlike(Recipe recipe) async {
    final uid = _ref.read(userProvider)!.uid;
    _recipeRepository.likeOrUnlike(recipe, uid);
  }*/

  Future<Recipe?> getRecipeById(String id) async {
    final res = await _recipeRepository.getRecipeById(id);
    return res;
  }

  void updateRecipe({
    required BuildContext context,
    required String recipeId,
    required String title,
    required String description,
    required List<String> instructions,
    required List<String> ingredients,
    required String servings,
    required String cookTimeMinutes,
    required List<String> likes,
    File? newImage,
    String? existingImageUrl,
  }) async {
    state = true;

    try {
      String imageUrl = existingImageUrl ?? '';

      if (newImage != null) {
        final res = await _storageRepository.editFile(
          newImage,
          recipeId,
          'images',
          title,
          contentType: 'image/jpeg',
        );

        imageUrl = res;
      }
      final user = _ref.read(userProvider)!;

      final recipe = Recipe(
        id: recipeId,
        title: title,
        description: description,
        userImage: user.profilePic,
        username: user.name,
        instructions: instructions.where((i) => i.isNotEmpty).toList(),
        ingredients: ingredients.where((i) => i.isNotEmpty).toList(),
        servings: servings,
        cookTimeMinutes: cookTimeMinutes,
        coverImage: imageUrl,
        uid: _ref.read(userProvider)!.uid,
        createdAt: TemporalDateTime.now(),
        likes: likes,
      );

      final res = await _recipeRepository.updateRecipe(recipe);

      state = false;

      res.fold(
        (failure) => showSnackBar(context, failure.message),
        (_) {
          showSnackBar(context, 'Recipe updated successfully!');
          Routemaster.of(context).pop();
        },
      );
    } catch (e) {
      state = false;
      if (context.mounted) showSnackBar(context, e.toString());
    }
  }
}
