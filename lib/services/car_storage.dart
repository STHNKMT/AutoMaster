import 'package:shared_preferences/shared_preferences.dart';

import '../models/car.dart';

class CarStorage {
  static const _carsKey = 'cars_data';

  Future<List<Car>> loadCars() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList(_carsKey) ?? <String>[];
    return saved.map(Car.fromJson).toList();
  }

  Future<void> saveCars(List<Car> cars) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = cars.map((c) => c.toJson()).toList();
    await prefs.setStringList(_carsKey, encoded);
  }
}
