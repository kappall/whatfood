import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';
import 'package:whatfood/core/common/error_text.dart';
import 'package:whatfood/core/common/loader.dart';
import 'package:whatfood/core/common/post_card_for_comment.dart';
import 'package:whatfood/core/common/provider.dart';
import 'package:whatfood/features/post/controller/post_controller.dart';
import 'package:whatfood/features/post/widgets/comment_card.dart';
import 'package:whatfood/models/Post.dart';

class CommentsView extends ConsumerStatefulWidget {
  final String postId;
  const CommentsView({super.key, required this.postId});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _CommentsViewState();
}

class _CommentsViewState extends ConsumerState<CommentsView> {
  final TextEditingController commentController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _commentFocusNode = FocusNode();

  @override
  void dispose() {
    commentController.dispose();
    _scrollController.dispose();
    _commentFocusNode.dispose();
    super.dispose();
  }

  void addComment(Post post, PostController controller) {
    controller.addComment(
      context: context,
      content: commentController.text.trim(),
      postId: post.id,
      commentCount: post.commentCount,
    );
    commentController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final controller = MyProvider.of<PostController>(context)?.value;
    if (controller == null) {
      return Scaffold(body: Center(child: Text('Controller not found')));
    }
    return StreamBuilder(
        stream: controller.fetchCommentsOfPost(widget.postId),
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
          final comments = snapshot.data!;
          return GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            child: FutureBuilder(
                future: controller.getPostById(widget.postId),
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
                  final post = snapshot.data!;
                  return Scaffold(
                      bottomNavigationBar: _buildCommentInput(post, controller),
                      appBar: AppBar(
                        leading: IconButton(
                          onPressed: () => Routemaster.of(context).pop(),
                          icon: Icon(Icons.arrow_back),
                        ),
                        title: Text('Comments'),
                        centerTitle: true,
                      ),
                      body: SingleChildScrollView(
                        controller: _scrollController,
                        child: Column(
                          children: [
                            PostCardForComment(
                              post: post,
                              isCommenting: true,
                              controller: controller,
                            ),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: comments.length,
                              itemBuilder: (context, index) {
                                final comment = comments[index];
                                return CommentCard(
                                  controller: controller,
                                  comment: comment,
                                  postOwnerUid: post.uid,
                                );
                              },
                            )
                          ],
                        ),
                      ));
                }),
          );
        });
  }

  Widget _buildCommentInput(Post post, PostController controller) {
    return SafeArea(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8)
            .copyWith(bottom: MediaQuery.of(context).viewInsets.bottom + 8),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          boxShadow: [
            BoxShadow(
              color: Colors.green,
              blurRadius: 6,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                style: const TextStyle(color: Colors.black),
                controller: commentController,
                textCapitalization: TextCapitalization.sentences,
                focusNode: _commentFocusNode,
                decoration: InputDecoration(
                  hintText: "Write a comment...",
                  filled: true,
                  fillColor: Colors.grey.shade200,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                maxLines: 2,
                minLines: 1,
              ),
            ),
            SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {
                addComment(post, controller);
                FocusScope.of(context).unfocus();
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: Text('Send'),
            ),
          ],
        ),
      ),
    );
  }
}
