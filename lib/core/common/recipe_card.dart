import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';
import 'package:whatfood/button_styles.dart';
import 'package:whatfood/features/recipes/controller/recipe_controller.dart';
import 'package:whatfood/features/recipes/widgets/show_recipe_modal.dart';
import 'package:whatfood/models/Recipe.dart';

class RecipeCard extends ConsumerWidget {
  final Recipe recipe;
  const RecipeCard({super.key, required this.recipe});

  void deleteRecipe(WidgetRef ref, BuildContext context) async {
    ref
        .read(recipeControllerProvider.notifier)
        .deleteRecipe(recipe.id, context);
  }
/*
  void likeOrUnlikeRecipe(WidgetRef ref) async {
    ref.read(recipeControllerProvider.notifier).likeOrUnlike(recipe);
  }*/

  void navigateToUser(BuildContext context) {
    try {
      Routemaster.of(context).push('user_page/${recipe.uid}');
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Widget popUpMenu(BuildContext context, WidgetRef ref, bool isOwner) {
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_horiz),
      onSelected: (String result) {},
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        if (isOwner)
          PopupMenuItem<String>(
            child: TextButton.icon(
              style: ButtonStyles.textButtonStyle(textColor: Colors.red),
              onPressed: () {
                deleteRecipe(ref, context);
              },
              icon: Icon(Icons.delete, color: Colors.red),
              label: Text("Delete"),
            ),
          ),
        if (isOwner)
          PopupMenuItem<String>(
            child: TextButton.icon(
              style: ButtonStyles.textButtonStyle(textColor: Colors.blueAccent),
              onPressed: () {
                debugPrint("Edit pressed");
              },
              icon: Icon(Icons.edit, color: Colors.blueAccent),
              label: Text("Edit"),
            ),
          ),
        PopupMenuItem<String>(
          value: 'Option 2',
          child: Text('Option 2'),
        ),
        PopupMenuItem<String>(
          value: 'Option 3',
          child: Text('Option 3'),
        ),
      ],
    );
  }

  Future<void> showRecipeModal(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => RecipeModal(
        recipe: recipe,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          onTap: () => showRecipeModal(context),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.black, width: 1),
            ),
            elevation: 4,
            child: Stack(
              children: [
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      recipe.coverImage,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black87,
                          Colors.black12,
                          Colors.transparent,
                        ],
                        begin: Alignment.bottomCenter,
                        end: Alignment.center,
                      ),
                      borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(16),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black87,
                          Colors.black12,
                          Colors.transparent,
                        ],
                        begin: Alignment.bottomCenter,
                        end: Alignment.center,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 20,
                  left: 20,
                  right: 20,
                  child: Text(
                    recipe.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
