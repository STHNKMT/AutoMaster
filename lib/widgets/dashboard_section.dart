import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class DashboardSection extends StatelessWidget {
  const DashboardSection({
    super.key,
    required this.upcoming,
    required this.overdue,
    required this.totalCost,
  });

  final int upcoming;
  final int overdue;
  final double totalCost;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Dashboard', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _metric('Upcoming', upcoming.toString()),
                _metric('Overdue', overdue.toString()),
                _metric('Cost', totalCost.toStringAsFixed(2)),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 120,
              child: BarChart(
                BarChartData(
                  titlesData: const FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  gridData: const FlGridData(show: false),
                  barGroups: [
                    BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: upcoming.toDouble())]),
                    BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: overdue.toDouble())]),
                    BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: totalCost == 0 ? 0 : 1)]),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _metric(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        Text(label),
      ],
    );
  }
}
