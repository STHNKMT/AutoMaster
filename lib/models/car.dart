import 'dart:convert';

class Car {
  Car({
    required this.id,
    required this.brand,
    required this.model,
    required this.year,
    required this.currentMileage,
    required this.serviceIntervalKm,
    required this.serviceIntervalMonths,
    required this.lastServiceDate,
    required this.lastServiceMileage,
  });

  final String id;
  final String brand;
  final String model;
  final int year;
  final int currentMileage;
  final int? serviceIntervalKm;
  final int? serviceIntervalMonths;
  final DateTime lastServiceDate;
  final int lastServiceMileage;

  DateTime get nextServiceDate {
    if (serviceIntervalMonths == null) {
      return lastServiceDate;
    }
    return DateTime(
      lastServiceDate.year,
      lastServiceDate.month + serviceIntervalMonths!,
      lastServiceDate.day,
    );
  }

  int? get nextServiceMileage {
    if (serviceIntervalKm == null) {
      return null;
    }
    return lastServiceMileage + serviceIntervalKm!;
  }

  Car withUpdatedMileage(int mileage) {
    return copyWith(currentMileage: mileage);
  }

  Car markServiceDone({required DateTime serviceDate, required int serviceMileage}) {
    return copyWith(
      lastServiceDate: serviceDate,
      lastServiceMileage: serviceMileage,
      currentMileage: serviceMileage,
    );
  }

  Car copyWith({
    String? id,
    String? brand,
    String? model,
    int? year,
    int? currentMileage,
    int? serviceIntervalKm,
    bool clearIntervalKm = false,
    int? serviceIntervalMonths,
    bool clearIntervalMonths = false,
    DateTime? lastServiceDate,
    int? lastServiceMileage,
  }) {
    return Car(
      id: id ?? this.id,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      year: year ?? this.year,
      currentMileage: currentMileage ?? this.currentMileage,
      serviceIntervalKm:
          clearIntervalKm ? null : serviceIntervalKm ?? this.serviceIntervalKm,
      serviceIntervalMonths: clearIntervalMonths
          ? null
          : serviceIntervalMonths ?? this.serviceIntervalMonths,
      lastServiceDate: lastServiceDate ?? this.lastServiceDate,
      lastServiceMileage: lastServiceMileage ?? this.lastServiceMileage,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'brand': brand,
      'model': model,
      'year': year,
      'currentMileage': currentMileage,
      'serviceIntervalKm': serviceIntervalKm,
      'serviceIntervalMonths': serviceIntervalMonths,
      'lastServiceDate': lastServiceDate.toIso8601String(),
      'lastServiceMileage': lastServiceMileage,
    };
  }

  factory Car.fromMap(Map<String, dynamic> map) {
    return Car(
      id: map['id'] as String,
      brand: map['brand'] as String,
      model: map['model'] as String,
      year: map['year'] as int,
      currentMileage: map['currentMileage'] as int,
      serviceIntervalKm: map['serviceIntervalKm'] as int?,
      serviceIntervalMonths: map['serviceIntervalMonths'] as int?,
      lastServiceDate: DateTime.parse(map['lastServiceDate'] as String),
      lastServiceMileage: map['lastServiceMileage'] as int,
    );
  }

  String toJson() => jsonEncode(toMap());

  factory Car.fromJson(String source) =>
      Car.fromMap(jsonDecode(source) as Map<String, dynamic>);
}
