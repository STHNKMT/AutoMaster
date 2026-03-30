import 'dart:io';

import 'package:flutter/material.dart';

import '../l10n/app_strings.dart';
import '../models/car.dart';
import '../services/storage_service.dart';
import 'analytics_screen.dart';
import 'maintenance_screen.dart';
import 'refuel_screen.dart';

class CarDetailsScreen extends StatefulWidget {
  const CarDetailsScreen({super.key, required this.car});

  final Car car;

  @override
  State<CarDetailsScreen> createState() => _CarDetailsScreenState();
}

class _CarDetailsScreenState extends State<CarDetailsScreen> {
  late Car _car;

  @override
  void initState() {
    super.initState();
    _car = widget.car;
  }

  void _refreshCar() {
    final updated = StorageService.instance.getCars();
    _car = updated.firstWhere((e) => e.id == _car.id, orElse: () => _car);
  }

  @override
  Widget build(BuildContext context) {
    _refreshCar();
    final maintenance = StorageService.instance.getMaintenanceByCar(_car.id);

    return Scaffold(
      appBar: AppBar(title: Text(_car.displayName)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_car.photoPath != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.file(File(_car.photoPath!), height: 160, width: double.infinity, fit: BoxFit.cover),
                    ),
                  if (_car.photoPath != null) const SizedBox(height: 10),
                  Text(AppStrings.t('car_details'), style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text('${AppStrings.t('brand')}: ${_car.brand}'),
                  Text('${AppStrings.t('model')}: ${_car.model}'),
                  Text('${AppStrings.t('year')}: ${_car.year}'),
                  Text('${AppStrings.t('mileage')}: ${_car.mileage} км'),
                  const SizedBox(height: 8),
                  Text(
                    maintenance.isEmpty
                        ? 'Статус: нет данных по ТО'
                        : 'Пробег с последнего ТО: ${_car.mileage - maintenance.first.mileage} км',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: () async {
              await Navigator.push(context, MaterialPageRoute(builder: (_) => MaintenanceScreen(car: _car)));
              if (mounted) setState(() {});
            },
            icon: const Icon(Icons.build),
            label: Text(AppStrings.t('maintenance')),
          ),
          const SizedBox(height: 10),
          FilledButton.icon(
            onPressed: () async {
              await Navigator.push(context, MaterialPageRoute(builder: (_) => RefuelScreen(car: _car)));
              if (mounted) setState(() {});
            },
            icon: const Icon(Icons.local_gas_station),
            label: Text(AppStrings.t('refuels')),
          ),
          const SizedBox(height: 10),
          FilledButton.icon(
            onPressed: () async {
              await Navigator.push(context, MaterialPageRoute(builder: (_) => AnalyticsScreen(car: _car)));
              if (mounted) setState(() {});
            },
            icon: const Icon(Icons.query_stats),
            label: Text(AppStrings.t('analytics')),
          ),
        ],
      ),
    );
  }
}
