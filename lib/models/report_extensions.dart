import 'package:whatfood/models/Report.dart';

extension ReportGraphQLFields on Report {
  static String get graphQLFields => '''
    id
    uid
    date
    nutritionalValues
    description
    category
  ''';
}
