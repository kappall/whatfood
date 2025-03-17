import 'package:flutter/material.dart';
import 'package:routemaster/routemaster.dart';
import 'package:whatfood/button_styles.dart';
import 'package:whatfood/core/common/error_text.dart';
import 'package:whatfood/core/common/loader.dart';
import 'package:whatfood/features/auth/controller/auth_controller.dart';
import 'package:whatfood/features/post/controller/post_controller.dart';
import 'package:whatfood/models/Post.dart';
import 'package:whatfood/models/User.dart';

class PostCardForComment extends StatefulWidget {
  final Post post;
  final bool isCommenting;
  final PostController controller;
  const PostCardForComment({
    super.key,
    required this.controller,
    required this.post,
    this.isCommenting = false,
  });

  @override
  State<StatefulWidget> createState() => _PostCardForComemntState();
}

class _PostCardForComemntState extends State<PostCardForComment> {
  void deletePost(BuildContext context) async {
    widget.controller.deletePost(widget.post, context);
  }

  void likeOrUnlikePost() async {
    widget.controller.likeOrUnlike(widget.post);
  }

  void navigateToUser(BuildContext context) {
    try {
      Routemaster.of(context).push('/user_page/${widget.post.uid}');
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Widget popUpMenu(BuildContext context, bool isOwner) {
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert),
      onSelected: (String result) {},
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        if (isOwner)
          PopupMenuItem<String>(
            child: TextButton.icon(
              style: ButtonStyles.textButtonStyle(textColor: Colors.red),
              onPressed: () {
                FocusScope.of(context).unfocus();
                deletePost(context);
              },
              icon: Icon(Icons.delete, color: Colors.red),
              label: Text("Delete"),
            ),
          ),
        if (isOwner)
          PopupMenuItem<String>(
            child: TextButton.icon(
              style: ButtonStyles.textButtonStyle(textColor: Colors.blueAccent),
              onPressed: () {
                FocusScope.of(context).unfocus();
                // Inserisci qui la logica per l'edit
              },
              icon: Icon(Icons.edit, color: Colors.blueAccent),
              label: Text("Edit"),
            ),
          ),
        PopupMenuItem<String>(
          child: TextButton.icon(
            style: ButtonStyles.textButtonStyle(textColor: Colors.green),
            onPressed: () {
              FocusScope.of(context).unfocus();
            },
            icon: Icon(Icons.share, color: Colors.green),
            label: Text("Share"),
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
          return Card(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            elevation: 4,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.lightGreen, width: 6)),
            child: Padding(
              padding: EdgeInsets.all(16),
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
                                  NetworkImage(widget.post.userImage),
                              radius: 24,
                            ),
                          ),
                          SizedBox(width: 12),
                          Text(
                            widget.post.username,
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                        ],
                      ),
                      popUpMenu(context, widget.post.uid == user.uid)
                    ],
                  ),
                  SizedBox(height: 12),
                  Text(
                    widget.post.description,
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      widget.post.imageUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: MediaQuery.of(context).size.height * 0.35,
                    ),
                  ),
                  SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.thumb_up,
                              color: widget.post.likes.contains(user.uid)
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).colorScheme.secondary,
                              size: 28,
                            ),
                            onPressed: () => likeOrUnlikePost(),
                          ),
                          Text(
                            widget.post.likes.isEmpty
                                ? 'Like'
                                : '${widget.post.likes.length}',
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.comment, size: 28),
                            onPressed: () {},
                          ),
                          Text(
                            '${widget.post.commentCount}',
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        });
  }
}
