import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:healthmate/features/health_record/data/models/health_record.dart';
import 'package:healthmate/features/health_record/presentation/widgets/record_card.dart';

void main() {
  testWidgets('RecordCard renders health metrics', (widgetTester) async {
    final record = HealthRecord(
      userName: 'Alex',
      date: DateTime(2025, 1, 1),
      steps: 6000,
      calories: 1800,
      water: 2200,
      notes: 'Morning jog',
    );

    await widgetTester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RecordCard(record: record, onEdit: () {}, onDelete: () {}),
        ),
      ),
    );

    expect(find.text('Alex'), findsOneWidget);
    expect(find.textContaining('6000 steps'), findsOneWidget);
    expect(find.textContaining('1800 kcal'), findsOneWidget);
    expect(find.textContaining('2200 ml'), findsOneWidget);
    expect(find.textContaining('Morning jog'), findsOneWidget);
  });
}
