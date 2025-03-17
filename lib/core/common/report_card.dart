import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:whatfood/models/report_model.dart';

class ReportCard extends ConsumerStatefulWidget {
  final ReportModel report;
  final bool isSelectionMode;
  final bool isSelected;
  final Function(ReportModel) onSelected;

  const ReportCard({
    super.key,
    required this.report,
    required this.isSelectionMode,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  ConsumerState<ReportCard> createState() => _ReportCardState();
}

class _ReportCardState extends ConsumerState<ReportCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: GestureDetector(
        onTap: () {
          if (widget.isSelectionMode) {
            widget.onSelected(widget.report);
          } else {
            setState(() {
              _isExpanded = !_isExpanded;
            });
          }
        },
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (widget.isSelectionMode)
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Icon(
                            widget.isSelected
                                ? Icons.check_circle
                                : Icons.circle_outlined,
                            color: widget.isSelected ? Colors.red : Colors.grey,
                          ),
                        ),
                      Expanded(
                        child: Text(
                          widget.report.description,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (!widget.isSelectionMode)
                        Icon(_isExpanded
                            ? Icons.expand_less
                            : Icons.expand_more),
                    ],
                  ),
                  if (_isExpanded && !widget.isSelectionMode) ...[
                    const SizedBox(height: 16),
                    Text(
                      '${widget.report.date.day}/${widget.report.date.month}/${widget.report.date.year}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Category: ${widget.report.category}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    ...widget.report.nutritionalValues.entries.map(
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
