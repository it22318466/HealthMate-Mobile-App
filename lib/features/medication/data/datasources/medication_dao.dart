import '../../../../core/database/app_database.dart';
import '../models/medication.dart';

class MedicationDao {
  Future<List<Medication>> fetchMedications({required String userName}) async {
    final db = await AppDatabase.instance.database;
    final maps = await db.query(
      'medications',
      where: 'userName = ?',
      whereArgs: [userName],
      orderBy: 'name ASC',
    );
    return maps.map((map) => Medication.fromMap(map)).toList();
  }

  Future<Medication?> fetchMedication(int id) async {
    final db = await AppDatabase.instance.database;
    final maps = await db.query(
      'medications',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return Medication.fromMap(maps.first);
  }

  Future<int> insertMedication(Medication medication) async {
    final db = await AppDatabase.instance.database;
    return await db.insert('medications', medication.toMap());
  }

  Future<int> updateMedication(Medication medication) async {
    final db = await AppDatabase.instance.database;
    return await db.update(
      'medications',
      medication.toMap(),
      where: 'id = ?',
      whereArgs: [medication.id],
    );
  }

  Future<int> deleteMedication(int id) async {
    final db = await AppDatabase.instance.database;
    return await db.delete(
      'medications',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}

