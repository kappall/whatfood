import 'package:whatfood/models/Post.dart';

extension PostGraphQLFields on Post {
  static String get graphQLFields => '''
    id
    content
    votes
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
