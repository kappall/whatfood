import 'dart:convert';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:whatfood/core/failure.dart';
import 'package:whatfood/models/Report.dart';
import 'package:whatfood/models/report_extensions.dart';

final reportRepositoryProvider = Provider((ref) {
  return ReportRepository();
});

class ReportRepository {
  // Aggiunge un report tramite una mutation GraphQL
  Future<Either<Failure, void>> addFoodReport(Report report) async {
    try {
      final request = GraphQLRequest<String>(
        document: '''
          mutation CreateReport(\$input: CreateReportInput!) {
            createReport(input: \$input) {
              ${ReportGraphQLFields.graphQLFields}
            }
          }
        ''',
        variables: {'input': report.toJson()},
      );
      await Amplify.API.mutate(request: request).response;
      return right(null);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  // Recupera i report dell'utente tramite una query GraphQL
  Future<List<Report>> getUserReports(String uid) async {
    try {
      final request = GraphQLRequest<String>(
        document: '''
          query ListReports(\$uid: ID!) {
            listReports(filter: { uid: { eq: \$uid } }, sortDirection: DESC, sortField: date) {
              items {
                ${ReportGraphQLFields.graphQLFields}
              }
            }
          }
        ''',
        variables: {'uid': uid},
      );
      final response = await Amplify.API.query(request: request).response;
      if (response.data == null) return [];
      final Map<String, dynamic> decoded =
          jsonDecode(response.data!) as Map<String, dynamic>;
      final List<dynamic> items =
          decoded['data']['listReports']['items'] as List<dynamic>;
      return items
          .map((item) => Report.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Errore nel recupero dei report: $e');
    }
  }

  // Elimina un report tramite mutation GraphQL
  Future<Either<Failure, void>> deleteReport(String reportId) async {
    try {
      final request = GraphQLRequest<String>(
        document: '''
          mutation DeleteReport(\$input: DeleteReportInput!) {
            deleteReport(input: \$input) {
              ${ReportGraphQLFields.graphQLFields}
            }
          }
        ''',
        variables: {
          'input': {'id': reportId}
        },
      );
      await Amplify.API.mutate(request: request).response;
      return right(null);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }
}
