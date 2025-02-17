import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/report_model.dart';
import '../controller/report_controller.dart';

class ReportCard extends ConsumerWidget {
  final ReportModel report;

  const ReportCard({
    super.key,
    required this.report,
  });

  void _deleteReport(BuildContext context, WidgetRef ref) {
    ref.read(reportControllerProvider.notifier).deleteReport(
          context: context,
          reportId: report.id,
        );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(padding: EdgeInsets.only(top: 20),child:Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.6,
                      child:
                        Text(
                        report.description,
                        softWrap: true,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          ),
                        ),
                    ),
                    Text(
                      '${report.date.day}/${report.date.month}/${report.date.year}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),),
                const SizedBox(height: 8),
                Text(
                  'Category: ${report.category}',
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 8),
                ...report.nutritionalValues.entries.map(
                  (entry) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(entry.key),
                        Text('${entry.value}'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.red),
              onPressed: () => _deleteReport(context, ref),
            ),
          ),
        ],
      ),
    );
  }
}
