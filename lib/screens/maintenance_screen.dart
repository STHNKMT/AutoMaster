import 'package:flutter/material.dart';

import '../l10n/app_strings.dart';
import '../models/car.dart';
import '../models/maintenance_record.dart';
import '../services/storage_service.dart';
import '../widgets/service_card.dart';

class MaintenanceScreen extends StatefulWidget {
  const MaintenanceScreen({super.key, required this.car});

  final Car car;

  @override
  State<MaintenanceScreen> createState() => _MaintenanceScreenState();
}

class _MaintenanceScreenState extends State<MaintenanceScreen> {
  Future<void> _openEditor([MaintenanceRecord? initial]) async {
    final whatDoneController = TextEditingController(text: initial?.whatDone ?? '');
    final mileageController = TextEditingController(text: (initial?.mileage ?? widget.car.mileage).toString());
    DateTime selectedDate = initial?.date ?? DateTime.now();

    final saved = await showDialog<bool>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: Text(AppStrings.t('add_maintenance')),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: whatDoneController, decoration: InputDecoration(labelText: AppStrings.t('what_done'))),
                TextField(controller: mileageController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: '${AppStrings.t('mileage')} (км)')),
                const SizedBox(height: 8),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('${AppStrings.t('date')}: ${selectedDate.day.toString().padLeft(2, '0')}.${selectedDate.month.toString().padLeft(2, '0')}.${selectedDate.year}'),
                  trailing: IconButton(
                    onPressed: () async {
                      final picked = await showDatePicker(context: context, initialDate: selectedDate, firstDate: DateTime(2000), lastDate: DateTime(2100));
                      if (picked != null) setStateDialog(() => selectedDate = picked);
                    },
                    icon: const Icon(Icons.calendar_month_outlined),
                  ),
                ),
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
      final mileage = int.tryParse(mileageController.text.trim());
      if (mileage != null && whatDoneController.text.trim().isNotEmpty) {
        final record = MaintenanceRecord(
          id: initial?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
          carId: widget.car.id,
          whatDone: whatDoneController.text.trim(),
          date: selectedDate,
          mileage: mileage,
        );
        await StorageService.instance.saveMaintenance(record);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppStrings.t('saved'))));
        setState(() {});
      }
    }

    whatDoneController.dispose();
    mileageController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final list = StorageService.instance.getMaintenanceByCar(widget.car.id);

    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.t('maintenance'))),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openEditor,
        icon: const Icon(Icons.add),
        label: Text(AppStrings.t('add_maintenance')),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (list.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 40),
              child: Center(child: Text(AppStrings.t('no_maintenance'))),
            )
          else
            ...list.map(
              (record) => ServiceCard(
                record: record,
                onEdit: () => _openEditor(record),
                onDelete: () async {
                  await StorageService.instance.deleteMaintenance(record.id);
                  if (!mounted) return;
                  setState(() {});
                },
              ),
            ),
        ],
      ),
    );
  }
}
