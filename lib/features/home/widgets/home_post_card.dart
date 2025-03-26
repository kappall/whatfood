import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:routemaster/routemaster.dart';
import 'package:whatfood/core/common/bounce_icon.dart';
import 'package:whatfood/features/auth/controller/auth_controller.dart';
import 'package:whatfood/features/post/controller/post_controller.dart';
import 'package:whatfood/models/Post.dart';
import 'package:whatfood/models/User.dart';

class HomePostCard extends ConsumerStatefulWidget {
  final Post post;
  final bool isCommenting;
  final String imageUrl;
  const HomePostCard({
    required this.imageUrl,
    super.key,
    required this.post,
    this.isCommenting = false,
  });

  @override
  ConsumerState<HomePostCard> createState() => _HomePostCardState();
}

class _HomePostCardState extends ConsumerState<HomePostCard> {
  late Post _post;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _post = widget.post;
  }

  void deletePost(BuildContext context) {
    ref
        .read(postControllerProvider.notifier)
        .deletePost(_post, context)
        .then((_) {
      ref.invalidate(postsProvider);
    });
  }

  void likeOrUnlikePost() {
    final user = ref.read(userProvider)!;
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
    ref.read(postControllerProvider.notifier).likeOrUnlike(_post);
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
    final user = ref.watch(userProvider)!;

    return GestureDetector(
      onDoubleTap: likeOrUnlikePost,
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.network(
              widget.imageUrl,
              fit: BoxFit.contain,
              width: double.infinity,
              errorBuilder: (BuildContext context, Object exception,
                  StackTrace? stackTrace) {
                return Container(
                  color: Colors.grey[300],
                  child: const Icon(Icons.broken_image, size: 50),
                );
              },
            ),
          ),
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
          PostContentOverlay(
            post: _post,
            user: user,
            isExpanded: _isExpanded,
            onExpandToggle: () => setState(() => _isExpanded = !_isExpanded),
            onLike: likeOrUnlikePost,
            onComment: () => navigateToComments(context),
            onBookmark: addOrRemoveBookmark,
            onUserTap: () => navigateToUser(context),
            onDeletePost: () => deletePost(context),
          ),
        ],
      ),
    );
  }
}

class PostContentOverlay extends StatelessWidget {
  final Post post;
  final User user;
  final bool isExpanded;
  final VoidCallback onExpandToggle;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onBookmark;
  final VoidCallback onUserTap;
  final VoidCallback onDeletePost;

  const PostContentOverlay({
    super.key,
    required this.post,
    required this.user,
    required this.isExpanded,
    required this.onExpandToggle,
    required this.onLike,
    required this.onComment,
    required this.onBookmark,
    required this.onUserTap,
    required this.onDeletePost,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
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
                  GestureDetector(
                    onTap: () => onUserTap,
                    child: CircleAvatar(
                      backgroundImage: NetworkImage(user.profilePic),
                      radius: 24,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    user.name,
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              popUpMenu(context, post.uid == user.id),
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
                  overflow:
                      isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (post.description.length > 50)
                  GestureDetector(
                    onTap: onExpandToggle,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        isExpanded ? 'Show less' : 'Show more',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
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
                  post.likes.contains(user.id)
                      ? Icons.favorite
                      : Icons.favorite_outline,
                  color:
                      post.likes.contains(user.id) ? Colors.red : Colors.white,
                  size: 30,
                ),
                onPressed: onLike,
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
                  onPressed: () => onComment),
              Text(
                "${post.commentCount}",
                style: const TextStyle(fontSize: 18, color: Colors.white),
              ),
              const SizedBox(width: 20),
              BounceIconButton(
                activeIcon: Icons.bookmark,
                inactiveIcon: Icons.bookmark_outline,
                isActive: user.savedPosts.contains(post.id),
                onPressed: onBookmark,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget popUpMenu(BuildContext context, bool isOwner) {
    return PopupMenuButton<String>(
      offset: const Offset(-40, 0),
      icon: const Icon(Icons.more_vert, color: Colors.white),
      iconSize: 32,
      onSelected: (String value) async {
        if (value == 'delete') {
          onDeletePost();
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
}
