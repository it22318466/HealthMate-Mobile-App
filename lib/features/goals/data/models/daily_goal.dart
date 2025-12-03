class DailyGoal {
  DailyGoal({
    this.id,
    required this.userName,
    required this.stepsGoal,
    required this.caloriesGoal,
    required this.waterGoal,
    this.reminderEnabled = true,
    this.reminderTime,
  });

  final int? id;
  final String userName;
  final int stepsGoal;
  final int caloriesGoal;
  final int waterGoal; // ml
  final bool reminderEnabled;
  final String? reminderTime; // HH:mm format

  factory DailyGoal.fromMap(Map<String, dynamic> map) {
    return DailyGoal(
      id: map['id'] as int?,
      userName: map['userName'] as String,
      stepsGoal: map['stepsGoal'] as int,
      caloriesGoal: map['caloriesGoal'] as int,
      waterGoal: map['waterGoal'] as int,
      reminderEnabled: (map['reminderEnabled'] as int? ?? 1) == 1,
      reminderTime: map['reminderTime'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userName': userName,
      'stepsGoal': stepsGoal,
      'caloriesGoal': caloriesGoal,
      'waterGoal': waterGoal,
      'reminderEnabled': reminderEnabled ? 1 : 0,
      'reminderTime': reminderTime,
    };
  }

  DailyGoal copyWith({
    int? id,
    String? userName,
    int? stepsGoal,
    int? caloriesGoal,
    int? waterGoal,
    bool? reminderEnabled,
    String? reminderTime,
  }) {
    return DailyGoal(
      id: id ?? this.id,
      userName: userName ?? this.userName,
      stepsGoal: stepsGoal ?? this.stepsGoal,
      caloriesGoal: caloriesGoal ?? this.caloriesGoal,
      waterGoal: waterGoal ?? this.waterGoal,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      reminderTime: reminderTime ?? this.reminderTime,
    );
  }
}

