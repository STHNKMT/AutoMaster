import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/car.dart';
import '../services/car_storage.dart';
import 'add_car_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final CarStorage _storage = CarStorage();
  final DateFormat _dateFormat = DateFormat('dd.MM.yyyy');

  List<Car> _cars = <Car>[];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadCars();
  }

  Future<void> _loadCars() async {
    final cars = await _storage.loadCars();
    if (!mounted) return;
    setState(() {
      _cars = cars;
      _loading = false;
    });
  }

  Future<void> _persistCars() async {
    await _storage.saveCars(_cars);
  }

  Future<void> _openAddCar() async {
    final created = await Navigator.of(context).push<Car>(
      MaterialPageRoute(builder: (_) => const AddCarPage()),
    );

    if (created == null) return;

    setState(() {
      _cars = [..._cars, created];
    });
    await _persistCars();
  }

  Future<void> _markServiceDone(Car car) async {
    final mileageController =
        TextEditingController(text: car.currentMileage.toString());

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Отметить выполненное ТО'),
          content: TextField(
            controller: mileageController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Пробег на момент ТО',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Отмена'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Готово'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      mileageController.dispose();
      return;
    }

    final serviceMileage = int.tryParse(mileageController.text.trim());
    mileageController.dispose();

    if (serviceMileage == null || serviceMileage < 0) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Неверный пробег. ТО не сохранено.')),
      );
      return;
    }

    setState(() {
      _cars = _cars
          .map(
            (c) => c.id == car.id
                ? c.markServiceDone(
                    serviceDate: DateTime.now(),
                    serviceMileage: serviceMileage,
                  )
                : c,
          )
          .toList();
    });
    await _persistCars();
  }

  String _nextServiceLabel(Car car) {
    final datePart = 'дата: ${_dateFormat.format(car.nextServiceDate)}';
    if (car.nextServiceMileage != null) {
      return '$datePart • ${car.nextServiceMileage} км';
    }
    return datePart;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AutoMaster: ТО автомобилей'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddCar,
        icon: const Icon(Icons.add),
        label: const Text('Добавить авто'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _cars.isEmpty
              ? const Center(
                  child: Text(
                    'Нет автомобилей.\nДобавьте первый автомобиль.',
                    textAlign: TextAlign.center,
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: _cars.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final car = _cars[index];
                    return Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: Theme.of(context).colorScheme.outlineVariant,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${car.brand} ${car.model} (${car.year})',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 4),
                            Text('Текущий пробег: ${car.currentMileage} км'),
                            const SizedBox(height: 4),
                            Text('Ближайшее ТО: ${_nextServiceLabel(car)}'),
                            const SizedBox(height: 10),
                            Align(
                              alignment: Alignment.centerRight,
                              child: OutlinedButton.icon(
                                onPressed: () => _markServiceDone(car),
                                icon: const Icon(Icons.build_circle_outlined),
                                label: const Text('ТО выполнено'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
