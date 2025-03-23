import 'package:whatfood/models/Report.dart';

extension ReportGraphQLFields on Report {
  static String get graphQLFields => '''
    id
    uid
    createdAt
    nutritionalValues
    description
    category
  ''';
}
