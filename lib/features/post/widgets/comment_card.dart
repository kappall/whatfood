import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';
import 'package:whatfood/features/auth/controller/auth_controller.dart';
import 'package:whatfood/features/post/controller/post_controller.dart';
import 'package:whatfood/models/Comment.dart';

class CommentCard extends ConsumerWidget {
  void navigateToUser(BuildContext context) {
    Routemaster.of(context).push('user_page/${comment.uid}');
  }

  final Comment comment;
  final String postOwnerUid;

  const CommentCard({
    super.key,
    required this.comment,
    required this.postOwnerUid,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider)!;
    final canDelete = (user.id == comment.uid || user.id == postOwnerUid);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                        shape: CircleBorder(),
                        padding: EdgeInsets.only(right: 0)),
                    onPressed: () => navigateToUser(context),
                    child: CircleAvatar(
                      backgroundImage: NetworkImage(comment.userImage),
                      radius: 24,
                    ),
                  ),
                  Text(
                    comment.username,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                  ),
                ],
              ),
              Column(
                children: [
                  Text(
                      '${TemporalDate.now().getDateTime().difference((comment.createdAt.getDateTimeInUtc())).inDays}d ago'),
                  Container(
                    child: canDelete
                        ? IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              FocusScope.of(context).unfocus();
                              ref
                                  .read(postControllerProvider.notifier)
                                  .deleteComment(
                                      commentId: comment.id,
                                      postId: comment.id,
                                      context: context);
                            },
                          )
                        : null,
                  ),
                ],
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(comment.text),
          ),
          Divider(
            height: 1,
          ),
        ],
      ),
    );
  }
}
