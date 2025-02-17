import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatfood/core/common/error_text.dart';
import 'package:whatfood/core/common/loader.dart';
import 'package:whatfood/features/auth/controller/auth_controller.dart';
import 'package:whatfood/features/report/widgets/report_card.dart';
import 'package:whatfood/models/report_model.dart';
import '../controller/report_controller.dart';

class ReportPage extends ConsumerWidget {
  const ReportPage({super.key});
  static const List<String> toAvoid = ['saturated','salt','energy'];
  Map<String, double> aggregateNutritionalValues(List<ReportModel> reports) {
    final Map<String, double> aggregated = {};
    for (final report in reports) {
      report.nutritionalValues.forEach((key, value) {
        aggregated[key] = (aggregated[key] ?? 0) + value;
      });
    }
    return aggregated;
  }

  List<PieChartSectionData> buildPieChartSections(Map<String, double> aggregatedData) {
    final List<PieChartSectionData> sections = [];
    final colors = [Colors.blue, Colors.red, Colors.green,Colors.orange];
    int idx = 0;
    aggregatedData.forEach((key, value) {
      if(!toAvoid.any((avoid)=>key.toLowerCase().contains(avoid))) {
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
    final List<Color> colors = [Colors.blue, Colors.red, Colors.green, Colors.orange];
    int idx = 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: aggregatedData.keys.map((key) {
        if (toAvoid.any((avoid)=>key.toLowerCase().contains(avoid))) return const SizedBox.shrink();
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
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider)!;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Food Reports'),
      ),
      body: ref.watch(userReportsProvider(user.uid)).when(
        data: (reports) {
          if(reports.isNotEmpty) {
                final aggregatedData = aggregateNutritionalValues(reports);
                final pieChartSections = buildPieChartSections(aggregatedData);
                double totalCalories = 0.0;

                aggregatedData.forEach((key, value) {
                  if (key.toLowerCase().contains('energy')) {
                    totalCalories = value;
                  }
                });
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
                                  child: Text(
                                    '${totalCalories.toStringAsFixed(0)} kcal',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).primaryColor,
                                    ),
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
                          return ReportCard(report: report);
                        },
                      ),
                    ],
                  ),
                );
              }
              else {
            return Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Center(
                  child:
                  Text('No food in your report today',
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

