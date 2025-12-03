import '../datasources/medication_dao.dart';
import '../models/medication.dart';

class MedicationRepository {
  MedicationRepository(this._dao);

  final MedicationDao _dao;

  Future<List<Medication>> fetchMedications({required String userName}) async {
    return await _dao.fetchMedications(userName: userName);
  }

  Future<Medication?> fetchMedication(int id) async {
    return await _dao.fetchMedication(id);
  }

  Future<void> addMedication(Medication medication) async {
    await _dao.insertMedication(medication);
  }

  Future<void> updateMedication(Medication medication) async {
    await _dao.updateMedication(medication);
  }

  Future<void> deleteMedication(int id) async {
    await _dao.deleteMedication(id);
  }
}

