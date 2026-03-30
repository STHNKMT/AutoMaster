enum ServiceType {
  oilChange,
  filters,
  tires,
  brakes,
  custom,
}

extension ServiceTypeX on ServiceType {
  String get key => switch (this) {
        ServiceType.oilChange => 'oil_change',
        ServiceType.filters => 'filters',
        ServiceType.tires => 'tires',
        ServiceType.brakes => 'brakes',
        ServiceType.custom => 'custom',
      };

  static ServiceType fromKey(String key) => switch (key) {
        'oil_change' => ServiceType.oilChange,
        'filters' => ServiceType.filters,
        'tires' => ServiceType.tires,
        'brakes' => ServiceType.brakes,
        _ => ServiceType.custom,
      };
}

class ServiceRecord {
  const ServiceRecord({
    this.id,
    required this.carId,
    required this.type,
    this.customType,
    required this.date,
    required this.mileage,
    required this.notes,
    required this.cost,
  });

  final int? id;
  final int carId;
  final ServiceType type;
  final String? customType;
  final DateTime date;
  final int mileage;
  final String notes;
  final double cost;

  String get typeLabel => type == ServiceType.custom ? (customType ?? 'Custom') : type.key;

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'car_id': carId,
      'type': type.key,
      'custom_type': customType,
      'date': date.toIso8601String(),
      'mileage': mileage,
      'notes': notes,
      'cost': cost,
    };
  }

  factory ServiceRecord.fromMap(Map<String, Object?> map) {
    return ServiceRecord(
      id: map['id'] as int?,
      carId: map['car_id'] as int,
      type: ServiceTypeX.fromKey(map['type'] as String),
      customType: map['custom_type'] as String?,
      date: DateTime.parse(map['date'] as String),
      mileage: map['mileage'] as int,
      notes: map['notes'] as String? ?? '',
      cost: (map['cost'] as num).toDouble(),
    );
  }
}
