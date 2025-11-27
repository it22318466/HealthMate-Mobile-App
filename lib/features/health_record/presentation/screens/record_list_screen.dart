import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../data/models/health_record.dart';
import '../../logic/health_record_controller.dart';
import '../widgets/record_card.dart';
import 'record_form_screen.dart';

class RecordListScreen extends StatelessWidget {
  const RecordListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<HealthRecordController>(
      builder: (context, controller, _) {
        if (controller.isLoading && controller.allRecords.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        final records = controller.displayedRecords;

        return RefreshIndicator(
          onRefresh: controller.loadRecords,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Column(
                    children: [
                      TextField(
                        decoration: const InputDecoration(
                          hintText: 'Search by user or notes',
                          prefixIcon: Icon(Icons.search),
                        ),
                        onChanged: controller.setSearchQuery,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: FilledButton.tonalIcon(
                              onPressed: () async {
                                final range = await showDateRangePicker(
                                  context: context,
                                  firstDate: DateTime(DateTime.now().year - 2),
                                  lastDate: DateTime.now().add(
                                    const Duration(days: 365),
                                  ),
                                  initialDateRange: controller.filterRange,
                                );
                                if (range != null) {
                                  controller.setDateRange(range);
                                }
                              },
                              icon: const Icon(Icons.filter_alt),
                              label: Text(
                                controller.filterRange == null
                                    ? 'Filter by date'
                                    : '${DateFormat.MMMd().format(controller.filterRange!.start)} → ${DateFormat.MMMd().format(controller.filterRange!.end)}',
                              ),
                            ),
                          ),
                          if (controller.filterRange != null ||
                              controller.searchQuery.isNotEmpty) ...[
                            const SizedBox(width: 8),
                            IconButton(
                              onPressed: controller.clearFilters,
                              icon: const Icon(Icons.clear),
                              tooltip: 'Clear filters',
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final record = records[index];
                    return RecordCard(
                      record: record,
                      onEdit: () => _openForm(context, record),
                      onDelete: () => _confirmDelete(context, record),
                    );
                  }, childCount: records.length),
                ),
              ),
              if (records.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Text(
                      'No records found. Add a new entry to get started.',
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void _openForm(BuildContext context, HealthRecord record) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RecordFormScreen(existingRecord: record),
      ),
    );
  }

  void _confirmDelete(BuildContext context, HealthRecord record) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete record'),
          content: const Text('Are you sure you want to delete this record?'),
          actions: [
            TextButton(
              onPressed: Navigator.of(context).pop,
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                context.read<HealthRecordController>().deleteRecord(record.id!);
                Navigator.of(context).pop();
              },
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
