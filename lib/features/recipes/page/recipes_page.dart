import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';
import 'package:whatfood/core/common/error_text.dart';
import 'package:whatfood/core/common/loader.dart';
import 'package:whatfood/core/common/recipe_card.dart';
import 'package:whatfood/features/recipes/controller/recipe_controller.dart';
import 'package:whatfood/models/recipe_model.dart';
import 'package:whatfood/theme/theme.dart';

class RecipesPage extends ConsumerStatefulWidget {
  const RecipesPage({super.key});

  @override
  ConsumerState<RecipesPage> createState() => RecipesPageState();
}

class RecipesPageState extends ConsumerState<RecipesPage> {
  @override
  Widget build(BuildContext context) {
    final themeNotifier = ref.read(themeProvider.notifier);
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50),
        child: AppBar(
          backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
          iconTheme: Theme.of(context).iconTheme,
          titleTextStyle: Theme.of(context).textTheme.headlineMedium,
          title: const Text('Recipes'),
        ),
      ),
      body: ref.watch(recpiesProvider).when(
            data: (data) {
              return ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (BuildContext content, int index) {
                    final recipe = data[index];
                    return RecipeCard(recipe: recipe);
                  });
            },
            error: (error, stackTrace) {
              debugPrint(stackTrace.toString());
              return ErrorText(error: error.toString());
            },
            loading: () => const Loader(),
          ),
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
        onPressed: () {
          Routemaster.of(context).push('/add-recipe');
        },
        backgroundColor: Colors.grey,
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 40,
        ),
      ),
    );
  }
}
