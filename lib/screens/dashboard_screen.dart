import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../l10n/app_strings.dart';
import '../services/storage_service.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cars = StorageService.instance.getCars();

    int upcoming = 0;
    int overdue = 0;
    double totalFuelCost = 0;

    for (final car in cars) {
      final maintenance = StorageService.instance.getMaintenanceByCar(car.id);
      if (maintenance.isNotEmpty) {
        final delta = car.mileage - maintenance.first.mileage;
        if (delta >= 10000) {
          overdue++;
        } else if (delta >= 8000) {
          upcoming++;
        }
      }
      totalFuelCost += StorageService.instance.getTotalFuelCost(car.id);
    }

    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.t('dashboard_tab'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _Metric(title: AppStrings.t('dashboard_upcoming'), value: upcoming.toString(), color: Colors.amber),
          _Metric(title: AppStrings.t('dashboard_overdue'), value: overdue.toString(), color: Colors.red),
          _Metric(title: AppStrings.t('total_fuel_cost'), value: '${totalFuelCost.toStringAsFixed(0)} ₽', color: Colors.indigo),
          const SizedBox(height: 12),
          Card(
            child: SizedBox(
              height: 220,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: BarChart(
                  BarChartData(
                    titlesData: const FlTitlesData(show: false),
                    gridData: const FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                    barGroups: [
                      BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: upcoming.toDouble(), color: Colors.amber)]),
                      BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: overdue.toDouble(), color: Colors.red)]),
                      BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: totalFuelCost == 0 ? 0 : 1, color: Colors.indigo)]),
                    ],
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.title, required this.value, required this.color});

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
