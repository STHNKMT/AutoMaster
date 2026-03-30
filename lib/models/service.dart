enum ServiceType { oilChange, filters, brakes, other }

enum ServiceStatus { ok, soon, overdue, noData }

class ServiceRecord {
  const ServiceRecord({
    required this.id,
    required this.carId,
    required this.type,
    required this.date,
    required this.mileage,
    required this.cost,
    required this.notes,
    this.intervalKm,
    this.intervalMonths,
    required this.createdAt,
  });

  final String id;
  final String carId;
  final ServiceType type;
  final DateTime date;
  final int mileage;
  final double cost;
  final String notes;
  final int? intervalKm;
  final int? intervalMonths;
  final DateTime createdAt;

  DateTime? get nextDueDate {
    if (intervalMonths == null) return null;
    return DateTime(date.year, date.month + intervalMonths!, date.day);
  }

  int? get nextDueMileage {
    if (intervalKm == null) return null;
    return mileage + intervalKm!;
  }

  ServiceStatus statusForMileage(int currentMileage) {
    final now = DateTime.now();
    final dueDate = nextDueDate;
    final dueMileage = nextDueMileage;

    if (dueDate == null && dueMileage == null) return ServiceStatus.noData;

    final isDateOverdue = dueDate != null && now.isAfter(dueDate);
    final isMileageOverdue = dueMileage != null && currentMileage >= dueMileage;
    if (isDateOverdue || isMileageOverdue) return ServiceStatus.overdue;

    final isDateSoon = dueDate != null && dueDate.difference(now).inDays <= 30;
    final isMileageSoon = dueMileage != null && (dueMileage - currentMileage) <= 1000;
    if (isDateSoon || isMileageSoon) return ServiceStatus.soon;

    return ServiceStatus.ok;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'carId': carId,
      'type': type.name,
      'date': date.toIso8601String(),
      'mileage': mileage,
      'cost': cost,
      'notes': notes,
      'intervalKm': intervalKm,
      'intervalMonths': intervalMonths,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ServiceRecord.fromMap(Map<dynamic, dynamic> map) {
    return ServiceRecord(
      id: map['id'] as String,
      carId: map['carId'] as String,
      type: ServiceType.values.firstWhere((e) => e.name == map['type']),
      date: DateTime.parse(map['date'] as String),
      mileage: map['mileage'] as int,
      cost: (map['cost'] as num).toDouble(),
      notes: map['notes'] as String,
      intervalKm: map['intervalKm'] as int?,
      intervalMonths: map['intervalMonths'] as int?,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }
}
