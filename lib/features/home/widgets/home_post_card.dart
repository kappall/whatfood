import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';
import 'package:whatfood/button_styles.dart';
import 'package:whatfood/core/common/image_carousel.dart';
import 'package:whatfood/features/auth/controller/auth_controller.dart';
import 'package:whatfood/features/post/controller/post_controller.dart';
import 'package:whatfood/models/post_model.dart';

class HomePostCard extends ConsumerWidget {
  final Post post;
  final bool isCommenting;
  const HomePostCard({
    Key? key,
    required this.post,
    this.isCommenting = false,
  }) : super(key: key);

  void deletePost(WidgetRef ref, BuildContext context) {
    ref.read(postControllerProvider.notifier).deletePost(post.id, context);
  }

  void likeOrUnlikePost(WidgetRef ref) {
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
      icon: const Icon(Icons.more_horiz, color: Colors.white),
      onSelected: (String result) {},
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        if (isOwner)
          PopupMenuItem<String>(
            child: TextButton.icon(
              style: ButtonStyles.textButtonStyle(textColor: Colors.red),
              onPressed: () {
                deletePost(ref, context);
              },
              icon: const Icon(Icons.delete, color: Colors.red),
              label: const Text("Delete"),
            ),
          ),
        if (isOwner)
          PopupMenuItem<String>(
            child: TextButton.icon(
              style: ButtonStyles.textButtonStyle(textColor: Colors.blueAccent),
              onPressed: () {
                print("Edit pressed");
              },
              icon: const Icon(Icons.edit, color: Colors.blueAccent),
              label: const Text("Edit"),
            ),
          ),
        const PopupMenuItem<String>(
          value: 'Option 2',
          child: Text('Option 2'),
        ),
        const PopupMenuItem<String>(
          value: 'Option 3',
          child: Text('Option 3'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Size size = MediaQuery.of(context).size;
    final bool isTypeImage = post.type == "image";
    final theme = Theme.of(context);

    return Stack(
      children: [
        Positioned.fill(
          child: isTypeImage
              ? ImageCarousel(
                  imageUrls: post.imageUrls!,
                  boxFit: BoxFit.contain,
                )
              : Container(
                  color: theme.appBarTheme.backgroundColor ?? Colors.black,
                ),
        ),
        // Overlay gradiente per migliorare la leggibilità
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
        // Contenuto in primo piano
        Positioned(
          bottom: 20,
          left: 20,
          right: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header con avatar, username e menu contestuale
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
                      const SizedBox(width: 10),
                      Text(
                        post.username,
                        style: const TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  popUpMenu(
                      context, ref, post.uid == ref.watch(userProvider)?.uid)
                ],
              ),
              const SizedBox(height: 10),
              // Titolo del post
              Text(
                post.title,
                style: const TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              // Se il post è testuale, visualizza anche la descrizione
              if (!isTypeImage)
                Text(
                  post.description ?? "",
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              const SizedBox(height: 20),
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.thumb_up,
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
                    icon: const Icon(
                      Icons.comment,
                      color: Colors.white,
                      size: 30,
                    ),
                    onPressed: () => navigateToComments(context),
                  ),
                  Text(
                    "${post.commentCount}",
                    style: const TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
