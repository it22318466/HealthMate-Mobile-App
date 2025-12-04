import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../auth/logic/auth_controller.dart';
import '../../data/models/health_record.dart';
import '../../logic/health_record_controller.dart';

class RecordFormScreen extends StatefulWidget {
  const RecordFormScreen({super.key, this.existingRecord});

  final HealthRecord? existingRecord;

  @override
  State<RecordFormScreen> createState() => _RecordFormScreenState();
}

class _RecordFormScreenState extends State<RecordFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _stepsController;
  late final TextEditingController _caloriesController;
  late final TextEditingController _waterController;
  late final TextEditingController _notesController;
  late DateTime _selectedDate;
  double _mood = 3;

  @override
  void initState() {
    super.initState();
    final record = widget.existingRecord;
    _stepsController = TextEditingController(
      text: record?.steps.toString() ?? '',
    );
    _caloriesController = TextEditingController(
      text: record?.calories.toString() ?? '',
    );
    _waterController = TextEditingController(
      text: record?.water.toString() ?? '',
    );
    _notesController = TextEditingController(text: record?.notes ?? '');
    _selectedDate = record?.date ?? DateTime.now();
    _mood = (record?.mood ?? 3).toDouble();
  }

  @override
  void dispose() {
    _stepsController.dispose();
    _caloriesController.dispose();
    _waterController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingRecord != null;
    final controller = context.watch<HealthRecordController>();
    final authUser = context.watch<AuthController>().currentUser;
    final ownerName =
        widget.existingRecord?.userName ?? authUser?.fullName ?? 'Guest';

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Update Record' : 'Add Record')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const CircleAvatar(child: Icon(Icons.person)),
              title: Text(ownerName),
              subtitle: const Text('Records will be tagged with this user'),
            ),
            const Divider(),
            _DateField(date: _selectedDate, onTap: _pickDate),
            const SizedBox(height: 12),
            _numberField(
              controller: _stepsController,
              label: 'Steps walked',
              suffix: 'steps',
            ),
            const SizedBox(height: 12),
            _numberField(
              controller: _caloriesController,
              label: 'Calories burned',
              suffix: 'kcal',
            ),
            const SizedBox(height: 12),
            _numberField(
              controller: _waterController,
              label: 'Water intake',
              suffix: 'ml',
            ),
            const SizedBox(height: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Mood (1 - low, 5 - great)'),
                Slider(
                  value: _mood,
                  divisions: 4,
                  min: 1,
                  max: 5,
                  label: _mood.toStringAsFixed(0),
                  onChanged: (value) => setState(() => _mood = value),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _notesController,
              minLines: 2,
              maxLines: 5,
              decoration: const InputDecoration(labelText: 'Notes'),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: controller.isSaving ? null : _submit,
              child: controller.isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(isEditing ? 'Update record' : 'Save record'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _numberField({
    required TextEditingController controller,
    required String label,
    required String suffix,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(labelText: label, suffixText: suffix),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Required';
        }
        final number = int.tryParse(value);
        if (number == null || number <= 0) {
          return 'Enter a valid number';
        }
        return null;
      },
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(DateTime.now().year - 5),
      lastDate: DateTime(DateTime.now().year + 1),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final authUser = context.read<AuthController>().currentUser;
    final messenger = ScaffoldMessenger.of(context);

    final record = HealthRecord(
      id: widget.existingRecord?.id,
      userName:
          widget.existingRecord?.userName ?? authUser?.fullName ?? 'Guest',
      date: _selectedDate,
      steps: int.parse(_stepsController.text),
      calories: int.parse(_caloriesController.text),
      water: int.parse(_waterController.text),
      mood: _mood.round(),
      notes: _notesController.text.trim(),
    );

    final controller = context.read<HealthRecordController>();
    if (widget.existingRecord == null) {
      await controller.addRecord(record);
      if (!mounted) return;
      messenger.showSnackBar(
        const SnackBar(content: Text('Record added successfully')),
      );
    } else {
      await controller.updateRecord(record);
      if (!mounted) return;
      messenger.showSnackBar(
        const SnackBar(content: Text('Record updated successfully')),
      );
    }
    Navigator.of(context).pop();
  }
}

class _DateField extends StatelessWidget {
  const _DateField({required this.date, required this.onTap});

  final DateTime date;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: InputDecorator(
        decoration: const InputDecoration(labelText: 'Date'),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(DateFormat.yMMMMd().format(date)),
            const Icon(Icons.calendar_today, size: 18),
          ],
        ),
      ),
    );
  }
}
