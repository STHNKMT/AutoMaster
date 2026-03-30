class MaintenanceRecord {
  const MaintenanceRecord({
    required this.id,
    required this.carId,
    required this.whatDone,
    required this.date,
    required this.mileage,
  });

  final String id;
  final String carId;
  final String whatDone;
  final DateTime date;
  final int mileage;

  Map<String, dynamic> toMap() => {
        'id': id,
        'carId': carId,
        'whatDone': whatDone,
        'date': date.toIso8601String(),
        'mileage': mileage,
      };

  factory MaintenanceRecord.fromMap(Map<dynamic, dynamic> map) => MaintenanceRecord(
        id: map['id'] as String,
        carId: map['carId'] as String,
        whatDone: map['whatDone'] as String,
        date: DateTime.parse(map['date'] as String),
        mileage: map['mileage'] as int,
      );
}
