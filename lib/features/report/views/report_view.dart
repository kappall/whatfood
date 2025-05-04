import 'dart:convert';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatfood/core/common/error_text.dart';
import 'package:whatfood/core/common/loader.dart';
import 'package:whatfood/features/auth/controller/auth_controller.dart';
import 'package:whatfood/features/report/controller/report_controller.dart';
import 'package:whatfood/core/common/report_card.dart';
import 'package:whatfood/models/Report.dart';

class ReportView extends ConsumerStatefulWidget {
  const ReportView({super.key});

  @override
  ConsumerState<ReportView> createState() => _ReportViewState();
}

class _ReportViewState extends ConsumerState<ReportView> {
  bool isSelectionMode = false;
  List<String> selectedReports = [];

  void toggleSelection(Report report) {
    setState(() {
      if (selectedReports.contains(report.id)) {
        selectedReports.remove(report.id);
      } else {
        selectedReports.add(report.id);
      }
    });
  }

  void deleteSelectedReports(BuildContext context) {
    for (final reportId in selectedReports) {
      ref
          .read(reportControllerProvider.notifier)
          .deleteReport(
            context: context,
            reportId: reportId,
          )
          .then((_) {
        ref.invalidate(userReportsProvider(ref.read(userProvider)!.id));
      });
    }
    setState(() {
      selectedReports.clear();
      isSelectionMode = false;
    });
  }

  static const List<String> toAvoid = ['saturated', 'salt', 'energy', 'fiber'];

  Map<String, double> aggregateNutritionalValues(List<Report> reports) {
    final Map<String, double> aggregated = {};
    for (final report in reports) {
      (jsonDecode(report.nutritionalValues) as Map<String, dynamic>)
          .forEach((key, value) {
        aggregated[key] = (aggregated[key] ?? 0) + value;
      });
    }
    return aggregated;
  }

  List<PieChartSectionData> buildPieChartSections(
      Map<String, double> aggregatedData) {
    final List<PieChartSectionData> sections = [];
    final colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.grey
    ];
    int idx = 0;
    aggregatedData.forEach((key, value) {
      if (!toAvoid.any((avoid) => key.toLowerCase().contains(avoid))) {
        sections.add(PieChartSectionData(
          color: colors[idx % colors.length],
          value: value,
          title: '',
          radius: 30,
        ));
        idx++;
      }
    });
    return sections;
  }

  Widget buildLegend(Map<String, double> aggregatedData) {
    final List<Color> colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange
    ];
    int idx = 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: aggregatedData.keys.map((key) {
        if (toAvoid.any((avoid) => key.toLowerCase().contains(avoid))) {
          return const SizedBox.shrink();
        }
        final color = colors[idx % colors.length];
        idx++;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 10, height: 10, color: color),
              const SizedBox(width: 8),
              Text(key, style: const TextStyle(fontSize: 12)),
            ],
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(
            isSelectionMode ? '${selectedReports.length} selected' : 'Reports'),
        actions: [
          if (!isSelectionMode)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () {
                setState(() {
                  isSelectionMode = true;
                });
              },
            )
          else ...[
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: selectedReports.isNotEmpty
                  ? () => deleteSelectedReports(context)
                  : null,
            ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                setState(() {
                  selectedReports.clear();
                  isSelectionMode = false;
                });
              },
            ),
          ],
        ],
      ),
      body: ref.watch(userReportsProvider(user.id)).when(
            data: (data) {
              final reports = data.toList();
              if (reports.isNotEmpty) {
                final aggregatedData = aggregateNutritionalValues(reports);
                double totalCalories = 0.0;
                aggregatedData.forEach((key, value) {
                  if (key.toLowerCase().contains('energy')) {
                    totalCalories = value;
                  }
                });
                final pieChartSections = buildPieChartSections(aggregatedData);

                return SingleChildScrollView(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 200,
                            height: 200,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                PieChart(
                                  PieChartData(
                                    sections: pieChartSections,
                                    sectionsSpace: 0,
                                    centerSpaceRadius: 60,
                                  ),
                                ),
                                Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        totalCalories.toStringAsFixed(0),
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Divider(
                                        color: Colors.white,
                                        thickness: 2,
                                        endIndent: 65,
                                        indent: 50,
                                      ),
                                      Text(
                                        user.dailyIntake.toStringAsFixed(0),
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          buildLegend(aggregatedData),
                        ],
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: reports.length,
                        itemBuilder: (context, index) {
                          final report = reports[index];
                          return ReportCard(
                            report: report,
                            isSelectionMode: isSelectionMode,
                            isSelected: selectedReports.contains(report.id),
                            onSelected: toggleSelection,
                          );
                        },
                      ),
                    ],
                  ),
                );
              } else {
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Center(
                    child: Text(
                      'No food in your report today',
                      style: TextStyle(fontSize: 24),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }
            },
            error: (error, stackTrace) {
              debugPrint(error.toString());
              return ErrorText(error: error.toString());
            },
            loading: () => const Loader(),
          ),
    );
  }
}
