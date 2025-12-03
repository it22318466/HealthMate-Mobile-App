import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/config/app_theme.dart';
import '../../../health_record/data/models/health_record.dart';
import '../../../health_record/logic/health_record_controller.dart';
import '../widgets/insight_stat_card.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<HealthRecordController>(
      builder: (context, controller, _) {
        if (controller.isLoading && controller.allRecords.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        final records = controller.allRecords;
        if (records.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.insights_outlined, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No data available',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Add health records to see insights',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
              ],
            ),
          );
        }

        final insights = _calculateInsights(records);
        final weeklyData = _getWeeklyData(records);
        final monthlyData = _getMonthlyData(records);

        return RefreshIndicator(
          onRefresh: controller.loadRecords,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Health Insights',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              InsightStatCard(
                title: 'Average Daily Steps',
                value: insights.avgSteps.toString(),
                subtitle: 'Last ${records.length} records',
                icon: Icons.directions_walk,
                color: AppTheme.stepsColor,
                trend: insights.stepsTrend,
              ),
              const SizedBox(height: 12),
              InsightStatCard(
                title: 'Average Daily Calories',
                value: insights.avgCalories.toString(),
                subtitle: 'Last ${records.length} records',
                icon: Icons.local_fire_department,
                color: AppTheme.caloriesColor,
                trend: insights.caloriesTrend,
              ),
              const SizedBox(height: 12),
              InsightStatCard(
                title: 'Average Daily Water',
                value: '${insights.avgWater} ml',
                subtitle: 'Last ${records.length} records',
                icon: Icons.water_drop,
                color: AppTheme.waterColor,
                trend: insights.waterTrend,
              ),
              const SizedBox(height: 12),
              InsightStatCard(
                title: 'Average Mood',
                value: insights.avgMood.toStringAsFixed(1),
                subtitle: 'Out of 5.0',
                icon: Icons.mood,
                color: Colors.amber,
                trend: insights.moodTrend,
              ),
              const SizedBox(height: 24),
              _WeeklyChart(data: weeklyData),
              const SizedBox(height: 24),
              _MonthlyChart(data: monthlyData),
              const SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Key Insights',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      ...insights.keyInsights.map(
                        (insight) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.lightbulb_outline,
                                size: 20,
                                color: Colors.amber[700],
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  insight,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ),
                            ],
                          ),
                        ),
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

  HealthInsights _calculateInsights(List<HealthRecord> records) {
    if (records.isEmpty) {
      return HealthInsights(
        avgSteps: 0,
        avgCalories: 0,
        avgWater: 0,
        avgMood: 0.0,
        stepsTrend: 0.0,
        caloriesTrend: 0.0,
        waterTrend: 0.0,
        moodTrend: 0.0,
        keyInsights: [],
      );
    }

    final sorted = [...records]..sort((a, b) => a.date.compareTo(b.date));
    final total = sorted.length;
    final half = (total / 2).ceil();

    final firstHalf = sorted.take(half).toList();
    final secondHalf = sorted.skip(half).toList();

    final avgSteps = (sorted.fold<int>(0, (sum, r) => sum + r.steps) / total).round();
    final avgCalories = (sorted.fold<int>(0, (sum, r) => sum + r.calories) / total).round();
    final avgWater = (sorted.fold<int>(0, (sum, r) => sum + r.water) / total).round();
    final avgMood = sorted.fold<double>(0, (sum, r) => sum + r.mood) / total;

    final firstHalfAvgSteps = firstHalf.isEmpty
        ? 0
        : (firstHalf.fold<int>(0, (sum, r) => sum + r.steps) / firstHalf.length).round();
    final secondHalfAvgSteps = secondHalf.isEmpty
        ? 0
        : (secondHalf.fold<int>(0, (sum, r) => sum + r.steps) / secondHalf.length).round();

    final stepsTrend = firstHalfAvgSteps == 0
        ? 0.0
        : ((secondHalfAvgSteps - firstHalfAvgSteps) / firstHalfAvgSteps * 100).toDouble();

    final firstHalfAvgCalories = firstHalf.isEmpty
        ? 0
        : (firstHalf.fold<int>(0, (sum, r) => sum + r.calories) / firstHalf.length).round();
    final secondHalfAvgCalories = secondHalf.isEmpty
        ? 0
        : (secondHalf.fold<int>(0, (sum, r) => sum + r.calories) / secondHalf.length).round();

    final caloriesTrend = firstHalfAvgCalories == 0
        ? 0.0
        : ((secondHalfAvgCalories - firstHalfAvgCalories) / firstHalfAvgCalories * 100).toDouble();

    final firstHalfAvgWater = firstHalf.isEmpty
        ? 0
        : (firstHalf.fold<int>(0, (sum, r) => sum + r.water) / firstHalf.length).round();
    final secondHalfAvgWater = secondHalf.isEmpty
        ? 0
        : (secondHalf.fold<int>(0, (sum, r) => sum + r.water) / secondHalf.length).round();

    final waterTrend = firstHalfAvgWater == 0
        ? 0.0
        : ((secondHalfAvgWater - firstHalfAvgWater) / firstHalfAvgWater * 100).toDouble();

    final firstHalfAvgMood = firstHalf.isEmpty
        ? 0.0
        : firstHalf.fold<double>(0, (sum, r) => sum + r.mood) / firstHalf.length;
    final secondHalfAvgMood = secondHalf.isEmpty
        ? 0.0
        : secondHalf.fold<double>(0, (sum, r) => sum + r.mood) / secondHalf.length;

    final moodTrend = firstHalfAvgMood == 0
        ? 0.0
        : ((secondHalfAvgMood - firstHalfAvgMood) / firstHalfAvgMood * 100).toDouble();

    final insights = <String>[];
    if (stepsTrend > 5) {
      insights.add('Great progress! Your step count is increasing.');
    } else if (stepsTrend < -5) {
      insights.add('Try to increase your daily steps for better health.');
    }
    if (avgMood >= 4) {
      insights.add('You\'re maintaining a positive mood!');
    } else if (avgMood <= 2) {
      insights.add('Consider activities that boost your mood.');
    }
    if (avgWater >= 2000) {
      insights.add('Excellent hydration habits!');
    } else {
      insights.add('Try to drink more water throughout the day.');
    }

    return HealthInsights(
      avgSteps: avgSteps,
      avgCalories: avgCalories,
      avgWater: avgWater,
      avgMood: avgMood,
      stepsTrend: stepsTrend,
      caloriesTrend: caloriesTrend,
      waterTrend: waterTrend,
      moodTrend: moodTrend,
      keyInsights: insights,
    );
  }

  List<WeeklyDataPoint> _getWeeklyData(List<HealthRecord> records) {
    final sorted = [...records]..sort((a, b) => a.date.compareTo(b.date));
    final last7 = sorted.length > 7 ? sorted.sublist(sorted.length - 7) : sorted;
    return last7
        .map((r) => WeeklyDataPoint(
              date: r.date,
              steps: r.steps,
              calories: r.calories,
              water: r.water,
            ))
        .toList();
  }

  Map<String, MonthlyDataPoint> _getMonthlyData(List<HealthRecord> records) {
    final Map<String, MonthlyDataPoint> monthly = {};
    for (final record in records) {
      final key = '${record.date.year}-${record.date.month.toString().padLeft(2, '0')}';
      if (monthly.containsKey(key)) {
        final existing = monthly[key]!;
        monthly[key] = MonthlyDataPoint(
          month: key,
          totalSteps: existing.totalSteps + record.steps,
          totalCalories: existing.totalCalories + record.calories,
          totalWater: existing.totalWater + record.water,
          count: existing.count + 1,
        );
      } else {
        monthly[key] = MonthlyDataPoint(
          month: key,
          totalSteps: record.steps,
          totalCalories: record.calories,
          totalWater: record.water,
          count: 1,
        );
      }
    }
    return monthly;
  }
}

