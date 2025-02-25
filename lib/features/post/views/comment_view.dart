import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatfood/core/common/error_text.dart';
import 'package:whatfood/core/common/loader.dart';
import 'package:whatfood/core/common/post_card_for_grid.dart';
import 'package:whatfood/features/post/controller/post_controller.dart';
import 'package:whatfood/features/post/widgets/comment_card.dart';
import 'package:whatfood/models/post_model.dart';

class CommentsView extends ConsumerStatefulWidget {
  final String postId;
  const CommentsView({
    super.key,
    required this.postId,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _CommentsViewState();
}

class _CommentsViewState extends ConsumerState<CommentsView> {
  final commentController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _commentFocusNode = FocusNode();

  @override
  void dispose() {
    commentController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void addComment(Post post) {
    ref.read(postControllerProvider.notifier).addComment(
          context: context,
          content: commentController.text.trim(),
          postId: post.id,
        );
    commentController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return ref.watch(postByIdProvider(widget.postId)).when(
          data: (post) {
            return GestureDetector(
              onTap: () {
                FocusScope.of(context).unfocus();
              },
              child: Scaffold(
                appBar: AppBar(),
                body: SingleChildScrollView(
                  child: Column(
                    children: [
                      PostCard(
                        post: post,
                        isCommenting: true,
                      ),
                      ref.watch(getpostCommentsProvider(widget.postId)).when(
                            data: (comments) {
                              return ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: comments.length,
                                itemBuilder: (context, index) {
                                  final comment = comments[index];
                                  return CommentCard(comment: comment);
                                },
                              );
                            },
                            error: (error, stackTrace) =>
                                ErrorText(error: error.toString()),
                            loading: () => const Loader(),
                          ),
                    ],
                  ),
                ),
                bottomNavigationBar: _buildCommentInput(post),
              ),
            );
          },
          error: (error, stackTrace) => Scaffold(
            body: Center(child: ErrorText(error: error.toString())),
          ),
          loading: () => Scaffold(body: const Center(child: Loader())),
        );
  }

  Widget _buildCommentInput(Post post) {
    return SafeArea(
      child: Container(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 8,
          bottom: MediaQuery.of(context).viewInsets.bottom + 8,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black,
              blurRadius: 4,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: commentController,
                textCapitalization: TextCapitalization.sentences,
                onSubmitted: (val) => addComment(post),
                focusNode: _commentFocusNode,
                decoration: InputDecoration(
                  hintText: "Scrivi un commento...",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                maxLines: 2,
                minLines: 1,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.send),
              onPressed: () {
                addComment(post);
                FocusScope.of(context).unfocus();
              },
            ),
          ],
        ),
      ),
    );
  }
}
