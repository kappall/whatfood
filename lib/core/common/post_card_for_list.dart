import 'package:flutter/material.dart';
import 'package:routemaster/routemaster.dart';
import 'package:whatfood/core/common/error_text.dart';
import 'package:whatfood/core/common/loader.dart';
import 'package:whatfood/features/auth/controller/auth_controller.dart';
import 'package:whatfood/features/post/controller/post_controller.dart';
import 'package:whatfood/models/Post.dart';
import 'package:whatfood/models/User.dart';

class PostCard extends StatefulWidget {
  final Post post;
  final bool isCommenting;
  final PostController controller;
  const PostCard({
    super.key,
    required this.controller,
    this.isCommenting = false,
    required this.post,
  });

  @override
  State<StatefulWidget> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  void deletePost(BuildContext context) async {
    widget.controller.deletePost(widget.post, context);
  }

  void likeOrUnlikePost() async {
    widget.controller.likeOrUnlike(widget.post);
  }

  void navigateToComments(BuildContext context) {
    Routemaster.of(context).push('${widget.post.id}/comments');
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
      icon: Icon(
        Icons.more_vert,
      ),
      onSelected: (String result) {
        if (result == 'delete') {
          deletePost(context);
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
  Widget build(BuildContext context) {
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
                                      backgroundImage:
                                          NetworkImage(widget.post.userImage),
                                      radius: 24,
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(left: 8),
                                    child: Text(
                                      widget.post.username,
                                      style: TextStyle(
                                        fontSize: 22,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              popUpMenu(context, widget.post.uid == user.uid)
                            ],
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 10),
                            child: Text(
                              widget.post.description,
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
                            color:
                                Theme.of(context).appBarTheme.backgroundColor),
                        child: Image.network(
                          widget.post.imageUrl,
                          fit: BoxFit.contain,
                          width: double.infinity,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
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
                                "${widget.post.likes.isEmpty ? 'Like' : widget.post.likes.length}",
                                style: TextStyle(fontSize: 18),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(Icons.comment),
                                onPressed: () => !widget.isCommenting
                                    ? navigateToComments(context)
                                    : null,
                              ),
                              Text(
                                "${widget.post.commentCount == 0 ? 'Comment' : widget.post.commentCount}",
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
        });
  }
}
