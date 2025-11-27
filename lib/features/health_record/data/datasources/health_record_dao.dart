import 'package:sqflite/sqflite.dart';

import '../../../../core/database/app_database.dart';
import '../models/health_record.dart';

class HealthRecordDao {
  static const tableName = 'health_records';

  Future<Database> get _db async => AppDatabase.instance.database;

  Future<List<HealthRecord>> fetchRecords({
    DateTime? startDate,
    DateTime? endDate,
    String? query,
    String? userName,
  }) async {
    final db = await _db;
    final where = <String>[];
    final args = <dynamic>[];

    if (startDate != null && endDate != null) {
      where.add('date BETWEEN ? AND ?');
      args.add(startDate.toIso8601String());
      args.add(endDate.toIso8601String());
    }

    if (query != null && query.trim().isNotEmpty) {
      where.add('(LOWER(userName) LIKE ? OR LOWER(notes) LIKE ?)');
      args.add('%${query.toLowerCase()}%');
      args.add('%${query.toLowerCase()}%');
    }

    if (userName != null && userName.isNotEmpty) {
      where.add('userName = ?');
      args.add(userName);
    }

    final result = await db.query(
      tableName,
      where: where.isNotEmpty ? where.join(' AND ') : null,
      whereArgs: args.isNotEmpty ? args : null,
      orderBy: 'date DESC',
    );

    return result.map(HealthRecord.fromMap).toList();
  }

  Future<int> insertRecord(HealthRecord record) async {
    final db = await _db;
    final data = record.toMap()..remove('id');
    return db.insert(tableName, data);
  }

  Future<int> updateRecord(HealthRecord record) async {
    if (record.id == null) {
      throw ArgumentError('Record id is required for update.');
    }
    final db = await _db;
    final data = record.toMap()..remove('id');
    return db.update(tableName, data, where: 'id = ?', whereArgs: [record.id]);
  }

  Future<int> deleteRecord(int id) async {
    final db = await _db;
    return db.delete(tableName, where: 'id = ?', whereArgs: [id]);
  }
}
