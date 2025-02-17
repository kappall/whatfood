import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import '../../../core/constants/firebase_constants.dart';
import '../../../core/failure.dart';
import '../../../core/providers/firebase_providers.dart';
import '../../../core/type_def.dart';
import '../../../models/report_model.dart';

final reportRepositoryProvider = Provider((ref) {
  return ReportRepository(firestore: ref.watch(firestoreProvider));
});

class ReportRepository {
  final FirebaseFirestore _firestore;

  ReportRepository({required FirebaseFirestore firestore})
      : _firestore = firestore;

  CollectionReference get _reports =>
      _firestore.collection(FirebaseConstants.reportsCollection);

  FutureVoid addFoodReport(ReportModel report) async {
    try {
      return right(_reports.doc(report.id).set(report.toMap()));
    } on FirebaseException catch (e) {
      throw (e.message!);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Stream<List<ReportModel>> getUserReports(String uid) {
    return _reports
        .where('uid', isEqualTo: uid)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ReportModel.fromMap({
                  ...doc.data() as Map<String, dynamic>,
                  'id': doc.id,
                }))
            .toList());
  }

  FutureVoid deleteReport(String reportId, String uid) async {
    try {
      debugPrint('Deleting report $reportId');
      await _reports.doc(reportId).delete();
      return right(null);
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }
}
