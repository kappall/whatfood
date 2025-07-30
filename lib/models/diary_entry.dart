import 'package:hive/hive.dart';

part 'diary_entry.g.dart';

@HiveType(typeId: 4)
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

  @HiveField(6)
  final double? protein;

  @HiveField(7)
  final double? carbs;

  @HiveField(8)
  final double? fat;

  DiaryEntry({
    required this.meal,
    required this.timestamp,
    this.quantity,
    this.calories,
    this.type = MealType.other,
    required this.key,
    this.protein,
    this.carbs,
    this.fat,
  });

  Map<String, dynamic> toJson() => {
        'meal': meal,
        'timestamp': timestamp.toIso8601String(),
        'quantity': quantity,
        'calories': calories,
        'type': type.name,
        'key': key,
        'protein': protein,
        'carbs': carbs,
        'fat': fat,
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
        protein: (json['protein'] as num?)?.toDouble(),
        carbs: (json['carbs'] as num?)?.toDouble(),
        fat: (json['fat'] as num?)?.toDouble(),
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
