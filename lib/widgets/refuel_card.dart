import 'package:flutter/material.dart';

import '../l10n/app_strings.dart';
import '../models/refuel_record.dart';

class RefuelCard extends StatelessWidget {
  const RefuelCard({super.key, required this.record, this.consumption});

  final RefuelRecord record;
  final double? consumption;

  @override
  Widget build(BuildContext context) {
    final date = '${record.date.day.toString().padLeft(2, '0')}.${record.date.month.toString().padLeft(2, '0')}.${record.date.year}';
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${_fuelText(record.fuelType)} • ${record.totalCost.toStringAsFixed(0)} ₽', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            Text('${AppStrings.t('date')}: $date • ${AppStrings.t('mileage')}: ${record.mileage} км'),
            Text('${AppStrings.t('price_per_liter')}: ${record.pricePerLiter.toStringAsFixed(2)} ₽ • ${AppStrings.t('liters')}: ${record.liters.toStringAsFixed(2)}'),
            if (consumption != null) Text('Расход: ${consumption!.toStringAsFixed(2)} л/100 км'),
          ],
        ),
      ),
    );
  }

  String _fuelText(FuelType type) {
    switch (type) {
      case FuelType.petrol:
        return AppStrings.t('petrol');
      case FuelType.diesel:
        return AppStrings.t('diesel');
      case FuelType.gas:
        return AppStrings.t('gas');
    }
  }
}
