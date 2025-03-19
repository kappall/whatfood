import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';
import 'package:whatfood/core/common/error_text.dart';
import 'package:whatfood/core/common/loader.dart';
import 'package:whatfood/features/auth/controller/auth_controller.dart';
import 'package:whatfood/features/post/controller/post_controller.dart';
import 'package:whatfood/models/Post.dart';
import 'package:whatfood/models/User.dart';

class PostCard extends ConsumerWidget {
  final Post post;
  final bool isCommenting;
  final PostController controller;
  const PostCard({
    super.key,
    required this.controller,
    this.isCommenting = false,
    required this.post,
  });

  void deletePost(WidgetRef ref, BuildContext context) async {
    ref.read(postControllerProvider.notifier).deletePost(post, context);
  }

  void likeOrUnlikePost(WidgetRef ref) async {
    ref.read(postControllerProvider.notifier).likeOrUnlike(post);
  }

  void navigateToComments(BuildContext context) {
    Routemaster.of(context).push('${post.id}/comments');
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
      icon: Icon(
        Icons.more_vert,
      ),
      onSelected: (String result) {
        if (result == 'delete') {
          deletePost(ref, context);
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        if (isOwner)
          PopupMenuItem<String>(
            value: 'delete',
            child: Row(
              children: [
                Icon(
                  Icons.delete,
                  color: Colors.red,
                ),
                SizedBox(width: 8),
                Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ],
            ),
          ),
        if (isOwner)
          PopupMenuItem<String>(
            value: 'edit',
            child: Row(
              children: [
                Icon(
                  Icons.edit,
                  color: Colors.blueAccent,
                ),
                SizedBox(width: 8),
                Text(
                  "Edit",
                  style: TextStyle(color: Colors.blueAccent),
                ),
              ],
            ),
          ),
        PopupMenuItem<String>(
          value: 'share',
          child: Row(
            children: [
              Icon(Icons.send, color: Colors.greenAccent),
              SizedBox(width: 8),
              Text(
                "Share",
                style: TextStyle(color: Colors.greenAccent),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider)!;
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(),
          padding: EdgeInsets.symmetric(vertical: 10),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(vertical: 4, horizontal: 16)
                    .copyWith(right: 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                  shape: CircleBorder(),
                                  padding: EdgeInsets.only(right: 0)),
                              onPressed: () => navigateToUser(context),
                              child: CircleAvatar(
                                backgroundImage: NetworkImage(post.userImage),
                                radius: 24,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(left: 8),
                              child: Text(
                                post.username,
                                style: TextStyle(
                                  fontSize: 22,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        popUpMenu(context, ref, post.uid == user.id)
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 10),
                      child: Text(
                        post.description,
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.4,
                width: double.infinity,
                child: Container(
                  decoration: BoxDecoration(
                      color: Theme.of(context).appBarTheme.backgroundColor),
                  child: Image.network(
                    post.imageUrl,
                    fit: BoxFit.contain,
                    width: double.infinity,
                  ),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            post.likes.contains(ref.watch(userProvider)?.id)
                                ? Icons.favorite
                                : Icons.favorite_outline,
                            color:
                                post.likes.contains(ref.watch(userProvider)?.id)
                                    ? Colors.red
                                    : Colors.white,
                            size: 30,
                          ),
                          onPressed: () => likeOrUnlikePost(ref),
                        ),
                        Text(
                          "${post.likes.isEmpty ? 'Like' : post.likes.length}",
                          style: TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.comment),
                          onPressed: () => !isCommenting
                              ? navigateToComments(context)
                              : null,
                        ),
                        Text(
                          "${post.commentCount == 0 ? 'Comment' : post.commentCount}",
                          style: TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Divider(
                color: Theme.of(context).primaryColor,
                height: 5,
              )
            ],
          ),
        ),
      ],
    );
  }
}
