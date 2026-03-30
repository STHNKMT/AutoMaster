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
  final _brand = TextEditingController();
  final _model = TextEditingController();
  final _year = TextEditingController();
  final _mileage = TextEditingController();

  @override
  void initState() {
    super.initState();
    final c = widget.initialCar;
    if (c != null) {
      _brand.text = c.brand;
      _model.text = c.model;
      _year.text = c.year.toString();
      _mileage.text = c.mileage.toString();
    }
  }

  @override
  void dispose() {
    _brand.dispose();
    _model.dispose();
    _year.dispose();
    _mileage.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final now = DateTime.now();

    final car = Car(
      id: widget.initialCar?.id ?? now.microsecondsSinceEpoch.toString(),
      brand: _brand.text.trim(),
      model: _model.text.trim(),
      year: int.parse(_year.text.trim()),
      mileage: int.parse(_mileage.text.trim()),
      photoPath: widget.initialCar?.photoPath,
      createdAt: widget.initialCar?.createdAt ?? now,
      updatedAt: now,
    );

    await StorageService.instance.saveCar(car);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppStrings.t('saved'))));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.initialCar == null ? AppStrings.t('add_car') : AppStrings.t('edit_car'))),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(controller: _brand, decoration: InputDecoration(labelText: AppStrings.t('brand')), validator: _required),
            const SizedBox(height: 12),
            TextFormField(controller: _model, decoration: InputDecoration(labelText: AppStrings.t('model')), validator: _required),
            const SizedBox(height: 12),
            TextFormField(
              controller: _year,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: AppStrings.t('year')),
              validator: (v) {
                final year = int.tryParse(v ?? '');
                if (year == null || year < 1950 || year > DateTime.now().year + 1) return 'Некорректный год';
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _mileage,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: '${AppStrings.t('mileage')} (км)'),
              validator: (v) {
                final value = int.tryParse(v ?? '');
                if (value == null || value < 0) return 'Некорректный пробег';
                return null;
              },
            ),
            const SizedBox(height: 20),
            FilledButton(onPressed: _save, child: Text(AppStrings.t('save'))),
          ],
        ),
      ),
    );
  }

  String? _required(String? value) => (value == null || value.trim().isEmpty) ? 'Заполните поле' : null;
}
