import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

import '../models/car.dart';
import '../models/maintenance_record.dart';
import '../models/refuel_record.dart';

class StorageService {
  StorageService._();
  static final StorageService instance = StorageService._();

  static const _carsBoxName = 'cars_box';
  static const _maintenanceBoxName = 'maintenance_box';
  static const _refuelsBoxName = 'refuels_box';

  late Box _carsBox;
  late Box _maintenanceBox;
  late Box _refuelsBox;

  final ValueNotifier<int> revision = ValueNotifier<int>(0);

  Future<void> init() async {
    await Hive.initFlutter();
    _carsBox = await Hive.openBox(_carsBoxName);
    _maintenanceBox = await Hive.openBox(_maintenanceBoxName);
    _refuelsBox = await Hive.openBox(_refuelsBoxName);
  }

  List<Car> getCars() {
    final cars = _carsBox.values
        .map((e) => Car.fromMap(Map<dynamic, dynamic>.from(e as Map)))
        .toList();
    cars.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return cars;
  }

  Future<void> saveCar(Car car) async {
    await _carsBox.put(car.id, car.toMap());
    revision.value++;
  }

  Future<void> updateMileage(String carId, int newMileage) async {
    final raw = _carsBox.get(carId);
    if (raw == null) return;
    final car = Car.fromMap(Map<dynamic, dynamic>.from(raw as Map));
    await saveCar(car.copyWith(mileage: newMileage, updatedAt: DateTime.now()));
  }

  Future<void> updateCarPhoto(String carId, String photoPath) async {
    final raw = _carsBox.get(carId);
    if (raw == null) return;
    final car = Car.fromMap(Map<dynamic, dynamic>.from(raw as Map));
    await saveCar(car.copyWith(photoPath: photoPath, updatedAt: DateTime.now()));
  }

  Future<void> deleteCar(String carId) async {
    await _carsBox.delete(carId);

    final maintenanceKeys = _maintenanceBox.keys.where((key) {
      final raw = Map<dynamic, dynamic>.from(_maintenanceBox.get(key) as Map);
      return raw['carId'] == carId;
    }).toList();
    for (final key in maintenanceKeys) {
      await _maintenanceBox.delete(key);
    }

    final refuelKeys = _refuelsBox.keys.where((key) {
      final raw = Map<dynamic, dynamic>.from(_refuelsBox.get(key) as Map);
      return raw['carId'] == carId;
    }).toList();
    for (final key in refuelKeys) {
      await _refuelsBox.delete(key);
    }

    revision.value++;
  }

  List<MaintenanceRecord> getMaintenanceByCar(String carId) {
    final list = _maintenanceBox.values
        .map((e) => MaintenanceRecord.fromMap(Map<dynamic, dynamic>.from(e as Map)))
        .where((e) => e.carId == carId)
        .toList();
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  Future<void> saveMaintenance(MaintenanceRecord record) async {
    await _maintenanceBox.put(record.id, record.toMap());
    await updateMileage(record.carId, record.mileage);
    revision.value++;
  }

  Future<void> deleteMaintenance(String id) async {
    await _maintenanceBox.delete(id);
    revision.value++;
  }

  List<RefuelRecord> getRefuelsByCar(String carId) {
    final list = _refuelsBox.values
        .map((e) => RefuelRecord.fromMap(Map<dynamic, dynamic>.from(e as Map)))
        .where((e) => e.carId == carId)
        .toList();
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  Future<void> saveRefuel(RefuelRecord record) async {
    await _refuelsBox.put(record.id, record.toMap());
    await updateMileage(record.carId, record.mileage);
    revision.value++;
  }

  Future<void> deleteRefuel(String id) async {
    await _refuelsBox.delete(id);
    revision.value++;
  }

  double getTotalFuelCost(String carId) {
    return getRefuelsByCar(carId).fold<double>(0, (sum, e) => sum + e.totalCost);
  }

  double getAverageConsumption(String carId) {
    final refuels = getRefuelsByCar(carId);
    if (refuels.length < 2) return 0;

    final sorted = [...refuels]..sort((a, b) => a.mileage.compareTo(b.mileage));
    final first = sorted.first;
    final last = sorted.last;
    final distance = (last.mileage - first.mileage).toDouble();
    final liters = sorted.skip(1).fold<double>(0, (sum, e) => sum + e.liters);

    if (distance <= 0 || liters <= 0) return 0;
    return (liters / distance) * 100;
  }

  int getMileageSinceLastMaintenance(String carId, int currentMileage) {
    final list = getMaintenanceByCar(carId);
    if (list.isEmpty) return currentMileage;
    return currentMileage - list.first.mileage;
  }

  Future<String> exportJson() async {
    final data = {
      'cars': getCars().map((e) => e.toMap()).toList(),
      'maintenance': _maintenanceBox.values.map((e) => e as Map).toList(),
      'refuels': _refuelsBox.values.map((e) => e as Map).toList(),
      'exportedAt': DateTime.now().toIso8601String(),
    };

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/automaster_export_${DateTime.now().millisecondsSinceEpoch}.json');
    await file.writeAsString(const JsonEncoder.withIndent('  ').convert(data));
    return file.path;
  }
}
