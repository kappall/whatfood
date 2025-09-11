import 'package:flutter/material.dart';
import 'package:routemaster/routemaster.dart';
import 'package:whatfood/models/Ingredient.dart';

class IngredientCard extends StatelessWidget {
  final Ingredient ingredient;
  final String? imageUrl;

  const IngredientCard({
    super.key,
    required this.ingredient,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () =>
            Routemaster.of(context).push('/ingredient/${ingredient.id}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image with fixed aspect ratio
            AspectRatio(
              aspectRatio: 4 / 3,
              child: imageUrl != null && imageUrl!.isNotEmpty
                  ? FadeInImage.assetNetwork(
                      placeholder: 'assets/images/placeholder.png',
                      image: imageUrl!,
                      fit: BoxFit.cover,
                      imageErrorBuilder: (_, __, ___) => const ColoredBox(
                        color: Colors.grey,
                        child: Icon(Icons.broken_image_rounded,
                            color: Colors.white70, size: 40),
                      ),
                    )
                  : const ColoredBox(
                      color: Colors.grey,
                      child: Icon(Icons.broken_image_rounded,
                          color: Colors.white70, size: 40),
                    ),
            ),
            // Name
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                ingredient.name,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
