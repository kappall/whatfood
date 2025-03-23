import 'dart:async';
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
  Future<Either<Failure, void>> addFoodReport(Report report) async {
    try {
      Map<String, dynamic> reportMap = {
        "input": {
          "id": report.id,
          "uid": report.uid,
          "nutritionalValues": report.nutritionalValues,
          "description": report.description,
          "category": report.category,
          "createdAt": report.createdAt.toString(),
        }
      };

      String graphQLDocument = '''
          mutation CreateReport(\$input: CreateReportInput!) {
            createReport(input: \$input) {
              id
            }
          }
        ''';

      var operation = Amplify.API.mutate(
        request: GraphQLRequest<String>(
          document: graphQLDocument,
          variables: reportMap,
        ),
      );

      final response = await operation.response;

      if (response.errors.isNotEmpty) {
        throw Exception(response.errors.first.message);
      }
      return right(null);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  // Recupera i report dell'utente tramite una query GraphQL
  Stream<List<Report>> getUserReports(String uid) {
    final controller = StreamController<List<Report>>();
    try {
      var reportQuery = '''
          query ListReports {
            listReports(filter: {uid: {eq: "$uid"}}) {
              items {
                ${ReportGraphQLFields.graphQLFields}
              }
            }
          }
        ''';

      final request = GraphQLRequest<String>(document: reportQuery);

      Amplify.API.query(request: request).response.then((response) {
        if (response.errors.isNotEmpty) {
          debugPrint("GraphQL Errors: ${response.errors}");
          controller.addError(response.errors.first.message);
          return;
        }

        if (response.data == null) {
          controller.add([]);
          return;
        }

        try {
          final Map<String, dynamic> jsonResponse = jsonDecode(response.data!);
          print(jsonResponse);
          if (jsonResponse['listReports'] == null ||
              jsonResponse['listReports']['items'] == null) {
            controller.add([]);
            return;
          }

          final List<dynamic> items = jsonResponse['listReports']['items'];
          final posts = items.map((item) => Report.fromJson(item)).toList();

          // Sort by creation date, newest first
          posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));

          controller.add(posts);
        } catch (e, stackTrace) {
          debugPrint("Parse error: $e");
          debugPrint("Stack trace: $stackTrace");
          controller.addError('Error parsing posts: $e');
        }
      }).catchError((error) {
        debugPrint("Query error: $error");
        controller.addError(error);
      });
    } catch (e) {
      throw Exception('Errore nel recupero dei report: $e');
    }
    return controller.stream;
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
