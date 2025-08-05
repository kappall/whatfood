import 'dart:convert';
import 'dart:io';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:routemaster/routemaster.dart';
import 'package:uuid/uuid.dart';
import 'package:whatfood/core/providers/storage_repository_provider.dart';
import 'package:whatfood/core/utils.dart';
import 'package:whatfood/features/auth/controller/auth_controller.dart';
import 'package:whatfood/features/recipes/repository/recipe_repository.dart';
import 'package:whatfood/models/Recipe.dart';

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

final recipesProvider = StreamProvider((ref) {
  final recipeController = ref.watch(recipeControllerProvider.notifier);

  return recipeController.fetchRecipes();
});

class MealFilter {
  final String mealType;
  final int maxMinutes;

  const MealFilter({
    required this.mealType,
    required this.maxMinutes,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MealFilter &&
          runtimeType == other.runtimeType &&
          mealType == other.mealType &&
          maxMinutes == other.maxMinutes;

  @override
  int get hashCode => mealType.hashCode ^ maxMinutes.hashCode;
}

final mealInspirationProvider =
    FutureProvider.family<List<Recipe>, MealFilter>((ref, filter) {
  return fetchRecipes(
    query: filter.mealType,
    maxMinutes: filter.maxMinutes,
  );
});

final recipeByIdProvider = StreamProvider.family((ref, String id) {
  final posController = ref.watch(recipeControllerProvider.notifier);
  return posController.getRecipeById(id);
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

  Future<void> shareRecipe({
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
    final user = _ref.watch(userProvider)!;

    String recipeId = const Uuid().v4();
    String coverImageUrl = '';

    try {
      final result = await _storageRepository.uploadImage(
        image,
        recipeId,
      );

      final imageUrl = result;

      coverImageUrl = imageUrl;

      final Recipe recipe = Recipe(
          id: recipeId,
          title: title,
          uid: user.id,
          coverImage: coverImageUrl,
          createdAt: TemporalDateTime.now(),
          likes: [],
          description: description,
          ingredients: ingredients,
          instructions: instructions,
          servings: servings,
          cookTimeMinutes: cookTimeMinutes,
          userImage: user.profilePic,
          fromUser: true,
          username: user.name);

      final res = await _recipeRepository.addRecipe(recipe);
      state = false;
      res.fold(
        (l) => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l.message)),
        ),
        (r) {
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

  Future<void> deleteRecipe(String id, BuildContext context) async {
    final res = await _recipeRepository.deleteRecipe(id);
    res.fold((l) => null, (r) => null);
  }
/*
  void likeOrUnlike(Recipe recipe) async {
    final uid = _ref.read(userProvider)!.uid;
    _recipeRepository.likeOrUnlike(recipe, uid);
  }*/

  Stream<Recipe> getRecipeById(String id) {
    return _recipeRepository.getRecipeById(id);
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
      final user = _ref.watch(userProvider)!;

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
        uid: user.id,
        fromUser: true,
        createdAt: TemporalDateTime.now(),
        likes: likes,
      );

      final res = await _recipeRepository.updateRecipe(recipe);

      state = false;

      res.fold(
        (failure) => showSnackBar(context, failure.message),
        (_) {
          showSnackBar(context, 'Recipe updated successfully!');
          Routemaster.of(context).popUntil((route) => route.path == '/');
        },
      );
    } catch (e) {
      state = false;
      if (context.mounted) showSnackBar(context, e.toString());
    }
  }
}

Future<List<Recipe>> fetchRecipes({String? query, int? maxMinutes}) async {
  final res = await http.post(
    Uri.parse(
        'https://bnjocjlpl1.execute-api.eu-north-1.amazonaws.com/dev/recipeApiCall'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'query': query,
      if (maxMinutes != null) 'maxReadyInMinutes': maxMinutes,
    }),
  );

  if (res.statusCode != 200) return [];
  final List results = jsonDecode(res.body);

  debugPrint(results.toString());

  return results.map((r) => fromSpoonacular(r)).toList();
}

final apiRecipesProvider =
    FutureProvider.family<List<Recipe>, String>((ref, query) {
  return fetchRecipes(query: query);
});

Recipe fromSpoonacular(Map<String, dynamic> data) {
  return Recipe(
    id: data['id'].toString(),
    title: data['title'] ?? 'Untitled',
    coverImage: data['image'] ?? '',
    description: _stripHtml(data['summary'] ?? ''),
    ingredients: [],
    instructions: [],
    servings: (data['servings'] ?? '').toString(),
    cookTimeMinutes: (data['readyInMinutes'] ?? '').toString(),
    createdAt: TemporalDateTime.now(),
    likes: [],
    fromUser: false,
    uid: null,
    userImage: null,
    username: null,
  );
}

String _stripHtml(String htmlString) {
  return htmlString
      .replaceAll(RegExp(r'<[^>]*>'), '')
      .replaceAll('&nbsp;', ' ')
      .trim();
}
