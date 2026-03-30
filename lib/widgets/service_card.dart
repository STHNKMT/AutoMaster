import 'package:flutter/material.dart';

import '../l10n/app_strings.dart';
import '../models/maintenance_record.dart';

class ServiceCard extends StatelessWidget {
  const ServiceCard({
    super.key,
    required this.record,
    required this.onEdit,
    required this.onDelete,
  });

  final MaintenanceRecord record;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final date = '${record.date.day.toString().padLeft(2, '0')}.${record.date.month.toString().padLeft(2, '0')}.${record.date.year}';
    return Card(
      child: ListTile(
        leading: const Icon(Icons.build_circle_outlined),
        title: Text(record.whatDone),
        subtitle: Text('${AppStrings.t('date')}: $date\n${AppStrings.t('mileage')}: ${record.mileage} км'),
        trailing: PopupMenuButton<String>(
          onSelected: (v) => v == 'edit' ? onEdit() : onDelete(),
          itemBuilder: (_) => [
            PopupMenuItem(value: 'edit', child: Text(AppStrings.t('edit_car'))),
            PopupMenuItem(value: 'delete', child: Text(AppStrings.t('delete'))),
          ],
        ),
      ),
    );
  }
}
