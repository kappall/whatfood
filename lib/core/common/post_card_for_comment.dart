import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';
import 'package:whatfood/button_styles.dart';
import 'package:whatfood/features/auth/controller/auth_controller.dart';
import 'package:whatfood/features/post/controller/post_controller.dart';
import 'package:whatfood/models/post_model.dart';

class PostCardForComment extends ConsumerWidget {
  final Post post;
  final bool isCommenting;
  const PostCardForComment({
    super.key,
    required this.post,
    this.isCommenting = false,
  });

  void deletePost(WidgetRef ref, BuildContext context) async {
    ref.read(postControllerProvider.notifier).deletePost(post, context);
  }

  void likeOrUnlikePost(WidgetRef ref) async {
    ref.read(postControllerProvider.notifier).likeOrUnlike(post);
  }

  void navigateToUser(BuildContext context) {
    try {
      Routemaster.of(context).push('/user_page/${post.uid}');
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Widget popUpMenu(BuildContext context, WidgetRef ref, bool isOwner) {
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
                deletePost(ref, context);
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
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider)!;
    return GestureDetector(
      onDoubleTap: () => likeOrUnlikePost(ref),
      child: Card(
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 8),
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
                          backgroundImage: NetworkImage(post.userImage),
                          radius: 24,
                        ),
                      ),
                      SizedBox(width: 12),
                      Text(
                        post.username,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ],
                  ),
                  popUpMenu(context, ref, post.uid == user.uid)
                ],
              ),
              SizedBox(height: 12),
              Text(
                post.description,
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  post.imageUrl,
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
                          post.likes.contains(ref.watch(userProvider)?.uid)
                              ? Icons.favorite
                              : Icons.favorite_outline,
                          color:
                              post.likes.contains(ref.watch(userProvider)?.uid)
                                  ? Colors.red
                                  : Colors.white,
                          size: 30,
                        ),
                        onPressed: () => likeOrUnlikePost(ref),
                      ),
                      Text(
                        post.likes.isEmpty ? 'Like' : '${post.likes.length}',
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
                        '${post.commentCount}',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
