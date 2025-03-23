import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:whatfood/core/utils.dart';
import 'package:whatfood/features/auth/controller/auth_controller.dart';
import 'package:whatfood/features/report/repository/report_repository.dart';
import 'package:whatfood/models/Report.dart';

final reportControllerProvider =
    StateNotifierProvider<ReportController, bool>((ref) {
  return ReportController(
    reportRepository: ref.watch(reportRepositoryProvider),
    ref: ref,
  );
});

final userReportsProvider = StreamProvider.family((ref, String uid) {
  final reportController = ref.watch(reportControllerProvider.notifier);
  return reportController.getUserReports(uid);
});

class ReportController extends StateNotifier<bool> {
  final ReportRepository _reportRepository;
  final Ref _ref;

  ReportController({
    required ReportRepository reportRepository,
    required Ref ref,
  })  : _reportRepository = reportRepository,
        _ref = ref,
        super(false);

  void addFoodReport({
    required BuildContext context,
    required String nutritionalValues,
    required String description,
    required String category,
  }) async {
    try {
      state = true;
      final user = _ref.read(userProvider);
      if (user == null) {
        throw 'User not logged in';
      }

      String reportId = const Uuid().v1();
      Report report = Report(
        id: reportId,
        createdAt: TemporalDateTime.now(),
        nutritionalValues: nutritionalValues,
        description: description,
        category: category,
        uid: user.id,
      );

      final res = await _reportRepository.addFoodReport(report);

      res.fold((failure) {
        showSnackBar(context, failure.message);
      }, (_) {
        showSnackBar(context, 'Food added to your report successfully');
      });
    } catch (e) {
      if (context.mounted) {
        showSnackBar(context, e.toString());
      }
    } finally {
      state = false;
    }
  }

  void deleteReport({
    required BuildContext context,
    required String reportId,
  }) async {
    final uid = _ref.read(userProvider)?.id ?? '';
    if (uid.isEmpty) return;

    final res = await _reportRepository.deleteReport(reportId);
    res.fold(
      (l) => showSnackBar(context, l.message),
      (r) => null,
    );
  }

  Stream<List<Report>> getUserReports(String uid) {
    return _reportRepository.getUserReports(uid);
  }
}
