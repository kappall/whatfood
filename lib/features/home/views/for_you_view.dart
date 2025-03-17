import 'package:flutter/material.dart';
import 'package:whatfood/core/common/error_text.dart';
import 'package:whatfood/core/common/loader.dart';
import 'package:whatfood/core/common/provider.dart';
import 'package:whatfood/features/home/widgets/home_post_card.dart';
import 'package:whatfood/features/post/controller/post_controller.dart';
import 'package:whatfood/models/MealType.dart';
import 'package:whatfood/models/Post.dart';

class ForYouView extends StatelessWidget {
  final MealType? selectedMealType;
  const ForYouView({Key? key, required this.selectedMealType})
      : super(key: key);

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
  Widget build(BuildContext context) {
    final controller = MyProvider.of<PostController>(context)?.value;
    if (controller == null) {
      return Scaffold(body: Center(child: Text('Controller not found')));
    }
    return StreamBuilder<List<Post>>(
      stream: controller.fetchPosts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Loader();
        }
        if (snapshot.hasError) {
          return ErrorText(error: snapshot.error.toString());
        }
        if (!snapshot.hasData) {
          return const Loader();
        }
        final posts = snapshot.data!;
        final filteredPosts = selectedMealType == null
            ? posts
            : posts.where((post) => post.mealType == selectedMealType).toList();

        if (filteredPosts.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (selectedMealType != null)
                  Icon(
                    _getMealTypeIcon(selectedMealType!),
                    size: 48,
                    color: Colors.grey,
                  ),
                const SizedBox(height: 16),
                const Text(
                  'No posts found',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
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
              child: HomePostCard(
                post: post,
                controller: controller,
              ),
            );
          },
        );
      },
    );
  }
}
