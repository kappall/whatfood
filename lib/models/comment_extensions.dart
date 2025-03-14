import 'package:whatfood/models/Comment.dart';

extension CommentGraphQLFields on Comment {
  static String get graphQLFields => '''
    id
    text
    likes
    username
    uid
    postID
    userImage
    createdAt
  ''';
}
