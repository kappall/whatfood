import 'package:flutter/material.dart';

class NutriScoreWidget extends StatelessWidget {
  final String grade;

  const NutriScoreWidget({super.key, required this.grade});

  @override
  Widget build(BuildContext context) {
    final Color color = switch (grade.toLowerCase()) {
      'a' => const Color(0xFF038141),
      'b' => const Color(0xFF85BB2F),
      'c' => const Color(0xFFFECB02),
      'd' => const Color(0xFFEE8100),
      'e' => const Color(0xFFE63E11),
      _ => Colors.grey,
    };

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(
            'NutriScore:',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            grade.toUpperCase(),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
