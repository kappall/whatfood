enum MealType {
  breakfast,
  lunch,
  dinner,
  snack;

  String get name {
    switch (this) {
      case MealType.breakfast:
        return 'Breakfast';
      case MealType.lunch:
        return 'Lunch';
      case MealType.dinner:
        return 'Dinner';
      case MealType.snack:
        return 'Snack';
    }
  }

  static MealType? fromString(String? value) {
    if (value == null) return null;
    return MealType.values.firstWhere(
      (type) => type.name.toLowerCase() == value.toLowerCase(),
      orElse: () => MealType.snack,
    );
  }
}
