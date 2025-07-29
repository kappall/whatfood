import 'package:hive/hive.dart';

part 'diary_entry.g.dart';

@HiveType(typeId: 3)
class DiaryEntry {
  @HiveField(0)
  final String meal;

  @HiveField(1)
  final DateTime timestamp;

  @HiveField(2)
  final String? quantity;

  @HiveField(3)
  final int? calories;

  @HiveField(4)
  final MealType type;

  @HiveField(5)
  final int key;

  DiaryEntry({
    required this.meal,
    required this.timestamp,
    this.quantity,
    this.calories,
    this.type = MealType.other,
    required this.key,
  });

  Map<String, dynamic> toJson() => {
        'meal': meal,
        'timestamp': timestamp.toIso8601String(),
        'quantity': quantity,
        'calories': calories,
        'type': type.name,
      };

  factory DiaryEntry.fromJson(Map<String, dynamic> json) => DiaryEntry(
        meal: json['meal'],
        timestamp: DateTime.parse(json['timestamp']),
        quantity: json['quantity'],
        calories: json['calories'],
        type: MealType.values.firstWhere(
          (e) => e.name == json['type'],
          orElse: () => MealType.other,
        ),
        key: json['key'],
      );
}

@HiveType(typeId: 2)
enum MealType {
  @HiveField(0)
  breakfast,
  @HiveField(1)
  lunch,
  @HiveField(2)
  dinner,
  @HiveField(3)
  snack,
  @HiveField(4)
  other,
}
