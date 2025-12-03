import '../../../../core/database/app_database.dart';
import '../models/daily_goal.dart';

class GoalDao {
  Future<List<DailyGoal>> fetchGoals({required String userName}) async {
    final db = await AppDatabase.instance.database;
    final maps = await db.query(
      'daily_goals',
      where: 'userName = ?',
      whereArgs: [userName],
    );
    return maps.map((map) => DailyGoal.fromMap(map)).toList();
  }

  Future<DailyGoal?> fetchGoalByUser({required String userName}) async {
    final goals = await fetchGoals(userName: userName);
    return goals.isNotEmpty ? goals.first : null;
  }

  Future<int> insertGoal(DailyGoal goal) async {
    final db = await AppDatabase.instance.database;
    return await db.insert('daily_goals', goal.toMap());
  }

  Future<int> updateGoal(DailyGoal goal) async {
    final db = await AppDatabase.instance.database;
    return await db.update(
      'daily_goals',
      goal.toMap(),
      where: 'id = ?',
      whereArgs: [goal.id],
    );
  }

  Future<int> deleteGoal(int id) async {
    final db = await AppDatabase.instance.database;
    return await db.delete(
      'daily_goals',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}

