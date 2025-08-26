import 'package:flutter/material.dart';

import 'package:routemaster/routemaster.dart';
import 'package:whatfood/models/Recipe.dart';

class RecipeCard extends StatelessWidget {
  final Recipe recipe;

  const RecipeCard({required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(16),
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 4 / 3,
            child: recipe.coverImage != null
                ? Image.network(
                    recipe.coverImage!,
                    fit: BoxFit.cover,
                  )
                : Container(color: Theme.of(context).colorScheme.surface),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  recipe.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                if (recipe.cookTimeMinutes != null)
                  Row(
                    children: [
                      const Icon(Icons.schedule, size: 14),
                      const SizedBox(width: 4),
                      Text('${recipe.cookTimeMinutes} min',
                          style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
