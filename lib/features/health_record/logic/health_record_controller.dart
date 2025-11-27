import 'package:flutter/material.dart';

import '../../auth/data/models/user_account.dart';
import '../data/models/health_record.dart';
import '../data/repositories/health_record_repository.dart';

class HealthRecordController extends ChangeNotifier {
  HealthRecordController(this._repository);

  final HealthRecordRepository _repository;

  List<HealthRecord> _records = [];
  bool _isLoading = false;
  bool _isSaving = false;
  DateTimeRange? _filterRange;
  String _searchQuery = '';
  UserAccount? _activeUser;

  List<HealthRecord> get allRecords => List.unmodifiable(_records);
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  DateTimeRange? get filterRange => _filterRange;
  String get searchQuery => _searchQuery;
  UserAccount? get activeUser => _activeUser;

  List<HealthRecord> get displayedRecords {
    Iterable<HealthRecord> output = _records;
    if (_filterRange != null) {
      output = output.where((record) {
        final date = record.date;
        return !date.isBefore(_filterRange!.start) &&
            !date.isAfter(_filterRange!.end);
      });
    }

    if (_searchQuery.isNotEmpty) {
      final value = _searchQuery.toLowerCase();
      output = output.where(
        (record) =>
            record.userName.toLowerCase().contains(value) ||
            record.notes.toLowerCase().contains(value),
      );
    }

    return output.toList()..sort((a, b) => b.date.compareTo(a.date));
  }

  List<HealthRecord> get recentRecords {
    final sorted = [..._records]..sort((a, b) => b.date.compareTo(a.date));
    return sorted.take(7).toList();
  }

  HealthSummary get todaySummary {
    final todayRecords = _records.where(
      (record) => _isSameDay(record.date, DateTime.now()),
    );
    return HealthSummary.fromRecords(todayRecords.toList());
  }

  HealthSummary get overallSummary => HealthSummary.fromRecords(_records);

  Future<void> loadRecords() async {
    if (_activeUser == null) {
      _records = [];
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();
    _records = await _repository.fetchRecords(userName: _activeUser!.fullName);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addRecord(HealthRecord record) async {
    if (_activeUser == null) return;
    _setSaving(true);
    await _repository.addRecord(
      record.copyWith(
        userName: record.userName.isEmpty
            ? _activeUser!.fullName
            : record.userName,
      ),
    );
    await loadRecords();
    _setSaving(false);
  }

  Future<void> updateRecord(HealthRecord record) async {
    if (_activeUser == null) return;
    _setSaving(true);
    await _repository.updateRecord(record);
    await loadRecords();
    _setSaving(false);
  }

  Future<void> deleteRecord(int id) async {
    if (_activeUser == null) return;
    _setSaving(true);
    await _repository.deleteRecord(id);
    await loadRecords();
    _setSaving(false);
  }

  void setSearchQuery(String value) {
    _searchQuery = value;
    notifyListeners();
  }

  void setDateRange(DateTimeRange? range) {
    _filterRange = range;
    notifyListeners();
  }

  void clearFilters() {
    _filterRange = null;
    _searchQuery = '';
    notifyListeners();
  }

  Future<void> syncUser(UserAccount? user) async {
    final currentId = _activeUser?.id;
    final nextId = user?.id;
    _activeUser = user;
    if (currentId == nextId) return;
    if (_activeUser == null) {
      _records = [];
      notifyListeners();
      return;
    }
    await loadRecords();
  }

  void _setSaving(bool value) {
    _isSaving = value;
    notifyListeners();
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

class HealthSummary {
  HealthSummary({
    required this.totalSteps,
    required this.totalCalories,
    required this.totalWater,
    required this.averageMood,
  });

  final int totalSteps;
  final int totalCalories;
  final int totalWater;
  final double averageMood;

  factory HealthSummary.fromRecords(List<HealthRecord> records) {
    if (records.isEmpty) {
      return HealthSummary(
        totalSteps: 0,
        totalCalories: 0,
        totalWater: 0,
        averageMood: 0,
      );
    }

    final steps = records.fold<int>(0, (sum, record) => sum + record.steps);
    final calories = records.fold<int>(
      0,
      (sum, record) => sum + record.calories,
    );
    final water = records.fold<int>(0, (sum, record) => sum + record.water);
    final mood = records.fold<int>(0, (sum, record) => sum + record.mood);

    return HealthSummary(
      totalSteps: steps,
      totalCalories: calories,
      totalWater: water,
      averageMood: mood / records.length,
    );
  }
}
