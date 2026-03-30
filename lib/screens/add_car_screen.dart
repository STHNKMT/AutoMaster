import 'package:flutter/material.dart';

import '../l10n/app_strings.dart';
import '../models/car.dart';
import '../services/storage_service.dart';

class AddCarScreen extends StatefulWidget {
  const AddCarScreen({super.key, this.initialCar});

  final Car? initialCar;

  @override
  State<AddCarScreen> createState() => _AddCarScreenState();
}

class _AddCarScreenState extends State<AddCarScreen> {
  final _formKey = GlobalKey<FormState>();
  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  final _yearController = TextEditingController();
  final _mileageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final car = widget.initialCar;
    if (car != null) {
      _brandController.text = car.brand;
      _modelController.text = car.model;
      _yearController.text = car.year.toString();
      _mileageController.text = car.mileage.toString();
    }
  }

  @override
  void dispose() {
    _brandController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _mileageController.dispose();
    super.dispose();
  }

  Future<void> _saveCar() async {
    if (!_formKey.currentState!.validate()) return;
    final now = DateTime.now();

    final car = Car(
      id: widget.initialCar?.id ?? now.microsecondsSinceEpoch.toString(),
      brand: _brandController.text.trim(),
      model: _modelController.text.trim(),
      year: int.parse(_yearController.text.trim()),
      mileage: int.parse(_mileageController.text.trim()),
      createdAt: widget.initialCar?.createdAt ?? now,
      updatedAt: now,
    );

    await StorageService.instance.saveCar(car);
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.initialCar != null;
    return Scaffold(
      appBar: AppBar(title: Text(editing ? AppStrings.t('edit_car') : AppStrings.t('add_car'))),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _brandController,
              decoration: InputDecoration(labelText: AppStrings.t('brand')),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Укажите марку' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _modelController,
              decoration: InputDecoration(labelText: AppStrings.t('model')),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Укажите модель' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _yearController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: AppStrings.t('year')),
              validator: (v) {
                final year = int.tryParse(v ?? '');
                if (year == null || year < 1950 || year > DateTime.now().year + 1) {
                  return 'Некорректный год';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _mileageController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: '${AppStrings.t('mileage')} (км)'),
              validator: (v) {
                final mileage = int.tryParse(v ?? '');
                if (mileage == null || mileage < 0) return 'Некорректный пробег';
                return null;
              },
            ),
            const SizedBox(height: 20),
            FilledButton(onPressed: _saveCar, child: Text(AppStrings.t('save'))),
          ],
        ),
      ),
    );
  }
}
