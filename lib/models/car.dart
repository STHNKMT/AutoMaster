class Car {
  const Car({
    this.id,
    required this.brand,
    required this.model,
    required this.year,
    this.vin,
    required this.mileage,
    required this.fuelType,
    this.createdAt,
    this.updatedAt,
  });

  final int? id;
  final String brand;
  final String model;
  final int year;
  final String? vin;
  final int mileage;
  final String fuelType;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  String get title => '$brand $model ($year)';

  Car copyWith({
    int? id,
    String? brand,
    String? model,
    int? year,
    String? vin,
    bool clearVin = false,
    int? mileage,
    String? fuelType,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Car(
      id: id ?? this.id,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      year: year ?? this.year,
      vin: clearVin ? null : vin ?? this.vin,
      mileage: mileage ?? this.mileage,
      fuelType: fuelType ?? this.fuelType,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'brand': brand,
      'model': model,
      'year': year,
      'vin': vin,
      'mileage': mileage,
      'fuel_type': fuelType,
      'created_at': (createdAt ?? DateTime.now()).toIso8601String(),
      'updated_at': (updatedAt ?? DateTime.now()).toIso8601String(),
    };
  }

  factory Car.fromMap(Map<String, Object?> map) {
    return Car(
      id: map['id'] as int?,
      brand: map['brand'] as String,
      model: map['model'] as String,
      year: map['year'] as int,
      vin: map['vin'] as String?,
      mileage: map['mileage'] as int,
      fuelType: map['fuel_type'] as String,
      createdAt: DateTime.tryParse(map['created_at'] as String? ?? ''),
      updatedAt: DateTime.tryParse(map['updated_at'] as String? ?? ''),
    );
  }
}
