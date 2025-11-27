import '../datasources/health_record_dao.dart';
import '../models/health_record.dart';

class HealthRecordRepository {
  HealthRecordRepository({HealthRecordDao? dao})
    : _dao = dao ?? HealthRecordDao();

  final HealthRecordDao _dao;

  Future<List<HealthRecord>> fetchRecords({
    DateTime? startDate,
    DateTime? endDate,
    String? query,
    String? userName,
  }) => _dao.fetchRecords(
    startDate: startDate,
    endDate: endDate,
    query: query,
    userName: userName,
  );

  Future<void> addRecord(HealthRecord record) => _dao.insertRecord(record);

  Future<void> updateRecord(HealthRecord record) => _dao.updateRecord(record);

  Future<void> deleteRecord(int id) => _dao.deleteRecord(id);
}
