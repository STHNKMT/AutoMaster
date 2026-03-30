enum FuelType { petrol, diesel, gas }

class RefuelRecord {
  const RefuelRecord({
    required this.id,
    required this.carId,
    required this.fuelType,
    required this.pricePerLiter,
    required this.liters,
    required this.mileage,
    required this.date,
  });

  final String id;
  final String carId;
  final FuelType fuelType;
  final double pricePerLiter;
  final double liters;
  final int mileage;
  final DateTime date;

  double get totalCost => pricePerLiter * liters;

  Map<String, dynamic> toMap() => {
        'id': id,
        'carId': carId,
        'fuelType': fuelType.name,
        'pricePerLiter': pricePerLiter,
        'liters': liters,
        'mileage': mileage,
        'date': date.toIso8601String(),
      };

  factory RefuelRecord.fromMap(Map<dynamic, dynamic> map) => RefuelRecord(
        id: map['id'] as String,
        carId: map['carId'] as String,
        fuelType: FuelType.values.firstWhere((e) => e.name == map['fuelType']),
        pricePerLiter: (map['pricePerLiter'] as num).toDouble(),
        liters: (map['liters'] as num).toDouble(),
        mileage: map['mileage'] as int,
        date: DateTime.parse(map['date'] as String),
      );
}
