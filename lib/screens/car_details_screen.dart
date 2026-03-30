import 'package:flutter/material.dart';

import '../l10n/app_strings.dart';
import '../models/car.dart';
import '../models/service.dart';
import '../services/notification_service.dart';
import '../services/storage_service.dart';
import '../widgets/service_card.dart';
import 'add_service_screen.dart';

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

  List<ServiceRecord> get _services => StorageService.instance.getServicesByCar(_car.id);

  ServiceStatus get _globalStatus {
    if (_services.isEmpty) return ServiceStatus.noData;

    ServiceStatus worst = ServiceStatus.ok;
    for (final service in _services) {
      final status = service.statusForMileage(_car.mileage);
      if (status == ServiceStatus.overdue) return ServiceStatus.overdue;
      if (status == ServiceStatus.soon) worst = ServiceStatus.soon;
      if (status == ServiceStatus.noData && worst == ServiceStatus.ok) {
        worst = ServiceStatus.noData;
      }
    }
    return worst;
  }

  Future<void> _goAddService() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddServiceScreen(car: _car)),
    );

    final updatedCars = StorageService.instance.getCars();
    _car = updatedCars.firstWhere((c) => c.id == _car.id, orElse: () => _car);

    for (final item in _services.take(3)) {
      if (item.statusForMileage(_car.mileage) == ServiceStatus.soon) {
        await NotificationService.instance.showSoonServiceNotification(
          id: item.id.hashCode,
          title: '${_car.displayName}: скоро ТО',
          body: 'Проверьте: ${_typeText(item.type)}',
        );
      }
    }

    if (mounted) setState(() {});
  }

  String _statusText(ServiceStatus status) {
    switch (status) {
      case ServiceStatus.ok:
        return AppStrings.t('status_ok');
      case ServiceStatus.soon:
        return AppStrings.t('status_soon');
      case ServiceStatus.overdue:
        return AppStrings.t('status_overdue');
      case ServiceStatus.noData:
        return AppStrings.t('status_no_data');
    }
  }

  Color _statusColor(ServiceStatus status) {
    switch (status) {
      case ServiceStatus.ok:
        return Colors.green;
      case ServiceStatus.soon:
        return Colors.amber;
      case ServiceStatus.overdue:
        return Colors.red;
      case ServiceStatus.noData:
        return Colors.blueGrey;
    }
  }

  String _typeText(ServiceType type) {
    switch (type) {
      case ServiceType.oilChange:
        return AppStrings.t('oil_change');
      case ServiceType.filters:
        return AppStrings.t('filters');
      case ServiceType.brakes:
        return AppStrings.t('brakes');
      case ServiceType.other:
        return AppStrings.t('other');
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = _globalStatus;
    final color = _statusColor(status);

    return Scaffold(
      appBar: AppBar(title: Text(_car.displayName)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _goAddService,
        icon: const Icon(Icons.add),
        label: Text(AppStrings.t('add_service')),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppStrings.t('car_details'), style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text('${AppStrings.t('brand')}: ${_car.brand}'),
                  Text('${AppStrings.t('model')}: ${_car.model}'),
                  Text('${AppStrings.t('year')}: ${_car.year}'),
                  Text('${AppStrings.t('mileage')}: ${_car.mileage} км'),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(_statusText(status), style: TextStyle(color: color, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(AppStrings.t('service_history'), style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          if (_services.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 24),
              child: Center(child: Text(AppStrings.t('no_services'))),
            )
          else
            ..._services.map((s) => ServiceCard(record: s, currentMileage: _car.mileage)),
        ],
      ),
    );
  }
}
