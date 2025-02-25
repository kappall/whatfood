import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';
import 'package:whatfood/button_styles.dart';
import 'package:whatfood/core/common/image_carousel.dart';
import 'package:whatfood/features/auth/controller/auth_controller.dart';
import 'package:whatfood/features/post/controller/post_controller.dart';
import 'package:whatfood/models/post_model.dart';

class PostCard extends ConsumerWidget {
  final Post post;
  final bool isCommenting;
  const PostCard({
    super.key,
    this.isCommenting = false,
    required this.post,
  });

  void deletePost(WidgetRef ref, BuildContext context) async {
    ref.read(postControllerProvider.notifier).deletePost(post.id, context);
  }

  void likeOrUnlikePost(WidgetRef ref) async {
    ref.read(postControllerProvider.notifier).likeOrUnlike(post);
  }

  void navigateToComments(BuildContext context) {
    Routemaster.of(context).push('post/${post.id}/comments');
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
      icon: Icon(Icons.more_horiz),
      onSelected: (String result) {},
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        if (isOwner)
          PopupMenuItem<String>(
              child: TextButton.icon(
            style: ButtonStyles.textButtonStyle(textColor: Colors.red),
            onPressed: () {
              deletePost(ref, context);
            },
            icon: Icon(
              Icons.delete,
              color: Colors.red,
            ),
            label: Text("Delete"),
          )),
        if (isOwner)
          PopupMenuItem<String>(
              child: TextButton.icon(
            style: ButtonStyles.textButtonStyle(textColor: Colors.blueAccent),
            onPressed: () {
              print("Pulsante premuto1");
            },
            icon: Icon(
              Icons.edit,
              color: Colors.blueAccent,
            ),
            label: Text("Edit"),
          )),
        PopupMenuItem<String>(
            child: TextButton.icon(
          style: ButtonStyles.textButtonStyle(textColor: Colors.greenAccent),
          onPressed: () {
            print("Pulsante premuto1");
          },
          icon: Icon(
            Icons.share,
            color: Colors.greenAccent,
          ),
          label: Text("Share"),
        )),
      ],
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isTypeImage = post.type == "image";
    final isTypeText = post.type == "text";
    final theme = Theme.of(context).bottomNavigationBarTheme;
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
                                    color:
                                        Theme.of(context).secondaryHeaderColor),
                              ),
                            ),
                          ],
                        ),
                        popUpMenu(context, ref, post.uid == user.uid)
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 10),
                      child: Text(
                        post.title,
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (isTypeImage)
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.4,
                  width: double.infinity,
                  child: Container(
                    decoration: BoxDecoration(
                        color: Theme.of(context).appBarTheme.backgroundColor),
                    child: ImageCarousel(
                      imageUrls: post.imageUrls!,
                      boxFit: BoxFit.contain,
                    ),
                  ),
                ),
              if (isTypeText)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Divider(
                      height: 2,
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        child: Container(
                          decoration: BoxDecoration(
                            color:
                                Theme.of(context).appBarTheme.backgroundColor!,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.black45
                                    : Colors.black12,
                                offset: Offset(0, 2),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              post.description!,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
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
                            Icons.thumb_up,
                            color: post.likes.contains(user.uid)
                                ? theme.selectedItemColor
                                : null,
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
