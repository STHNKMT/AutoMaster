import 'service_record.dart';

class ServiceInterval {
  const ServiceInterval({
    this.id,
    required this.carId,
    required this.type,
    this.customType,
    this.intervalKm,
    this.intervalMonths,
  });

  final int? id;
  final int carId;
  final ServiceType type;
  final String? customType;
  final int? intervalKm;
  final int? intervalMonths;

  DateTime? calculateNextDate(DateTime? lastDate) {
    if (lastDate == null || intervalMonths == null) return null;
    return DateTime(lastDate.year, lastDate.month + intervalMonths!, lastDate.day);
  }

  int? calculateNextMileage(int? lastMileage) {
    if (lastMileage == null || intervalKm == null) return null;
    return lastMileage + intervalKm!;
  }

  String get typeKey => type == ServiceType.custom ? (customType ?? 'custom') : type.key;

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'car_id': carId,
      'type': type.key,
      'custom_type': customType,
      'interval_km': intervalKm,
      'interval_months': intervalMonths,
    };
  }

  factory ServiceInterval.fromMap(Map<String, Object?> map) {
    return ServiceInterval(
      id: map['id'] as int?,
      carId: map['car_id'] as int,
      type: ServiceTypeX.fromKey(map['type'] as String),
      customType: map['custom_type'] as String?,
      intervalKm: map['interval_km'] as int?,
      intervalMonths: map['interval_months'] as int?,
    );
  }
}
