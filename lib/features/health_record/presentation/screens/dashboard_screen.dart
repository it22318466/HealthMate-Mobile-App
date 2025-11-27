import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/config/app_theme.dart';
import '../../data/models/health_record.dart';
import '../../logic/health_record_controller.dart';
import '../widgets/summary_stat_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<HealthRecordController>(
      builder: (context, controller, _) {
        if (controller.isLoading && controller.allRecords.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        final todaySummary = controller.todaySummary;

        return RefreshIndicator(
          onRefresh: controller.loadRecords,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Today\'s snapshot',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              SummaryStatCard(
                title: 'Steps',
                value: '${todaySummary.totalSteps}',
                icon: Icons.directions_walk,
                color: AppTheme.stepsColor,
              ),
              SummaryStatCard(
                title: 'Calories',
                value: '${todaySummary.totalCalories} kcal',
                icon: Icons.local_fire_department,
                color: AppTheme.caloriesColor,
              ),
              SummaryStatCard(
                title: 'Water',
                value: '${todaySummary.totalWater} ml',
                icon: Icons.water_drop,
                color: AppTheme.waterColor,
              ),
              const SizedBox(height: 24),
              _WeeklyTrendChart(records: controller.recentRecords),
              const SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Insights',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        controller.recentRecords.isEmpty
                            ? 'No data yet. Add your first record to unlock insights.'
                            : 'You are averaging ${controller.overallSummary.totalSteps ~/ (controller.allRecords.isEmpty ? 1 : controller.allRecords.length)} steps per entry. '
                                  'Keep walking to reach your goals!',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _WeeklyTrendChart extends StatelessWidget {
  const _WeeklyTrendChart({required this.records});

  final List<HealthRecord> records;

  @override
  Widget build(BuildContext context) {
    if (records.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Log a few days of data to see your weekly progress chart.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      );
    }

    final stepsList = records.reversed.toList();
    final spots = List.generate(
      stepsList.length,
      (index) =>
          FlSpot(index.toDouble(), (stepsList[index].steps / 1000).toDouble()),
    );

    return Card(
      child: SizedBox(
        height: 220,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Steps (last 7 entries)',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              Expanded(
                child: LineChart(
                  LineChartData(
                    gridData: const FlGridData(show: false),
                    borderData: FlBorderData(
                      border: const Border(
                        left: BorderSide(color: Colors.black12),
                        bottom: BorderSide(color: Colors.black12),
                      ),
                    ),
                    titlesData: FlTitlesData(
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 24,
                          getTitlesWidget: (value, _) {
                            final index = value.toInt();
                            if (index >= stepsList.length) {
                              return const SizedBox();
                            }
                            final date = stepsList[index].date;
                            return Text(
                              '${date.month}/${date.day}',
                              style: const TextStyle(fontSize: 11),
                            );
                          },
                        ),
                      ),
                    ),
                    lineBarsData: [
                      LineChartBarData(
                        spots: spots,
                        isCurved: true,
                        barWidth: 3,
                        color: AppTheme.stepsColor,
                        dotData: const FlDotData(show: false),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
