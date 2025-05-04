import 'package:whatfood/models/Post.dart';

extension PostGraphQLFields on Post {
  static String get graphQLFields => '''
    id
    description
    likes
    username
    uid
    userImage
    type
    createdAt
    commentCount
    imageUrl
    tags
    mealType
  ''';
}
