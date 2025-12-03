import 'package:flutter/material.dart';

import '../../auth/data/models/user_account.dart';
import '../data/models/medication.dart';
import '../data/repositories/medication_repository.dart';

class MedicationController extends ChangeNotifier {
  MedicationController(this._repository);

  final MedicationRepository _repository;

  List<Medication> _medications = [];
  bool _isLoading = false;
  bool _isSaving = false;
  UserAccount? _activeUser;

  List<Medication> get medications => List.unmodifiable(_medications);
  List<Medication> get activeMedications =>
      _medications.where((m) => m.isActive).toList();
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  UserAccount? get activeUser => _activeUser;

  Future<void> loadMedications() async {
    if (_activeUser == null) {
      _medications = [];
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();
    _medications = await _repository.fetchMedications(
      userName: _activeUser!.fullName,
    );
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addMedication(Medication medication) async {
    if (_activeUser == null) return;
    _setSaving(true);
    await _repository.addMedication(
      medication.copyWith(
        userName: medication.userName.isEmpty
            ? _activeUser!.fullName
            : medication.userName,
      ),
    );
    await loadMedications();
    _setSaving(false);
  }

  Future<void> updateMedication(Medication medication) async {
    if (_activeUser == null) return;
    _setSaving(true);
    await _repository.updateMedication(medication);
    await loadMedications();
    _setSaving(false);
  }

  Future<void> deleteMedication(int id) async {
    if (_activeUser == null) return;
    _setSaving(true);
    await _repository.deleteMedication(id);
    await loadMedications();
    _setSaving(false);
  }

  Future<void> toggleMedicationStatus(int id) async {
    final medication = _medications.firstWhere((m) => m.id == id);
    await updateMedication(medication.copyWith(isActive: !medication.isActive));
  }

  Future<void> syncUser(UserAccount? user) async {
    final currentId = _activeUser?.id;
    final nextId = user?.id;
    _activeUser = user;
    if (currentId == nextId) return;
    if (_activeUser == null) {
      _medications = [];
      notifyListeners();
      return;
    }
    await loadMedications();
  }

  void _setSaving(bool value) {
    _isSaving = value;
    notifyListeners();
  }
}

