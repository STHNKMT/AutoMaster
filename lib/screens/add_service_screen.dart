import 'package:flutter/material.dart';

import '../l10n/app_strings.dart';
import '../models/car.dart';
import '../models/service.dart';
import '../services/storage_service.dart';

class AddServiceScreen extends StatefulWidget {
  const AddServiceScreen({super.key, required this.car});

  final Car car;

  @override
  State<AddServiceScreen> createState() => _AddServiceScreenState();
}

class _AddServiceScreenState extends State<AddServiceScreen> {
  final _formKey = GlobalKey<FormState>();
  ServiceType _type = ServiceType.oilChange;
  DateTime _date = DateTime.now();

  final _mileageController = TextEditingController();
  final _costController = TextEditingController();
  final _notesController = TextEditingController();
  final _intervalKmController = TextEditingController();
  final _intervalMonthsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _mileageController.text = widget.car.mileage.toString();
  }

  @override
  void dispose() {
    _mileageController.dispose();
    _costController.dispose();
    _notesController.dispose();
    _intervalKmController.dispose();
    _intervalMonthsController.dispose();
    super.dispose();
  }

  Future<void> _saveService() async {
    if (!_formKey.currentState!.validate()) return;

    final record = ServiceRecord(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      carId: widget.car.id,
      type: _type,
      date: _date,
      mileage: int.parse(_mileageController.text.trim()),
      cost: double.parse(_costController.text.trim()),
      notes: _notesController.text.trim(),
      intervalKm: int.tryParse(_intervalKmController.text.trim()),
      intervalMonths: int.tryParse(_intervalMonthsController.text.trim()),
      createdAt: DateTime.now(),
    );

    await StorageService.instance.saveService(record);
    if (!mounted) return;
    Navigator.pop(context);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() => _date = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final typeItems = {
      ServiceType.oilChange: AppStrings.t('oil_change'),
      ServiceType.filters: AppStrings.t('filters'),
      ServiceType.brakes: AppStrings.t('brakes'),
      ServiceType.other: AppStrings.t('other'),
    };

    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.t('add_service'))),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            DropdownButtonFormField<ServiceType>(
              value: _type,
              items: typeItems.entries
                  .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
                  .toList(),
              onChanged: (v) => setState(() => _type = v ?? ServiceType.oilChange),
              decoration: InputDecoration(labelText: AppStrings.t('service_type')),
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('${AppStrings.t('service_date')}: ${_date.day.toString().padLeft(2, '0')}.${_date.month.toString().padLeft(2, '0')}.${_date.year}'),
              trailing: IconButton(onPressed: _pickDate, icon: const Icon(Icons.calendar_month_outlined)),
            ),
            TextFormField(
              controller: _mileageController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: '${AppStrings.t('mileage')} (км)'),
              validator: (v) {
                final n = int.tryParse(v ?? '');
                if (n == null || n < 0) return 'Укажите корректный пробег';
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _costController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(labelText: '${AppStrings.t('service_cost')} (${AppStrings.t('rub')})'),
              validator: (v) {
                final n = double.tryParse(v ?? '');
                if (n == null || n < 0) return 'Укажите корректную стоимость';
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _intervalKmController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: AppStrings.t('interval_km')),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _intervalMonthsController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: AppStrings.t('interval_months')),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _notesController,
              maxLines: 3,
              decoration: InputDecoration(labelText: AppStrings.t('service_notes')),
            ),
            const SizedBox(height: 20),
            FilledButton(onPressed: _saveService, child: Text(AppStrings.t('save'))),
          ],
        ),
      ),
    );
  }
}
