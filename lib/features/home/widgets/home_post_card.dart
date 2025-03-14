import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:routemaster/routemaster.dart';
import 'package:whatfood/core/common/bounce_icon.dart';
import 'package:whatfood/features/auth/controller/auth_controller.dart';
import 'package:whatfood/features/post/controller/post_controller.dart';
import 'package:whatfood/models/Post.dart';

class HomePostCard extends ConsumerWidget {
  final Post post;
  final bool isCommenting;
  const HomePostCard({
    super.key,
    required this.post,
    this.isCommenting = false,
  });

  void deletePost(WidgetRef ref, BuildContext context) {
    ref.read(postControllerProvider.notifier).deletePost(post, context);
  }

  void likeOrUnlikePost(WidgetRef ref) {
    ref.read(postControllerProvider.notifier).likeOrUnlike(post);
  }

  void navigateToComments(BuildContext context) {
    debugPrint('Here');
    Routemaster.of(context).push('/${post.id}/comments');
  }

  void navigateToUser(BuildContext context) {
    try {
      Routemaster.of(context).push('user_page/${post.uid}');
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Widget popUpMenu(BuildContext context, WidgetRef ref, bool isOwner) {
    return PopupMenuButton<String>(
      offset: const Offset(-40, 0),
      icon: const Icon(Icons.more_vert, color: Colors.white),
      iconSize: 32,
      onSelected: (String value) async {
        if (value == 'delete') {
          deletePost(ref, context);
        } else if (value == 'share') {
          debugPrint('Share');
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        if (isOwner)
          PopupMenuItem<String>(
            value: 'delete',
            child: Row(
              children: [
                Icon(Icons.delete, color: Colors.redAccent),
                SizedBox(width: 8),
                Text(
                  "Delete",
                  style: TextStyle(color: Colors.redAccent),
                ),
              ],
            ),
          ),
        PopupMenuItem<String>(
          value: 'share',
          child: Row(
            children: [
              Icon(Icons.send, color: Colors.blueAccent),
              SizedBox(width: 8),
              Text(
                "Share",
                style: TextStyle(color: Colors.blueAccent),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void addOrRemoveBookmark(WidgetRef ref) async {
    final user = ref.watch(userProvider);
    if (user == null) return;

    final isSaved = user.savedPosts.contains(post.id);

    await ref
        .read(postControllerProvider.notifier)
        .addOrRemoveBookmark(post, user);

    final updatedSavedPosts = List<String>.from(user.savedPosts);
    if (isSaved) {
      updatedSavedPosts.remove(post.id);
    } else {
      updatedSavedPosts.add(post.id);
    }

    final updatedUser = user.copyWith(savedPosts: updatedSavedPosts);
    ref.read(userProvider.notifier).state = updatedUser;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usernameAsync = ref.watch(userNameProvider(post.uid));
    final userPicAsync = ref.watch(userPicProvider(post.uid));
    bool isExpanded = false;

    return GestureDetector(
      onDoubleTap: () => likeOrUnlikePost(ref),
      child: Stack(
        children: [
          Positioned.fill(
              child: Image.network(
            post.imageUrl,
            fit: BoxFit.contain,
            width: double.infinity,
          )),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black87,
                    Colors.black12,
                    Colors.transparent,
                  ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.center,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        userPicAsync.when(
                          data: (userPic) => GestureDetector(
                            onTap: () => navigateToUser(context),
                            child: CircleAvatar(
                              backgroundImage: NetworkImage(userPic),
                              radius: 24,
                            ),
                          ),
                          loading: () => const SizedBox(
                            width: 20,
                            height: 20,
                            child:
                                CircularProgressIndicator(color: Colors.white),
                          ),
                          error: (_, __) => const CircleAvatar(
                            radius: 24,
                            backgroundColor: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 10),
                        usernameAsync.when(
                          data: (username) => Text(
                            username,
                            style: const TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          loading: () => const SizedBox(
                            width: 20,
                            height: 20,
                            child:
                                CircularProgressIndicator(color: Colors.white),
                          ),
                          error: (_, __) => const Text(
                            'Unknown User',
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    popUpMenu(
                        context, ref, post.uid == ref.watch(userProvider)?.uid),
                  ],
                ),
                const SizedBox(height: 10),
                StatefulBuilder(
                  builder: (context, setState) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.description,
                        maxLines: isExpanded ? null : 1,
                        overflow: isExpanded
                            ? TextOverflow.visible
                            : TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (post.description.length > 30)
                        GestureDetector(
                          onTap: () => setState(() => isExpanded = !isExpanded),
                          child: Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(
                              isExpanded ? 'Show less' : 'Show more',
                              style: TextStyle(
                                color: Colors.white..withValues(alpha: 0.7),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        post.likes.contains(ref.watch(userProvider)?.uid)
                            ? Icons.favorite
                            : Icons.favorite_outline,
                        color: post.likes.contains(ref.watch(userProvider)?.uid)
                            ? Colors.red
                            : Colors.white,
                        size: 30,
                      ),
                      onPressed: () => likeOrUnlikePost(ref),
                    ),
                    Text(
                      "${post.likes.length}",
                      style: const TextStyle(fontSize: 18, color: Colors.white),
                    ),
                    const SizedBox(width: 20),
                    IconButton(
                      icon: FaIcon(
                        FontAwesomeIcons.commentDots,
                        color: Colors.white,
                      ),
                      onPressed: () => navigateToComments(context),
                    ),
                    Text(
                      "${post.commentCount}",
                      style: const TextStyle(fontSize: 18, color: Colors.white),
                    ),
                    const SizedBox(width: 20),
                    BounceIconButton(
                      activeIcon: Icons.bookmark,
                      inactiveIcon: Icons.bookmark_outline,
                      isActive:
                          ref.watch(userProvider)!.savedPosts.contains(post.id),
                      onPressed: () => addOrRemoveBookmark(ref),
                    ),
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
