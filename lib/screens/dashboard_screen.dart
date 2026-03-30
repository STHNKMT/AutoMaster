import 'package:flutter/material.dart';

import '../l10n/app_strings.dart';
import '../models/service.dart';
import '../services/storage_service.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cars = StorageService.instance.getCars();
    final services = StorageService.instance.getAllServices();

    int upcoming = 0;
    int overdue = 0;

    for (final s in services) {
      final matching = cars.where((c) => c.id == s.carId);
      if (matching.isEmpty) continue;
      final car = matching.first;
      final status = s.statusForMileage(car.mileage);
      if (status == ServiceStatus.soon) upcoming++;
      if (status == ServiceStatus.overdue) overdue++;
    }

    final totalCost = StorageService.instance.getTotalCost();
    final total = (upcoming + overdue).toDouble();
    final progress = total == 0 ? 0.0 : upcoming / total;

    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.t('dashboard_tab'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _MetricCard(title: AppStrings.t('dashboard_upcoming'), value: upcoming.toString(), color: Colors.amber),
          _MetricCard(title: AppStrings.t('dashboard_overdue'), value: overdue.toString(), color: Colors.red),
          _MetricCard(
            title: AppStrings.t('dashboard_total_cost'),
            value: '${totalCost.toStringAsFixed(0)} ${AppStrings.t('rub')}',
            color: Colors.indigo,
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Соотношение ближайших и просроченных ТО', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(value: progress, minHeight: 10, borderRadius: BorderRadius.circular(99)),
                  const SizedBox(height: 8),
                  Text('Ближайшие: ${upcoming.toString()} • Просроченные: ${overdue.toString()}'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.title, required this.value, required this.color});

  final String title;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(backgroundColor: color.withOpacity(0.15), child: Icon(Icons.analytics_outlined, color: color)),
        title: Text(title),
        trailing: Text(value, style: Theme.of(context).textTheme.titleMedium),
      ),
    );
  }
}
