import 'package:intl/intl.dart';

class HealthRecord {
  HealthRecord({
    this.id,
    required this.userName,
    required this.date,
    required this.steps,
    required this.calories,
    required this.water,
    this.mood = 3,
    this.notes = '',
  });

  final int? id;
  final String userName;
  final DateTime date;
  final int steps;
  final int calories;
  final int water; // ml
  final int mood; // 1-5 scale
  final String notes;

  factory HealthRecord.fromMap(Map<String, dynamic> map) {
    return HealthRecord(
      id: map['id'] as int?,
      userName: map['userName'] as String,
      date: DateTime.parse(map['date'] as String),
      steps: map['steps'] as int,
      calories: map['calories'] as int,
      water: map['water'] as int,
      mood: (map['mood'] as int?) ?? 3,
      notes: (map['notes'] as String?) ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userName': userName,
      'date': DateFormat("yyyy-MM-dd'T'HH:mm:ss").format(date),
      'steps': steps,
      'calories': calories,
      'water': water,
      'mood': mood,
      'notes': notes,
    };
  }

  HealthRecord copyWith({
    int? id,
    String? userName,
    DateTime? date,
    int? steps,
    int? calories,
    int? water,
    int? mood,
    String? notes,
  }) {
    return HealthRecord(
      id: id ?? this.id,
      userName: userName ?? this.userName,
      date: date ?? this.date,
      steps: steps ?? this.steps,
      calories: calories ?? this.calories,
      water: water ?? this.water,
      mood: mood ?? this.mood,
      notes: notes ?? this.notes,
    );
  }
}
