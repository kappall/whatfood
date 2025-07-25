import 'package:hive/hive.dart';

part 'diary_entry.g.dart';

@HiveType(typeId: 0)
class DiaryEntry {
  @HiveField(0)
  final String meal;

  @HiveField(1)
  final DateTime timestamp;

  DiaryEntry({required this.meal, required this.timestamp});

  Map<String, dynamic> toJson() => {
        'meal': meal,
        'timestamp': timestamp.toIso8601String(),
      };

  factory DiaryEntry.fromJson(Map<String, dynamic> json) => DiaryEntry(
        meal: json['meal'],
        timestamp: DateTime.parse(json['timestamp']),
      );
}
