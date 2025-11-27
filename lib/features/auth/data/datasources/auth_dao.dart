import 'package:sqflite/sqflite.dart';

import '../../../../core/database/app_database.dart';
import '../models/user_account.dart';

class AuthDao {
  Future<Database> get _database async => AppDatabase.instance.database;

  Future<UserAccount?> getUserByEmail(String email) async {
    final db = await _database;
    final result = await db.query(
      'users',
      where: 'LOWER(email) = ?',
      whereArgs: [email.toLowerCase()],
      limit: 1,
    );
    if (result.isEmpty) return null;
    return UserAccount.fromMap(result.first);
  }

  Future<UserAccount?> getUserById(int id) async {
    final db = await _database;
    final result = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (result.isEmpty) return null;
    return UserAccount.fromMap(result.first);
  }

  Future<int> insertUser(UserAccount user) async {
    final db = await _database;
    return db.insert('users', user.toMap()..remove('id'));
  }

  Future<List<UserAccount>> fetchAll() async {
    final db = await _database;
    final result = await db.query('users', orderBy: 'fullName ASC');
    return result.map(UserAccount.fromMap).toList();
  }
}