class HealthInsights {
  HealthInsights({
    required this.avgSteps,
    required this.avgCalories,
    required this.avgWater,
    required this.avgMood,
    required this.stepsTrend,
    required this.caloriesTrend,
    required this.waterTrend,
    required this.moodTrend,
    required this.keyInsights,
  });

  final int avgSteps;
  final int avgCalories;
  final int avgWater;
  final double avgMood;
  final double stepsTrend;
  final double caloriesTrend;
  final double waterTrend;
  final double moodTrend;
  final List<String> keyInsights;
}

class WeeklyDataPoint {
  WeeklyDataPoint({
    required this.date,
    required this.steps,
    required this.calories,
    required this.water,
  });

  final DateTime date;
  final int steps;
  final int calories;
  final int water;
}

class MonthlyDataPoint {
  MonthlyDataPoint({
    required this.month,
    required this.totalSteps,
    required this.totalCalories,
    required this.totalWater,
    required this.count,
  });

  final String month;
  final int totalSteps;
  final int totalCalories;
  final int totalWater;
  final int count;
}

class _WeeklyChart extends StatelessWidget {
  const _WeeklyChart({required this.data});

  final List<WeeklyDataPoint> data;

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const SizedBox.shrink();
    }

    final stepsSpots = data
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.steps / 1000))
        .toList();

    return Card(
      child: SizedBox(
        height: 220,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Weekly Steps Trend',
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
                            if (index >= data.length) return const SizedBox();
                            final date = data[index].date;
                            return Text(
                              '${date.month}/${date.day}',
                              style: const TextStyle(fontSize: 11),
                            );
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          getTitlesWidget: (value, _) {
                            return Text(
                              '${value.toInt()}k',
                              style: const TextStyle(fontSize: 11),
                            );
                          },
                        ),
                      ),
                    ),
                    lineBarsData: [
                      LineChartBarData(
                        spots: stepsSpots,
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

class _MonthlyChart extends StatelessWidget {
  const _MonthlyChart({required this.data});

  final Map<String, MonthlyDataPoint> data;

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const SizedBox.shrink();
    }

    final sortedMonths = data.keys.toList()..sort();
    final last3Months = sortedMonths.length > 3
        ? sortedMonths.sublist(sortedMonths.length - 3)
        : sortedMonths;

    final bars = last3Months.map((month) {
      final point = data[month]!;
      return BarChartGroupData(
        x: last3Months.indexOf(month),
        barRods: [
          BarChartRodData(
            toY: (point.totalSteps / point.count / 1000),
            color: AppTheme.stepsColor,
            width: 20,
          ),
        ],
      );
    }).toList();

    return Card(
      child: SizedBox(
        height: 220,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Monthly Average Steps',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              Expanded(
                child: BarChart(
                  BarChartData(
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
                            if (index >= last3Months.length) return const SizedBox();
                            final month = last3Months[index];
                            return Text(
                              month.split('-')[1],
                              style: const TextStyle(fontSize: 11),
                            );
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          getTitlesWidget: (value, _) {
                            return Text(
                              '${value.toInt()}k',
                              style: const TextStyle(fontSize: 11),
                            );
                          },
                        ),
                      ),
                    ),
                    barGroups: bars,
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

