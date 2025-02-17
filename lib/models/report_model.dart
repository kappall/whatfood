class ReportModel {
  final String id;
  final String uid;
  final DateTime date;
  final Map<String, dynamic> nutritionalValues;
  final String description;
  final String category;

  ReportModel({
    required this.id,
    required this.uid,
    required this.date,
    required this.nutritionalValues,
    required this.description,
    required this.category,
  });

  factory ReportModel.fromMap(Map<String, dynamic> map) {
    return ReportModel(
      id: map['id'] ?? '',
      uid: map['uid'] ?? '',
      date: DateTime.parse(map['date']),
      nutritionalValues: Map<String, dynamic>.from(map['nutritionalValues']),
      description: map['description'] ?? '',
      category: map['category'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'uid': uid,
      'date': date.toIso8601String(),
      'nutritionalValues': nutritionalValues,
      'description': description,
      'category': category,
    };
  }

  @override
  String toString() {
    return 'ReportModel{id: $id, uid: $uid, date: $date, nutritionalValues: $nutritionalValues, description: $description, category: $category}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is ReportModel &&
              runtimeType == other.runtimeType &&
              id == other.id &&
              uid == other.uid &&
              date == other.date &&
              nutritionalValues == other.nutritionalValues &&
              description == other.description &&
              category == other.category;

  @override
  int get hashCode =>
      id.hashCode ^
      uid.hashCode ^
      date.hashCode ^
      nutritionalValues.hashCode ^
      description.hashCode ^
      category.hashCode;
}
