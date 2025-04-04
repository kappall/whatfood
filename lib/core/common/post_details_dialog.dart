import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';
import 'package:whatfood/features/auth/controller/auth_controller.dart';
import 'package:whatfood/features/post/controller/post_controller.dart';
import 'package:whatfood/models/Post.dart';

class PostDetailsDialog extends ConsumerStatefulWidget {
  final Post post;
  final String imageUrl;

  const PostDetailsDialog({
    super.key,
    required this.post,
    required this.imageUrl,
  });
  @override
  ConsumerState<PostDetailsDialog> createState() => _PostDetailsDialogState();
}

class _PostDetailsDialogState extends ConsumerState<PostDetailsDialog> {
  late Post _post;

  @override
  void initState() {
    super.initState();
    _post = widget.post;
  }

  void deletePost(BuildContext context) {
    ref
        .read(postControllerProvider.notifier)
        .deletePost(widget.post, context)
        .then((_) {
      ref.invalidate(postsProvider);
    });
  }

  void likeOrUnlikePost() {
    final user = ref.read(userProvider)!;
    if (user.id == _post.uid) {
      return;
    }
    ref.read(postControllerProvider.notifier).likeOrUnlike(_post, user.id);
    setState(() {
      if (_post.likes.contains(user.id)) {
        _post = _post.copyWith(
          likes: List<String>.from(_post.likes)..remove(user.id),
        );
      } else {
        _post = _post.copyWith(
          likes: List<String>.from(_post.likes)..add(user.id),
        );
      }
    });
    // Update backend
  }

  void navigateToComments(BuildContext context) {
    debugPrint('Here');
    Routemaster.of(context).push('/${_post.id}/comments');
  }

  void navigateToUser(BuildContext context) {
    try {
      Routemaster.of(context).push('user_page/${_post.uid}');
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void addOrRemoveBookmark() async {
    final user = ref.read(userProvider);
    if (user == null) return;

    final isSaved = user.savedPosts.contains(_post.id);
    final updatedSavedPosts = List<String>.from(user.savedPosts);

    setState(() {
      if (isSaved) {
        updatedSavedPosts.remove(_post.id);
      } else {
        updatedSavedPosts.add(_post.id);
      }
    });

    final updatedUser = user.copyWith(savedPosts: updatedSavedPosts);
    ref.read(userProvider.notifier).state = updatedUser;

    await ref
        .read(postControllerProvider.notifier)
        .addOrRemoveBookmark(_post, user);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final dialogWidth = screenWidth * 0.8;
    debugPrint(_post.likes.toString());

    const primaryColor = Color(0xFF6200EE);
    const surfaceColor = Color(0xFF000B0E);
    const iconColor = Color(0xFF6200EE);
    const textColor = Color(0xFFFFFBFE);

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Stack(
        children: [
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(
              color: Colors.black.withValues(alpha: 0.1),
            ),
          ),
          Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: dialogWidth),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 8,
                color: surfaceColor,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          widget.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 200,
                              height: 200,
                              color: Colors.grey[300],
                              child: const Icon(Icons.broken_image, size: 50),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        widget.post.description,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            children: [
                              IconButton(
                                icon: Icon(
                                    _post.likes.contains(_post.uid)
                                        ? Icons.favorite
                                        : Icons.favorite_outline,
                                    color: iconColor),
                                onPressed: () {
                                  likeOrUnlikePost();
                                },
                              ),
                              Text(
                                '${_post.likes.length}',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: textColor,
                                ),
                              ),
                            ],
                          ),
                          Column(children: [
                            IconButton(
                              icon: Icon(Icons.comment_outlined,
                                  color: iconColor),
                              onPressed: () {
                                navigateToComments(context);
                              },
                            ),
                            Text(
                              '${_post.commentCount}',
                              style: TextStyle(
                                fontSize: 16,
                                color: textColor,
                              ),
                            ),
                          ]),
                          IconButton(
                            icon: Icon(Icons.share, color: iconColor),
                            onPressed: () {
                              debugPrint('share post');
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: surfaceColor,
                          elevation: 2,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                        child: const Text('Close'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
