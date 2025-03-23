import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';
import 'package:whatfood/core/common/error_text.dart';
import 'package:whatfood/core/common/loader.dart';
import 'package:whatfood/core/common/recipe_card.dart';
import 'package:whatfood/features/recipes/controller/recipe_controller.dart';

class RecipesView extends ConsumerStatefulWidget {
  const RecipesView({super.key});

  @override
  ConsumerState<RecipesView> createState() => RecipesViewState();
}

class RecipesViewState extends ConsumerState<RecipesView> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(110),
          child: AppBar(
            backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
            iconTheme: Theme.of(context).iconTheme,
            titleTextStyle: Theme.of(context).textTheme.headlineMedium,
            title: const Text('Recipes'),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(60),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Container(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.search,
                          color: Colors.white,
                          size: 32,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            style: TextStyle(
                              color: Colors.black,
                            ),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Search...',
                              contentPadding:
                                  const EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        body: ref.watch(recipesProvider).when(
              data: (data) {
                return GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                  ),
                  itemCount: data.length,
                  itemBuilder: (BuildContext context, int index) {
                    final recipe = data[index];
                    return FutureBuilder(
                        future: Amplify.Storage.getUrl(
                          path: StoragePath.fromString(recipe.coverImage),
                        ).result,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Loader();
                          }
                          if (snapshot.hasError) {
                            return ErrorText(error: snapshot.error.toString());
                          }
                          if (!snapshot.hasData) {
                            return const Loader();
                          }
                          String imageUrl = snapshot.data!.url.toString();
                          return RecipeCard(recipe: recipe, imageUrl: imageUrl);
                        });
                  },
                );
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
          backgroundColor: Colors.green,
          child: const Icon(
            Icons.add,
            color: Colors.white,
            size: 40,
          ),
        ),
      ),
    );
  }
}
