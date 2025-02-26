import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';
import 'package:whatfood/models/post_model.dart';

class PostCard extends ConsumerWidget {
  final Post post;
  final bool isCommenting;
  const PostCard({
    super.key,
    this.isCommenting = false,
    required this.post,
  });

  void navigateToListPosts(BuildContext context) {
    Routemaster.of(context).push('/post_list/${post.uid}');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isTypeImage = post.type == "image";
    return LayoutBuilder(
      builder: (context, constraints) {
        double cardWidth = (constraints.maxWidth - 32) / 2;
        return GestureDetector(
          onTap: () => navigateToListPosts(context),
          child: Container(
            width: cardWidth,
            height: cardWidth,
            margin: EdgeInsets.all(4),
            child: Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                elevation: 4,
                child: isTypeImage
                    ? ClipRRect(
                        child: Image.network(
                          post.imageUrl!,
                          fit: BoxFit.cover,
                        ),
                      )
                    : null),
          ),
        );
      },
    );
  }
}
