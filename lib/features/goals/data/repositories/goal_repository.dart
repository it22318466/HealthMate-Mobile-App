import '../datasources/goal_dao.dart';
import '../models/daily_goal.dart';

class GoalRepository {
  GoalRepository(this._dao);

  final GoalDao _dao;

  Future<List<DailyGoal>> fetchGoals({required String userName}) async {
    return await _dao.fetchGoals(userName: userName);
  }

  Future<DailyGoal?> fetchGoalByUser({required String userName}) async {
    return await _dao.fetchGoalByUser(userName: userName);
  }

  Future<void> saveGoal(DailyGoal goal) async {
    final existing = await _dao.fetchGoalByUser(userName: goal.userName);
    if (existing != null) {
      await _dao.updateGoal(goal.copyWith(id: existing.id));
    } else {
      await _dao.insertGoal(goal);
    }
  }

  Future<void> deleteGoal(int id) async {
    await _dao.deleteGoal(id);
  }
}

