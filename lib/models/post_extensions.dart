import 'package:whatfood/models/Post.dart';

extension PostGraphQLFields on Post {
  static String get graphQLFields => '''
    id
    content
    upVotes
    downVotes
    authorname
    uid
    authorImage
    createdAt
    commentCount
    imageUrl
    tags
    title
  ''';
}
