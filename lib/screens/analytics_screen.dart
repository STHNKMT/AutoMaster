import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../l10n/app_strings.dart';
import '../models/car.dart';
import '../services/storage_service.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key, required this.car});

  final Car car;

  @override
  Widget build(BuildContext context) {
    final refuels = StorageService.instance.getRefuelsByCar(car.id);
    final totalCost = StorageService.instance.getTotalFuelCost(car.id);
    final avgConsumption = StorageService.instance.getAverageConsumption(car.id);
    final sinceMaintenance = StorageService.instance.getMileageSinceLastMaintenance(car.id, car.mileage);

    final spots = <FlSpot>[];
    final sorted = [...refuels]..sort((a, b) => a.mileage.compareTo(b.mileage));
    for (var i = 1; i < sorted.length; i++) {
      final prev = sorted[i - 1];
      final cur = sorted[i];
      final dist = (cur.mileage - prev.mileage).toDouble();
      if (dist <= 0) continue;
      final cons = (cur.liters / dist) * 100;
      spots.add(FlSpot(i.toDouble(), cons));
    }

    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.t('analytics'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _Metric(title: AppStrings.t('total_fuel_cost'), value: '${totalCost.toStringAsFixed(0)} ₽'),
          _Metric(title: AppStrings.t('average_consumption'), value: avgConsumption.toStringAsFixed(2)),
          _Metric(title: AppStrings.t('mileage_since_maintenance'), value: '$sinceMaintenance км'),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: SizedBox(
                height: 220,
                child: spots.isEmpty
                    ? const Center(child: Text('Недостаточно данных для графика'))
                    : LineChart(
                        LineChartData(
                          minY: 0,
                          titlesData: const FlTitlesData(show: false),
                          gridData: const FlGridData(show: true),
                          borderData: FlBorderData(show: false),
                          lineBarsData: [
                            LineChartBarData(spots: spots, isCurved: true, dotData: const FlDotData(show: true)),
                          ],
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(title),
        trailing: Text(value, style: Theme.of(context).textTheme.titleMedium),
      ),
    );
  }
}
