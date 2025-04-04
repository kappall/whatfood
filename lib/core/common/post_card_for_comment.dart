import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:routemaster/routemaster.dart';
import 'package:whatfood/button_styles.dart';
import 'package:whatfood/core/common/error_text.dart';
import 'package:whatfood/core/common/loader.dart';
import 'package:whatfood/features/auth/controller/auth_controller.dart';
import 'package:whatfood/features/post/controller/post_controller.dart';
import 'package:whatfood/models/Post.dart';

class PostCardForComment extends ConsumerStatefulWidget {
  final Post post;
  final bool isCommenting;
  const PostCardForComment({
    super.key,
    required this.post,
    this.isCommenting = false,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _PostCardForCommentState();
}

class _PostCardForCommentState extends ConsumerState<PostCardForComment> {
  late Post _post;
  @override
  void initState() {
    _post = widget.post;
    super.initState();
  }

  void deletePost(WidgetRef ref, BuildContext context) async {
    ref.read(postControllerProvider.notifier).deletePost(_post, context);
  }

  void likeOrUnlikePost() {
    final user = ref.read(userProvider)!;
    if (user.id == _post.id) {
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
  }

  void navigateToUser(BuildContext context) {
    try {
      Routemaster.of(context).push('/user_page/${_post.uid}');
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
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider)!;
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
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
                        backgroundImage: NetworkImage(_post.userImage),
                        radius: 24,
                      ),
                    ),
                    SizedBox(width: 12),
                    Text(
                      _post.username,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ],
                ),
                popUpMenu(context, ref, _post.uid == user.id)
              ],
            ),
            SizedBox(height: 12),
            Text(
              _post.description,
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 12),
            FutureBuilder(
              future: Amplify.Storage.getUrl(
                path: StoragePath.fromString(_post.imageUrl),
              ).result,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Loader();
                }
                if (!snapshot.hasData) {
                  return const Loader();
                }
                String imageUrl = snapshot.data!.url.toString();
                return ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: MediaQuery.of(context).size.height * 0.35,
                    errorBuilder: (BuildContext context, Object exception,
                        StackTrace? stackTrace) {
                      return Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.broken_image, size: 50),
                      );
                    },
                  ),
                );
              },
            ),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        _post.likes.contains(user.id)
                            ? Icons.favorite
                            : Icons.favorite_outline,
                        color: _post.likes.contains(user.id)
                            ? Colors.red
                            : Colors.white,
                      ),
                      onPressed: () {
                        likeOrUnlikePost();
                      },
                    ),
                    Text(
                      _post.likes.isEmpty ? 'Like' : '${_post.likes.length}',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
                Row(
                  children: [
                    FaIcon(
                      FontAwesomeIcons.commentDots,
                      color: Colors.white,
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    Text(
                      '${_post.commentCount}',
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
  }
}
