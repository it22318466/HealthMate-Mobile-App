import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/medication.dart';
import '../../logic/medication_controller.dart';
import '../widgets/medication_card.dart';
import 'medication_form_screen.dart';

class MedicationListScreen extends StatelessWidget {
  const MedicationListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MedicationController>(
      builder: (context, controller, _) {
        if (controller.isLoading && controller.medications.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        final activeMedications = controller.activeMedications;
        final inactiveMedications = controller.medications
            .where((m) => !m.isActive)
            .toList();

        return RefreshIndicator(
          onRefresh: controller.loadMedications,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Medications',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              if (activeMedications.isEmpty && inactiveMedications.isEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Icon(
                          Icons.medication_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No medications added',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Add your medications to track them',
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () => _showMedicationForm(context, controller),
                          icon: const Icon(Icons.add),
                          label: const Text('Add Medication'),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (activeMedications.isNotEmpty) ...[
                      Text(
                        'Active',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      ...activeMedications.map(
                        (medication) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: MedicationCard(
                            medication: medication,
                            onTap: () => _showMedicationForm(
                              context,
                              controller,
                              medication: medication,
                            ),
                            onToggle: () => controller.toggleMedicationStatus(
                              medication.id!,
                            ),
                            onDelete: () => _confirmDelete(
                              context,
                              controller,
                              medication,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    if (inactiveMedications.isNotEmpty) ...[
                      Text(
                        'Inactive',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                      const SizedBox(height: 8),
                      ...inactiveMedications.map(
                        (medication) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: MedicationCard(
                            medication: medication,
                            onTap: () => _showMedicationForm(
                              context,
                              controller,
                              medication: medication,
                            ),
                            onToggle: () => controller.toggleMedicationStatus(
                              medication.id!,
                            ),
                            onDelete: () => _confirmDelete(
                              context,
                              controller,
                              medication,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
            ],
          ),
        );
      },
    );
  }

  void _showMedicationForm(
    BuildContext context,
    MedicationController controller, {
    Medication? medication,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MedicationFormScreen(medication: medication),
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    MedicationController controller,
    Medication medication,
  ) {
    final messenger = ScaffoldMessenger.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Medication'),
        content: Text('Are you sure you want to delete ${medication.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await controller.deleteMedication(medication.id!);
              if (context.mounted) Navigator.pop(context);
              messenger.showSnackBar(
                const SnackBar(
                  content: Text('Medication deleted successfully'),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

