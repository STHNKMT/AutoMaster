import 'package:flutter/material.dart';

import '../models/car.dart';

enum ServiceIntervalType { km, months }

class AddCarPage extends StatefulWidget {
  const AddCarPage({super.key});

  @override
  State<AddCarPage> createState() => _AddCarPageState();
}

class _AddCarPageState extends State<AddCarPage> {
  final _formKey = GlobalKey<FormState>();
  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  final _yearController = TextEditingController();
  final _mileageController = TextEditingController();
  final _intervalController = TextEditingController();

  ServiceIntervalType _intervalType = ServiceIntervalType.km;

  @override
  void dispose() {
    _brandController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _mileageController.dispose();
    _intervalController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final currentMileage = int.parse(_mileageController.text.trim());
    final intervalValue = int.parse(_intervalController.text.trim());
    final now = DateTime.now();

    final car = Car(
      id: now.microsecondsSinceEpoch.toString(),
      brand: _brandController.text.trim(),
      model: _modelController.text.trim(),
      year: int.parse(_yearController.text.trim()),
      currentMileage: currentMileage,
      serviceIntervalKm:
          _intervalType == ServiceIntervalType.km ? intervalValue : null,
      serviceIntervalMonths:
          _intervalType == ServiceIntervalType.months ? intervalValue : null,
      lastServiceDate: now,
      lastServiceMileage: currentMileage,
    );

    Navigator.of(context).pop(car);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Добавить автомобиль')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextFormField(
                controller: _brandController,
                decoration: const InputDecoration(labelText: 'Марка'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Введите марку';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _modelController,
                decoration: const InputDecoration(labelText: 'Модель'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Введите модель';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _yearController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Год выпуска'),
                validator: (value) {
                  final parsed = int.tryParse(value ?? '');
                  if (parsed == null || parsed < 1950 || parsed > 2100) {
                    return 'Укажите корректный год';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _mileageController,
                keyboardType: TextInputType.number,
                decoration:
                    const InputDecoration(labelText: 'Текущий пробег (км)'),
                validator: (value) {
                  final parsed = int.tryParse(value ?? '');
                  if (parsed == null || parsed < 0) {
                    return 'Введите корректный пробег';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              SegmentedButton<ServiceIntervalType>(
                segments: const [
                  ButtonSegment(
                    value: ServiceIntervalType.km,
                    label: Text('Интервал в км'),
                  ),
                  ButtonSegment(
                    value: ServiceIntervalType.months,
                    label: Text('Интервал в мес.'),
                  ),
                ],
                selected: {_intervalType},
                onSelectionChanged: (newSelection) {
                  setState(() {
                    _intervalType = newSelection.first;
                  });
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _intervalController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: _intervalType == ServiceIntervalType.km
                      ? 'Интервал ТО (км)'
                      : 'Интервал ТО (месяц)',
                ),
                validator: (value) {
                  final parsed = int.tryParse(value ?? '');
                  if (parsed == null || parsed <= 0) {
                    return 'Введите интервал';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.save_outlined),
                label: const Text('Сохранить автомобиль'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
