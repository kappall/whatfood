import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatfood/core/common/error_text.dart';
import 'package:whatfood/core/common/loader.dart';
import 'package:whatfood/features/home/widgets/home_post_card.dart';
import 'package:whatfood/features/post/controller/post_controller.dart';
import 'package:whatfood/models/MealType.dart';

class ForYouView extends ConsumerWidget {
  const ForYouView({super.key});
  IconData _getMealTypeIcon(MealType type) {
    switch (type) {
      case MealType.BREAKFAST:
        return Icons.breakfast_dining;
      case MealType.LUNCH:
        return Icons.lunch_dining;
      case MealType.DINNER:
        return Icons.dinner_dining;
      case MealType.SNACK:
        return Icons.cookie;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedMealType = ref.watch(mealFilterProvider);

    return ref.watch(postsProvider).when(
          data: (posts) {
            final filteredPosts = selectedMealType == null
                ? posts
                : posts
                    .where((post) => post.mealType == selectedMealType)
                    .toList();

            if (filteredPosts.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _getMealTypeIcon(selectedMealType!),
                      size: 48,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No ${selectedMealType.name} posts found',
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              );
            }
            return PageView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: filteredPosts.length,
              itemBuilder: (BuildContext context, int index) {
                final post = filteredPosts[index];
                return SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: HomePostCard(post: post),
                );
              },
            );
          },
          error: (error, stackTrace) => ErrorText(error: error.toString()),
          loading: () => const Loader(),
        );
  }
}
