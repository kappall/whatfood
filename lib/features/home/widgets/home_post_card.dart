import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:routemaster/routemaster.dart';
import 'package:whatfood/core/common/bounce_icon.dart';
import 'package:whatfood/core/common/error_text.dart';
import 'package:whatfood/core/common/loader.dart';
import 'package:whatfood/features/auth/controller/auth_controller.dart';
import 'package:whatfood/features/post/controller/post_controller.dart';
import 'package:whatfood/models/Post.dart';
import 'package:whatfood/models/User.dart';

class HomePostCard extends StatefulWidget {
  final Post post;
  final PostController controller;
  const HomePostCard({
    super.key,
    required this.controller,
    required this.post,
  });

  @override
  State<StatefulWidget> createState() => _HomePostCardState();
}

class _HomePostCardState extends State<HomePostCard> {
  void deletePost(BuildContext context) {
    widget.controller.deletePost(widget.post, context);
  }

  void likeOrUnlikePost() {
    widget.controller.likeOrUnlike(widget.post);
  }

  void navigateToComments(BuildContext context) {
    debugPrint('Here');
    Routemaster.of(context).push('/${widget.post.id}/comments');
  }

  void navigateToUser(BuildContext context) {
    try {
      Routemaster.of(context).push('user_page/${widget.post.uid}');
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Widget popUpMenu(BuildContext context, bool isOwner) {
    return PopupMenuButton<String>(
      offset: const Offset(-40, 0),
      icon: const Icon(Icons.more_vert, color: Colors.white),
      iconSize: 32,
      onSelected: (String value) async {
        if (value == 'delete') {
          deletePost(context);
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

  void addOrRemoveBookmark() async {
    await widget.controller.addOrRemoveBookmark(widget.post);
  }

  @override
  Widget build(BuildContext context) {
    bool isExpanded = false;

    return FutureBuilder(
        future: getUserData(),
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
          final user = User.fromJson(snapshot.data!);
          return GestureDetector(
            onDoubleTap: () => likeOrUnlikePost(),
            child: Stack(
              children: [
                Positioned.fill(
                    child: Image.network(
                  widget.post.imageUrl,
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
                              GestureDetector(
                                onTap: () => navigateToUser(context),
                                child: CircleAvatar(
                                  backgroundImage:
                                      NetworkImage(user.profilePic),
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
                          popUpMenu(context, widget.post.uid == user.uid),
                        ],
                      ),
                      const SizedBox(height: 10),
                      StatefulBuilder(
                        builder: (context, setState) => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.post.description,
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
                            if (widget.post.description.length > 30)
                              GestureDetector(
                                onTap: () =>
                                    setState(() => isExpanded = !isExpanded),
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 4.0),
                                  child: Text(
                                    isExpanded ? 'Show less' : 'Show more',
                                    style: TextStyle(
                                      color: Colors.white
                                        ..withValues(alpha: 0.7),
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
                              widget.post.likes.contains(user.uid)
                                  ? Icons.favorite
                                  : Icons.favorite_outline,
                              color: widget.post.likes.contains(user.uid)
                                  ? Colors.red
                                  : Colors.white,
                              size: 30,
                            ),
                            onPressed: () => likeOrUnlikePost(),
                          ),
                          Text(
                            "${widget.post.likes.length}",
                            style: const TextStyle(
                                fontSize: 18, color: Colors.white),
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
                            "${widget.post.commentCount}",
                            style: const TextStyle(
                                fontSize: 18, color: Colors.white),
                          ),
                          const SizedBox(width: 20),
                          BounceIconButton(
                            activeIcon: Icons.bookmark,
                            inactiveIcon: Icons.bookmark_outline,
                            isActive: user.savedPosts.contains(widget.post.id),
                            onPressed: () => addOrRemoveBookmark(),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        });
  }
}
