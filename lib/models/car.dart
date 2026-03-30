class Car {
  const Car({
    required this.id,
    required this.brand,
    required this.model,
    required this.year,
    required this.mileage,
    this.photoPath,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String brand;
  final String model;
  final int year;
  final int mileage;
  final String? photoPath;
  final DateTime createdAt;
  final DateTime updatedAt;

  String get displayName => '$brand $model';

  Car copyWith({
    String? id,
    String? brand,
    String? model,
    int? year,
    int? mileage,
    String? photoPath,
    bool clearPhoto = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Car(
      id: id ?? this.id,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      year: year ?? this.year,
      mileage: mileage ?? this.mileage,
      photoPath: clearPhoto ? null : photoPath ?? this.photoPath,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'brand': brand,
        'model': model,
        'year': year,
        'mileage': mileage,
        'photoPath': photoPath,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory Car.fromMap(Map<dynamic, dynamic> map) => Car(
        id: map['id'] as String,
        brand: map['brand'] as String,
        model: map['model'] as String,
        year: map['year'] as int,
        mileage: map['mileage'] as int,
        photoPath: map['photoPath'] as String?,
        createdAt: DateTime.parse(map['createdAt'] as String),
        updatedAt: DateTime.parse(map['updatedAt'] as String),
      );
}
