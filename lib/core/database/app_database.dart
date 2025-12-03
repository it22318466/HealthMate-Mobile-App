import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../utils/password_hasher.dart';

class AppDatabase {
  AppDatabase._();

  static final AppDatabase instance = AppDatabase._();

  static const _dbName = 'healthmate.db';
  static const _dbVersion = 3;

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);
    return openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await _createUserTable(db);
    await _createHealthRecordTable(db);
    await _createDailyGoalsTable(db);
    await _createMedicationsTable(db);
    await _seedData(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await _createUserTable(db);
    }
    if (oldVersion < 3) {
      await _createDailyGoalsTable(db);
      await _createMedicationsTable(db);
    }
  }

  Future<void> _createUserTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        fullName TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        passwordHash TEXT NOT NULL
      )
    ''');
  }

  Future<void> _createHealthRecordTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS health_records(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userName TEXT NOT NULL,
        date TEXT NOT NULL,
        steps INTEGER NOT NULL,
        calories INTEGER NOT NULL,
        water INTEGER NOT NULL,
        mood INTEGER,
        notes TEXT
      )
    ''');
  }

  Future<void> _createDailyGoalsTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS daily_goals(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userName TEXT NOT NULL,
        stepsGoal INTEGER NOT NULL,
        caloriesGoal INTEGER NOT NULL,
        waterGoal INTEGER NOT NULL,
        reminderEnabled INTEGER DEFAULT 1,
        reminderTime TEXT
      )
    ''');
  }

  Future<void> _createMedicationsTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS medications(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userName TEXT NOT NULL,
        name TEXT NOT NULL,
        dosage TEXT NOT NULL,
        frequency TEXT NOT NULL,
        time TEXT NOT NULL,
        notes TEXT,
        isActive INTEGER DEFAULT 1
      )
    ''');
  }

  Future<void> _seedData(Database db) async {
    final defaultUser = {
      'fullName': 'Alex Morgan',
      'email': 'alex@healthmate.com',
      'passwordHash': PasswordHasher.hash('password123'),
    };
    final userId = await db.insert('users', defaultUser);

    final now = DateTime.now();
    final dummyRecords = List.generate(5, (index) {
      final date = now.subtract(Duration(days: index));
      return {
        'userName': defaultUser['fullName'],
        'date': date.toIso8601String(),
        'steps': 6000 + (index * 500),
        'calories': 1800 - (index * 50),
        'water': 2200 + (index * 100),
        'mood': 3 + (index % 3),
        'notes': 'Auto-generated record #$index for user $userId',
      };
    });

    for (final record in dummyRecords) {
      await db.insert('health_records', record);
    }
  }
}
