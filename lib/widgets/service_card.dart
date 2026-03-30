import 'package:flutter/material.dart';

import '../l10n/app_strings.dart';
import '../models/service.dart';

class ServiceCard extends StatelessWidget {
  const ServiceCard({super.key, required this.record, required this.currentMileage});

  final ServiceRecord record;
  final int currentMileage;

  IconData _iconForType(ServiceType type) {
    switch (type) {
      case ServiceType.oilChange:
        return Icons.oil_barrel_outlined;
      case ServiceType.filters:
        return Icons.filter_alt_outlined;
      case ServiceType.brakes:
        return Icons.car_repair_outlined;
      case ServiceType.other:
        return Icons.build_outlined;
    }
  }

  String _nameForType(ServiceType type) {
    switch (type) {
      case ServiceType.oilChange:
        return AppStrings.t('oil_change');
      case ServiceType.filters:
        return AppStrings.t('filters');
      case ServiceType.brakes:
        return AppStrings.t('brakes');
      case ServiceType.other:
        return AppStrings.t('other');
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = record.statusForMileage(currentMileage);
    final statusColor = switch (status) {
      ServiceStatus.ok => Colors.green,
      ServiceStatus.soon => Colors.amber,
      ServiceStatus.overdue => Colors.red,
      ServiceStatus.noData => Colors.blueGrey,
    };

    final dateText = '${record.date.day.toString().padLeft(2, '0')}.${record.date.month.toString().padLeft(2, '0')}.${record.date.year}';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(_iconForType(record.type)),
                const SizedBox(width: 10),
                Expanded(child: Text(_nameForType(record.type), style: Theme.of(context).textTheme.titleMedium)),
                Text('${record.cost.toStringAsFixed(0)} ${AppStrings.t('rub')}'),
              ],
            ),
            const SizedBox(height: 8),
            Text('${AppStrings.t('service_date')}: $dateText • ${AppStrings.t('mileage')}: ${record.mileage} км'),
            if (record.notes.trim().isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(record.notes),
            ],
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                switch (status) {
                  ServiceStatus.ok => AppStrings.t('status_ok'),
                  ServiceStatus.soon => AppStrings.t('status_soon'),
                  ServiceStatus.overdue => AppStrings.t('status_overdue'),
                  ServiceStatus.noData => AppStrings.t('status_no_data'),
                },
                style: TextStyle(color: statusColor, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
