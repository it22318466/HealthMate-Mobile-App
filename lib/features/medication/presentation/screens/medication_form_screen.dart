import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../auth/logic/auth_controller.dart';
import '../../data/models/medication.dart';
import '../../logic/medication_controller.dart';

class MedicationFormScreen extends StatefulWidget {
  const MedicationFormScreen({super.key, this.medication});

  final Medication? medication;

  @override
  State<MedicationFormScreen> createState() => _MedicationFormScreenState();
}

class _MedicationFormScreenState extends State<MedicationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _dosageController;
  late TextEditingController _frequencyController;
  late TextEditingController _timeController;
  late TextEditingController _notesController;
  late bool _isActive;

  @override
  void initState() {
    super.initState();
    final med = widget.medication;
    _nameController = TextEditingController(text: med?.name ?? '');
    _dosageController = TextEditingController(text: med?.dosage ?? '');
    _frequencyController = TextEditingController(text: med?.frequency ?? 'Once daily');
    _timeController = TextEditingController(text: med?.time ?? '09:00');
    _notesController = TextEditingController(text: med?.notes ?? '');
    _isActive = med?.isActive ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    _frequencyController.dispose();
    _timeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.medication == null ? 'Add Medication' : 'Edit Medication'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Medication Name *',
                prefixIcon: Icon(Icons.medication),
                hintText: 'e.g., Aspirin',
              ),
              validator: (value) =>
                  value?.isEmpty ?? true ? 'Please enter medication name' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _dosageController,
              decoration: const InputDecoration(
                labelText: 'Dosage *',
                prefixIcon: Icon(Icons.science),
                hintText: 'e.g., 500mg, 1 tablet',
              ),
              validator: (value) =>
                  value?.isEmpty ?? true ? 'Please enter dosage' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _frequencyController.text,
              decoration: const InputDecoration(
                labelText: 'Frequency *',
                prefixIcon: Icon(Icons.schedule),
              ),
              items: const [
                DropdownMenuItem(value: 'Once daily', child: Text('Once daily')),
                DropdownMenuItem(value: 'Twice daily', child: Text('Twice daily')),
                DropdownMenuItem(
                  value: 'Three times daily',
                  child: Text('Three times daily'),
                ),
                DropdownMenuItem(
                  value: 'Every 8 hours',
                  child: Text('Every 8 hours'),
                ),
                DropdownMenuItem(
                  value: 'Every 12 hours',
                  child: Text('Every 12 hours'),
                ),
                DropdownMenuItem(value: 'As needed', child: Text('As needed')),
              ],
              onChanged: (value) {
                if (value != null) {
                  _frequencyController.text = value;
                }
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _timeController,
              decoration: const InputDecoration(
                labelText: 'Time(s) *',
                prefixIcon: Icon(Icons.access_time),
                hintText: 'e.g., 09:00 or 09:00,21:00',
                helperText: 'Use comma to separate multiple times',
              ),
              validator: (value) =>
                  value?.isEmpty ?? true ? 'Please enter time' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes',
                prefixIcon: Icon(Icons.note),
                hintText: 'Additional information (optional)',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            CheckboxListTile(
              title: const Text('Active'),
              subtitle: const Text('Show in active medications list'),
              value: _isActive,
              onChanged: (value) => setState(() => _isActive = value ?? true),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saveMedication,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Save Medication'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveMedication() async {
    if (!_formKey.currentState!.validate()) return;

    final authController = context.read<AuthController>();
    if (authController.currentUser == null) return;

    final controller = context.read<MedicationController>();
    final medication = Medication(
      id: widget.medication?.id,
      userName: authController.currentUser!.fullName,
      name: _nameController.text.trim(),
      dosage: _dosageController.text.trim(),
      frequency: _frequencyController.text.trim(),
      time: _timeController.text.trim(),
      notes: _notesController.text.trim(),
      isActive: _isActive,
    );

    if (widget.medication == null) {
      await controller.addMedication(medication);
    } else {
      await controller.updateMedication(medication);
    }

    if (!mounted) return;
    Navigator.of(context).pop();
  }
}

