import 'package:flutter/material.dart';

import '../l10n/app_strings.dart';
import '../models/car.dart';
import '../models/service.dart';

class CarCard extends StatelessWidget {
  const CarCard({
    super.key,
    required this.car,
    required this.status,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  final Car car;
  final ServiceStatus status;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      ServiceStatus.ok => Colors.green,
      ServiceStatus.soon => Colors.amber,
      ServiceStatus.overdue => Colors.red,
      ServiceStatus.noData => Colors.blueGrey,
    };

    final statusText = switch (status) {
      ServiceStatus.ok => AppStrings.t('status_ok'),
      ServiceStatus.soon => AppStrings.t('status_soon'),
      ServiceStatus.overdue => AppStrings.t('status_overdue'),
      ServiceStatus.noData => AppStrings.t('status_no_data'),
    };

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${car.brand} ${car.model}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (v) => v == 'edit' ? onEdit() : onDelete(),
                    itemBuilder: (_) => [
                      PopupMenuItem(value: 'edit', child: Text(AppStrings.t('edit_car'))),
                      PopupMenuItem(value: 'delete', child: Text(AppStrings.t('delete'))),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text('${AppStrings.t('year')}: ${car.year} • ${AppStrings.t('mileage')}: ${car.mileage} км'),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(statusText, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
