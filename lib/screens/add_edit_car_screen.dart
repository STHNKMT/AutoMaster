import 'package:flutter/material.dart';

import '../models/car.dart';
import '../services/local_db_service.dart';

class AddEditCarScreen extends StatefulWidget {
  const AddEditCarScreen({super.key, this.car});

  final Car? car;

  @override
  State<AddEditCarScreen> createState() => _AddEditCarScreenState();
}

class _AddEditCarScreenState extends State<AddEditCarScreen> {
  final _formKey = GlobalKey<FormState>();
  final _brand = TextEditingController();
  final _model = TextEditingController();
  final _year = TextEditingController();
  final _vin = TextEditingController();
  final _mileage = TextEditingController();
  String _fuelType = 'Petrol';

  @override
  void initState() {
    super.initState();
    final c = widget.car;
    if (c != null) {
      _brand.text = c.brand;
      _model.text = c.model;
      _year.text = c.year.toString();
      _vin.text = c.vin ?? '';
      _mileage.text = c.mileage.toString();
      _fuelType = c.fuelType;
    }
  }

  @override
  void dispose() {
    _brand.dispose();
    _model.dispose();
    _year.dispose();
    _vin.dispose();
    _mileage.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final car = Car(
      id: widget.car?.id,
      brand: _brand.text.trim(),
      model: _model.text.trim(),
      year: int.parse(_year.text.trim()),
      vin: _vin.text.trim().isEmpty ? null : _vin.text.trim(),
      mileage: int.parse(_mileage.text.trim()),
      fuelType: _fuelType,
      createdAt: widget.car?.createdAt,
      updatedAt: DateTime.now(),
    );

    await LocalDbService.instance.upsertCar(car);
    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.car != null;
    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Edit car' : 'Add car')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(controller: _brand, decoration: const InputDecoration(labelText: 'Brand'), validator: _required),
            const SizedBox(height: 12),
            TextFormField(controller: _model, decoration: const InputDecoration(labelText: 'Model'), validator: _required),
            const SizedBox(height: 12),
            TextFormField(
              controller: _year,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Year'),
              validator: (v) {
                final parsed = int.tryParse(v ?? '');
                if (parsed == null || parsed < 1950 || parsed > 2100) return 'Invalid year';
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(controller: _vin, decoration: const InputDecoration(labelText: 'VIN (optional)')),
            const SizedBox(height: 12),
            TextFormField(
              controller: _mileage,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Mileage (km)'),
              validator: (v) {
                final parsed = int.tryParse(v ?? '');
                if (parsed == null || parsed < 0) return 'Invalid mileage';
                return null;
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _fuelType,
              items: const ['Petrol', 'Diesel', 'Hybrid', 'Electric', 'LPG']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) => setState(() => _fuelType = v ?? 'Petrol'),
              decoration: const InputDecoration(labelText: 'Fuel type'),
            ),
            const SizedBox(height: 18),
            FilledButton(onPressed: _save, child: const Text('Save')),
          ],
        ),
      ),
    );
  }

  String? _required(String? value) {
    if (value == null || value.trim().isEmpty) return 'Required field';
    return null;
  }
}
