import 'package:flutter/material.dart';

import '../l10n/app_strings.dart';
import '../models/car.dart';
import '../models/service.dart';
import '../services/storage_service.dart';
import '../widgets/car_card.dart';
import 'add_car_screen.dart';
import 'car_details_screen.dart';

enum CarsSort { mileage, lastService }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();
  CarsSort _sort = CarsSort.mileage;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  ServiceStatus _statusForCar(Car car) {
    final services = StorageService.instance.getServicesByCar(car.id);
    if (services.isEmpty) return ServiceStatus.noData;
    ServiceStatus worst = ServiceStatus.ok;
    for (final s in services) {
      final status = s.statusForMileage(car.mileage);
      if (status == ServiceStatus.overdue) return ServiceStatus.overdue;
      if (status == ServiceStatus.soon) worst = ServiceStatus.soon;
      if (status == ServiceStatus.noData && worst == ServiceStatus.ok) {
        worst = ServiceStatus.noData;
      }
    }
    return worst;
  }

  DateTime? _lastServiceDate(String carId) {
    final services = StorageService.instance.getServicesByCar(carId);
    return services.isEmpty ? null : services.first.date;
  }

  List<Car> _filteredSortedCars() {
    final query = _searchController.text.trim().toLowerCase();
    final cars = StorageService.instance.getCars().where((c) {
      if (query.isEmpty) return true;
      return c.brand.toLowerCase().contains(query) || c.model.toLowerCase().contains(query);
    }).toList();

    if (_sort == CarsSort.mileage) {
      cars.sort((a, b) => b.mileage.compareTo(a.mileage));
    } else {
      cars.sort((a, b) {
        final ad = _lastServiceDate(a.id) ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bd = _lastServiceDate(b.id) ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bd.compareTo(ad);
      });
    }

    return cars;
  }

  Future<void> _openAddCar([Car? car]) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddCarScreen(initialCar: car)),
    );
    if (mounted) setState(() {});
  }

  Future<void> _deleteCar(Car car) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(AppStrings.t('delete_car_title')),
        content: Text(AppStrings.t('delete_car_message')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(AppStrings.t('cancel'))),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(AppStrings.t('delete'))),
        ],
      ),
    );

    if (confirmed == true) {
      await StorageService.instance.deleteCar(car.id);
      if (mounted) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final cars = _filteredSortedCars();

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.t('cars_tab')),
        actions: [
          PopupMenuButton<CarsSort>(
            initialValue: _sort,
            onSelected: (value) => setState(() => _sort = value),
            itemBuilder: (_) => [
              PopupMenuItem(value: CarsSort.mileage, child: Text(AppStrings.t('sort_mileage'))),
              PopupMenuItem(value: CarsSort.lastService, child: Text(AppStrings.t('sort_last_service'))),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddCar,
        icon: const Icon(Icons.add),
        label: Text(AppStrings.t('add_car')),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _searchController,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: AppStrings.t('search_hint'),
              prefixIcon: const Icon(Icons.search),
            ),
          ),
          const SizedBox(height: 14),
          if (cars.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 40),
              child: Center(child: Text(AppStrings.t('no_cars'))),
            )
          else
            ...cars.map(
              (car) => CarCard(
                car: car,
                status: _statusForCar(car),
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => CarDetailsScreen(car: car)),
                  );
                  if (mounted) setState(() {});
                },
                onEdit: () => _openAddCar(car),
                onDelete: () => _deleteCar(car),
              ),
            ),
        ],
      ),
    );
  }
}
