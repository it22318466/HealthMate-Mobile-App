import 'package:flutter/material.dart';

import '../../auth/data/models/user_account.dart';
import '../data/models/daily_goal.dart';
import '../data/repositories/goal_repository.dart';

class GoalController extends ChangeNotifier {
  GoalController(this._repository);

  final GoalRepository _repository;

  DailyGoal? _currentGoal;
  bool _isLoading = false;
  UserAccount? _activeUser;

  DailyGoal? get currentGoal => _currentGoal;
  bool get isLoading => _isLoading;

  Future<void> loadGoal() async {
    if (_activeUser == null) {
      _currentGoal = null;
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();
    _currentGoal = await _repository.fetchGoalByUser(
      userName: _activeUser!.fullName,
    );
    _isLoading = false;
    notifyListeners();
  }

  Future<void> saveGoal(DailyGoal goal) async {
    if (_activeUser == null) return;
    await _repository.saveGoal(goal);
    await loadGoal();
  }

  Future<void> syncUser(UserAccount? user) async {
    _activeUser = user;
    await loadGoal();
  }

  GoalProgress calculateProgress({
    required int currentSteps,
    required int currentCalories,
    required int currentWater,
  }) {
    if (_currentGoal == null) {
      return GoalProgress(
        stepsProgress: 0.0,
        caloriesProgress: 0.0,
        waterProgress: 0.0,
      );
    }

    return GoalProgress(
      stepsProgress: (currentSteps / _currentGoal!.stepsGoal).clamp(0.0, 1.0),
      caloriesProgress:
          (currentCalories / _currentGoal!.caloriesGoal).clamp(0.0, 1.0),
      waterProgress: (currentWater / _currentGoal!.waterGoal).clamp(0.0, 1.0),
    );
  }
}

class GoalProgress {
  GoalProgress({
    required this.stepsProgress,
    required this.caloriesProgress,
    required this.waterProgress,
  });

  final double stepsProgress;
  final double caloriesProgress;
  final double waterProgress;
}

