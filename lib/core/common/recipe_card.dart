import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';
import 'package:whatfood/button_styles.dart';
import 'package:whatfood/core/common/image_carousel.dart';
import 'package:whatfood/features/auth/controller/auth_controller.dart';
import 'package:whatfood/features/recipes/controller/recipe_controller.dart';
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context).bottomNavigationBarTheme;
    final user = ref.watch(userProvider)!;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        shape: CircleBorder(),
                        padding: EdgeInsets.zero,
                      ),
                      onPressed: () => navigateToUser(context),
                      child: CircleAvatar(
                        backgroundImage: NetworkImage(recipe.userImage),
                        radius: 24,
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      recipe.username,
                      style: TextStyle(
                        fontSize: 22,
                        color: Theme.of(context).secondaryHeaderColor,
                      ),
                    ),
                  ],
                ),
                popUpMenu(context, ref, recipe.uid == user.uid)
              ],
            ),
            SizedBox(height: 8),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.15,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(
                    flex: 2,
                    child: Image.network(
                      recipe.coverImage,
                      fit: BoxFit.contain,
                      width: MediaQuery.of(context).size.width * 0.25,
                    ),
                  ),
                  Expanded(
                    flex: 5,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          recipe.title,
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Expanded(
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              return ShaderMask(
                                blendMode: BlendMode.dstIn,
                                shaderCallback: (Rect bounds) {
                                  return LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [Colors.black, Colors.transparent],
                                    stops: [0.8, 1.0],
                                  ).createShader(bounds);
                                },
                                child: Text(
                                  recipe.description,
                                  style: TextStyle(fontSize: 16),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 4,
                                ),
                              );
                            },
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 8),
            Row(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.thumb_up,
                    color: recipe.likes.contains(user.uid)
                        ? theme.selectedItemColor
                        : null,
                    size: 30,
                  ),
                  onPressed: () => likeOrUnlikePost(ref),
                ),
                Text(
                  "${recipe.likes.isEmpty ? 'Like' : recipe.likes.length}",
                  style: TextStyle(fontSize: 18),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
