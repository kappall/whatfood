import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';
import 'package:whatfood/models/comment_model.dart';

class CommentCard extends ConsumerWidget {
  final Comment comment;
  const CommentCard({required this.comment, super.key});

  void navigateToUser(BuildContext context) {
    Routemaster.of(context).push('user_page/${comment.uid}');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
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
                      backgroundImage: NetworkImage(comment.profilePic),
                      radius: 24,
                    ),
                  ),
                  Text(
                    comment.username,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                  ),
                ],
              ),
              Row(
                children: [
                  Text(
                      '${DateTime.now().difference(comment.createdAt).inDays}d ago')
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
