import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';
import 'package:whatfood/button_styles.dart';
import 'package:whatfood/core/utils.dart';
import 'package:whatfood/features/auth/controller/auth_controller.dart';
import 'package:whatfood/features/recipes/controller/recipe_controller.dart';
import 'package:whatfood/features/recipes/widgets/recipe_modal.dart';
import 'package:whatfood/models/recipe_model.dart';

class RecipeCard extends ConsumerWidget {
  final Recipe recipe;
  const RecipeCard({Key? key, required this.recipe}) : super(key: key);

  void deleteRecipe(WidgetRef ref, BuildContext context) async {
    ref
        .read(recipeControllerProvider.notifier)
        .deleteRecipe(recipe.id, context);
  }

  void likeOrUnlikePost(WidgetRef ref) async {
    ref.read(recipeControllerProvider.notifier).likeOrUnlike(recipe);
  }

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
                print("Edit pressed");
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
    final theme = Theme.of(context).bottomNavigationBarTheme;
    final user = ref.watch(userProvider)!;
    return LayoutBuilder(
      builder: (context, constraints) {
        double cardWidth = (constraints.maxWidth - 32) / 2;

        return GestureDetector(
          onTap: () => showRecipeModal(context),
          child: Container(
            width: cardWidth,
            height: cardWidth,
            margin: EdgeInsets.all(8),
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              elevation: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(16)),
                      child: Image.network(
                        recipe.coverImage,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          recipe.title,
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.thumb_up,
                                color: recipe.likes.contains(user.uid)
                                    ? theme.selectedItemColor
                                    : null,
                                size: 24,
                              ),
                              onPressed: () => likeOrUnlikePost(ref),
                            ),
                            Text(
                              "${recipe.likes.isEmpty ? 'Like' : recipe.likes.length}",
                              style: TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
