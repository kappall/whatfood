import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatfood/core/common/error_text.dart';
import 'package:whatfood/core/common/loader.dart';
import 'package:whatfood/core/common/post_card.dart';
import 'package:whatfood/features/auth/controller/auth_controller.dart';
import 'package:whatfood/features/post/controller/post_controller.dart';
import 'package:whatfood/features/post/widgets/comment_card.dart';
import 'package:whatfood/models/post_model.dart';

class CommentsPage extends ConsumerStatefulWidget {
  final String postId;
  const CommentsPage({
    super.key,
    required this.postId,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _CommentsPageState();
}

class _CommentsPageState extends ConsumerState<CommentsPage> {
  final commentController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    super.dispose();
    commentController.dispose();
    _scrollController.dispose();
  }

  void addComment(Post post) {
    ref.read(postControllerProvider.notifier).addComment(
        context: context,
        content: commentController.text.trim(),
        postId: post.id);
    commentController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ref.watch(postByIdProvider(widget.postId)).when(
            data: (post) {
              return Column(
                children: [
                  PostCard(
                    post: post,
                    isCommenting: true,
                  ),
                  Expanded(
                    child: ref
                        .watch(getpostCommentsProvider(widget.postId))
                        .when(
                          data: (comments) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (_scrollController.hasClients) {
                                _scrollController.jumpTo(
                                    _scrollController.position.maxScrollExtent);
                              }
                            });

                            return ListView.builder(
                              controller: _scrollController,
                              itemCount: comments.length,
                              itemBuilder: (BuildContext context, int index) {
                                final comment = comments[index];
                                return CommentCard(comment: comment);
                              },
                            );
                          },
                          error: (error, stackTrace) => ErrorText(
                            error: error.toString(),
                          ),
                          loading: () => const Loader(),
                        ),
                  ),
                  _buildCommentInput(post),
                ],
              );
            },
            error: (error, stackTrace) => ErrorText(
              error: error.toString(),
            ),
            loading: () => const Loader(),
          ),
    );
  }

  Widget _buildCommentInput(Post post) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: commentController,
                textCapitalization: TextCapitalization.sentences,
                onSubmitted: (val) => addComment(post),
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
              onPressed: () => addComment(post),
            ),
          ],
        ),
      ),
    );
  }
}
