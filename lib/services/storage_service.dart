import 'dart:convert';
import 'dart:io';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

import '../models/car.dart';
import '../models/service.dart';

class StorageService {
  StorageService._();
  static final StorageService instance = StorageService._();

  static const _carsBoxName = 'cars_box';
  static const _servicesBoxName = 'services_box';

  late Box _carsBox;
  late Box _servicesBox;
  final ValueNotifier<int> revision = ValueNotifier<int>(0);

  Future<void> init() async {
    await Hive.initFlutter();
    _carsBox = await Hive.openBox(_carsBoxName);
    _servicesBox = await Hive.openBox(_servicesBoxName);
  }

  List<Car> getCars() {
    return _carsBox.values
        .map((e) => Car.fromMap(Map<dynamic, dynamic>.from(e as Map)))
        .toList();
  }

  Future<void> saveCar(Car car) async {
    await _carsBox.put(car.id, car.toMap());
    revision.value++;
  }

  Future<void> deleteCar(String carId) async {
    await _carsBox.delete(carId);

    final toDelete = _servicesBox.keys.where((key) {
      final raw = Map<dynamic, dynamic>.from(_servicesBox.get(key) as Map);
      return raw['carId'] == carId;
    }).toList();

    for (final key in toDelete) {
      await _servicesBox.delete(key);
    }

    revision.value++;
  }

  List<ServiceRecord> getServicesByCar(String carId) {
    final records = _servicesBox.values
        .map((e) => ServiceRecord.fromMap(Map<dynamic, dynamic>.from(e as Map)))
        .where((s) => s.carId == carId)
        .toList();

    records.sort((a, b) => b.date.compareTo(a.date));
    return records;
  }

  List<ServiceRecord> getAllServices() {
    final records = _servicesBox.values
        .map((e) => ServiceRecord.fromMap(Map<dynamic, dynamic>.from(e as Map)))
        .toList();
    records.sort((a, b) => b.date.compareTo(a.date));
    return records;
  }

  Future<void> saveService(ServiceRecord record) async {
    await _servicesBox.put(record.id, record.toMap());
    final rawCar = _carsBox.get(record.carId);
    if (rawCar != null) {
      final car = Car.fromMap(Map<dynamic, dynamic>.from(rawCar as Map));
      await saveCar(car.copyWith(mileage: record.mileage, updatedAt: DateTime.now()));
    }
    revision.value++;
  }

  ServiceRecord? getLatestServiceForCar(String carId) {
    final list = getServicesByCar(carId);
    return list.isEmpty ? null : list.first;
  }

  double getTotalCost() {
    return getAllServices().fold<double>(0, (sum, e) => sum + e.cost);
  }

  Future<String> exportJson() async {
    final data = {
      'cars': getCars().map((e) => e.toMap()).toList(),
      'services': getAllServices().map((e) => e.toMap()).toList(),
      'exportedAt': DateTime.now().toIso8601String(),
    };

    final dir = await getApplicationDocumentsDirectory();
    final path = '${dir.path}/automaster_export_${DateTime.now().millisecondsSinceEpoch}.json';
    final file = File(path);
    await file.writeAsString(const JsonEncoder.withIndent('  ').convert(data));
    return path;
  }
}
