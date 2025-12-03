import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/config/app_theme.dart';
import '../../../auth/logic/auth_controller.dart';
import '../../../health_record/logic/health_record_controller.dart';
import '../../data/models/daily_goal.dart';
import '../../logic/goal_controller.dart';
import '../widgets/goal_progress_card.dart';

class GoalsScreen extends StatelessWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<GoalController, HealthRecordController>(
      builder: (context, goalController, healthController, _) {
        if (goalController.isLoading && goalController.currentGoal == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final todaySummary = healthController.todaySummary;
        final progress = goalController.calculateProgress(
          currentSteps: todaySummary.totalSteps,
          currentCalories: todaySummary.totalCalories,
          currentWater: todaySummary.totalWater,
        );

        return RefreshIndicator(
          onRefresh: () async {
            await goalController.loadGoal();
            await healthController.loadRecords();
          },
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Daily Goals',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              if (goalController.currentGoal == null)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Icon(
                          Icons.flag_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No goals set yet',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Set your daily goals to track your progress',
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () => _showGoalForm(context, goalController),
                          icon: const Icon(Icons.add),
                          label: const Text('Set Goals'),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Column(
                  children: [
                    GoalProgressCard(
                      title: 'Steps',
                      current: todaySummary.totalSteps,
                      goal: goalController.currentGoal!.stepsGoal,
                      progress: progress.stepsProgress,
                      icon: Icons.directions_walk,
                      color: AppTheme.stepsColor,
                      unit: '',
                    ),
                    const SizedBox(height: 12),
                    GoalProgressCard(
                      title: 'Calories',
                      current: todaySummary.totalCalories,
                      goal: goalController.currentGoal!.caloriesGoal,
                      progress: progress.caloriesProgress,
                      icon: Icons.local_fire_department,
                      color: AppTheme.caloriesColor,
                      unit: 'kcal',
                    ),
                    const SizedBox(height: 12),
                    GoalProgressCard(
                      title: 'Water',
                      current: todaySummary.totalWater,
                      goal: goalController.currentGoal!.waterGoal,
                      progress: progress.waterProgress,
                      icon: Icons.water_drop,
                      color: AppTheme.waterColor,
                      unit: 'ml',
                    ),
                    const SizedBox(height: 24),
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.settings),
                        title: const Text('Edit Goals'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => _showGoalForm(context, goalController),
                      ),
                    ),
                    if (goalController.currentGoal!.reminderEnabled)
                      Card(
                        child: ListTile(
                          leading: const Icon(Icons.notifications),
                          title: const Text('Reminders'),
                          subtitle: goalController.currentGoal!.reminderTime != null
                              ? Text('Daily at ${goalController.currentGoal!.reminderTime}')
                              : const Text('Enabled'),
                          trailing: Switch(
                            value: goalController.currentGoal!.reminderEnabled,
                            onChanged: (value) async {
                              await goalController.saveGoal(
                                goalController.currentGoal!.copyWith(
                                  reminderEnabled: value,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }

  void _showGoalForm(BuildContext context, GoalController controller) {
    final currentGoal = controller.currentGoal;
    final stepsController = TextEditingController(
      text: currentGoal?.stepsGoal.toString() ?? '10000',
    );
    final caloriesController = TextEditingController(
      text: currentGoal?.caloriesGoal.toString() ?? '2000',
    );
    final waterController = TextEditingController(
      text: currentGoal?.waterGoal.toString() ?? '2500',
    );
    final reminderTimeController = TextEditingController(
      text: currentGoal?.reminderTime ?? '09:00',
    );
    var reminderEnabled = currentGoal?.reminderEnabled ?? true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Set Daily Goals'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: stepsController,
                  decoration: const InputDecoration(
                    labelText: 'Steps Goal',
                    prefixIcon: Icon(Icons.directions_walk),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: caloriesController,
                  decoration: const InputDecoration(
                    labelText: 'Calories Goal (kcal)',
                    prefixIcon: Icon(Icons.local_fire_department),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: waterController,
                  decoration: const InputDecoration(
                    labelText: 'Water Goal (ml)',
                    prefixIcon: Icon(Icons.water_drop),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                CheckboxListTile(
                  title: const Text('Enable Reminders'),
                  value: reminderEnabled,
                  onChanged: (value) => setState(() => reminderEnabled = value ?? true),
                ),
                if (reminderEnabled)
                  TextField(
                    controller: reminderTimeController,
                    decoration: const InputDecoration(
                      labelText: 'Reminder Time (HH:mm)',
                      prefixIcon: Icon(Icons.access_time),
                      hintText: '09:00',
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final authController = context.read<AuthController>();
                if (authController.currentUser == null) return;
                
                final goal = DailyGoal(
                  id: currentGoal?.id,
                  userName: authController.currentUser!.fullName,
                  stepsGoal: int.tryParse(stepsController.text) ?? 10000,
                  caloriesGoal: int.tryParse(caloriesController.text) ?? 2000,
                  waterGoal: int.tryParse(waterController.text) ?? 2500,
                  reminderEnabled: reminderEnabled,
                  reminderTime: reminderEnabled ? reminderTimeController.text : null,
                );
                await controller.saveGoal(goal);
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}

