import 'package:flutter/material.dart';

import '../l10n/app_strings.dart';
import '../models/car.dart';
import '../models/refuel_record.dart';
import '../services/storage_service.dart';
import '../widgets/refuel_card.dart';

class RefuelScreen extends StatefulWidget {
  const RefuelScreen({super.key, required this.car});

  final Car car;

  @override
  State<RefuelScreen> createState() => _RefuelScreenState();
}

class _RefuelScreenState extends State<RefuelScreen> {
  Future<void> _addRefuel() async {
    FuelType fuelType = FuelType.petrol;
    final priceController = TextEditingController();
    final litersController = TextEditingController();
    final mileageController = TextEditingController(text: widget.car.mileage.toString());
    DateTime date = DateTime.now();

    final saved = await showDialog<bool>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: Text(AppStrings.t('add_refuel')),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<FuelType>(
                  value: fuelType,
                  items: [
                    DropdownMenuItem(value: FuelType.petrol, child: Text(AppStrings.t('petrol'))),
                    DropdownMenuItem(value: FuelType.diesel, child: Text(AppStrings.t('diesel'))),
                    DropdownMenuItem(value: FuelType.gas, child: Text(AppStrings.t('gas'))),
                  ],
                  onChanged: (v) => setStateDialog(() => fuelType = v ?? FuelType.petrol),
                  decoration: InputDecoration(labelText: AppStrings.t('fuel_type')),
                ),
                TextField(controller: priceController, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: InputDecoration(labelText: '${AppStrings.t('price_per_liter')} (₽)')),
                TextField(controller: litersController, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: InputDecoration(labelText: AppStrings.t('liters'))),
                TextField(controller: mileageController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: '${AppStrings.t('mileage')} (км)')),
                const SizedBox(height: 8),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('${AppStrings.t('date')}: ${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}'),
                  trailing: IconButton(
                    onPressed: () async {
                      final picked = await showDatePicker(context: context, initialDate: date, firstDate: DateTime(2000), lastDate: DateTime(2100));
                      if (picked != null) setStateDialog(() => date = picked);
                    },
                    icon: const Icon(Icons.calendar_month_outlined),
                  ),
                )
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: Text(AppStrings.t('cancel'))),
            FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(AppStrings.t('save'))),
          ],
        ),
      ),
    );

    if (saved == true) {
      final price = double.tryParse(priceController.text.trim());
      final liters = double.tryParse(litersController.text.trim());
      final mileage = int.tryParse(mileageController.text.trim());

      if (price != null && liters != null && mileage != null && price > 0 && liters > 0) {
        final record = RefuelRecord(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          carId: widget.car.id,
          fuelType: fuelType,
          pricePerLiter: price,
          liters: liters,
          mileage: mileage,
          date: date,
        );

        await StorageService.instance.saveRefuel(record);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppStrings.t('saved'))));
        setState(() {});
      }
    }

    priceController.dispose();
    litersController.dispose();
    mileageController.dispose();
  }

  double? _consumptionAt(List<RefuelRecord> sortedAsc, int i) {
    if (i == 0) return null;
    final current = sortedAsc[i];
    final prev = sortedAsc[i - 1];
    final dist = (current.mileage - prev.mileage).toDouble();
    if (dist <= 0) return null;
    return (current.liters / dist) * 100;
  }

  @override
  Widget build(BuildContext context) {
    final refuelsDesc = StorageService.instance.getRefuelsByCar(widget.car.id);
    final asc = [...refuelsDesc]..sort((a, b) => a.mileage.compareTo(b.mileage));
    final consumptionById = <String, double?>{};
    for (var i = 0; i < asc.length; i++) {
      consumptionById[asc[i].id] = _consumptionAt(asc, i);
    }

    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.t('refuels'))),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addRefuel,
        icon: const Icon(Icons.add),
        label: Text(AppStrings.t('add_refuel')),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (refuelsDesc.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 40),
              child: Center(child: Text(AppStrings.t('no_refuels'))),
            )
          else
            ...refuelsDesc.map((r) => RefuelCard(record: r, consumption: consumptionById[r.id])),
        ],
      ),
    );
  }
}
