class Medication {
  Medication({
    this.id,
    required this.userName,
    required this.name,
    required this.dosage,
    required this.frequency,
    required this.time,
    this.notes = '',
    this.isActive = true,
  });

  final int? id;
  final String userName;
  final String name;
  final String dosage; // e.g., "500mg", "1 tablet"
  final String frequency; // e.g., "Once daily", "Twice daily", "Every 8 hours"
  final String time; // e.g., "09:00", "09:00,21:00"
  final String notes;
  final bool isActive;

  factory Medication.fromMap(Map<String, dynamic> map) {
    return Medication(
      id: map['id'] as int?,
      userName: map['userName'] as String,
      name: map['name'] as String,
      dosage: map['dosage'] as String,
      frequency: map['frequency'] as String,
      time: map['time'] as String,
      notes: (map['notes'] as String?) ?? '',
      isActive: (map['isActive'] as int? ?? 1) == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userName': userName,
      'name': name,
      'dosage': dosage,
      'frequency': frequency,
      'time': time,
      'notes': notes,
      'isActive': isActive ? 1 : 0,
    };
  }

  Medication copyWith({
    int? id,
    String? userName,
    String? name,
    String? dosage,
    String? frequency,
    String? time,
    String? notes,
    bool? isActive,
  }) {
    return Medication(
      id: id ?? this.id,
      userName: userName ?? this.userName,
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      frequency: frequency ?? this.frequency,
      time: time ?? this.time,
      notes: notes ?? this.notes,
      isActive: isActive ?? this.isActive,
    );
  }

  List<String> get times => time.split(',').map((t) => t.trim()).toList();
}

