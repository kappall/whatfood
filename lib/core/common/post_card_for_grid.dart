import 'package:flutter/material.dart';
import 'package:whatfood/models/Post.dart';
import 'post_details_dialog.dart';

class PostCard extends StatelessWidget {
  final Post post;
  final String imageUrl;
  final bool isCommenting;
  const PostCard({
    super.key,
    this.isCommenting = false,
    required this.post,
    required this.imageUrl,
  });

  void showPostDetails(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => PostDetailsDialog(post: post, imageUrl: imageUrl),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isTypeImage = post.type == "image";
    return LayoutBuilder(
      builder: (context, constraints) {
        double cardWidth = (constraints.maxWidth - 32) / 2;
        return GestureDetector(
          onTap: () => showPostDetails(context),
          child: Container(
            width: cardWidth,
            height: cardWidth,
            margin: const EdgeInsets.all(4),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
              child: isTypeImage
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (BuildContext context, Object exception,
                            StackTrace? stackTrace) {
                          return Container(
                            color: Colors.grey[300],
                            child: const Icon(Icons.broken_image, size: 50),
                          );
                        },
                      ),
                    )
                  : null,
            ),
          ),
        );
      },
    );
  }
}
