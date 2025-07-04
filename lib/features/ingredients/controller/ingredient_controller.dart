import 'dart:io';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';
import 'package:whatfood/core/providers/storage_repository_provider.dart';
import 'package:whatfood/core/utils.dart';
import 'package:whatfood/features/ingredients/repository/ingredients_repository.dart';
import 'package:whatfood/models/Ingredient.dart';

final IngredientControllerProvider =
    StateNotifierProvider<IngredientController, bool>((ref) {
  final IngredientRepository = ref.watch(ingredientRepositoryProvider);
  final storageRepository = ref.watch(storageRepositoryProvider);
  return IngredientController(
    IngredientRepository: IngredientRepository,
    ref: ref,
    storageRepository: storageRepository,
  );
});

final ingredientsProvider = StreamProvider((ref) {
  final ingredientController = ref.watch(IngredientControllerProvider.notifier);

  return ingredientController.fetchIngredients();
});

final ingredientByIdProvider = StreamProvider.family((ref, String id) {
  final posController = ref.watch(IngredientControllerProvider.notifier);
  return posController.getIngredientById(id);
});

class IngredientController extends StateNotifier<bool> {
  final IngredientRepository _ingredientRepository;
  final StorageRepository _storageRepository;

  IngredientController({
    required IngredientRepository IngredientRepository,
    required StorageRepository storageRepository,
    required Ref ref,
  })  : _ingredientRepository = IngredientRepository,
        _storageRepository = storageRepository,
        super(false);
  Stream<List<Ingredient>> fetchIngredients() {
    return _ingredientRepository.fetchIngredients();
  }

/*
  void likeOrUnlike(Ingredient ingredient) async {
    final uid = _ref.read(userProvider)!.uid;
    _IngredientRepository.likeOrUnlike(ingredient, uid);
  }*/

  Stream<Ingredient> getIngredientById(String id) {
    return _ingredientRepository.getIngredientById(id);
  }

  void updateIngredient({
    required BuildContext context,
    required String ingredientId,
    required String name,
    required String description,
    required List<String> tips,
    required List<String> similars,
    required List<String> shops,
    required List<String> recipes,
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
          ingredientId,
          'images',
          name,
          contentType: 'image/jpeg',
        );

        imageUrl = res;
      }

      final ingredient = Ingredient(
        id: ingredientId,
        name: name,
        description: description,
        tips: tips.where((i) => i.isNotEmpty).toList(),
        shops: shops.where((i) => i.isNotEmpty).toList(),
        similars: similars.where((i) => i.isNotEmpty).toList(),
        recipes: recipes.where((i) => i.isNotEmpty).toList(),
        coverImage: imageUrl,
        createdAt: TemporalDateTime.now(),
        likes: likes,
      );

      final res = await _ingredientRepository.updateIngredient(ingredient);

      state = false;

      res.fold(
        (failure) => showSnackBar(context, failure.message),
        (_) {
          showSnackBar(context, 'Ingredient updated successfully!');
          Routemaster.of(context).popUntil((route) => route.path == '/');
        },
      );
    } catch (e) {
      state = false;
      if (context.mounted) showSnackBar(context, e.toString());
    }
  }
}
