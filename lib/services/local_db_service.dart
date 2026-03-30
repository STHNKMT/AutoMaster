import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../models/car.dart';
import '../models/service_interval.dart';
import '../models/service_record.dart';

class LocalDbService {
  LocalDbService._();
  static final LocalDbService instance = LocalDbService._();

  static const _dbName = 'auto_master.db';
  Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await _open();
    return _db!;
  }

  Future<Database> _open() async {
    final path = p.join(await getDatabasesPath(), _dbName);
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, _) async {
        await db.execute('''
          CREATE TABLE cars(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            brand TEXT NOT NULL,
            model TEXT NOT NULL,
            year INTEGER NOT NULL,
            vin TEXT,
            mileage INTEGER NOT NULL,
            fuel_type TEXT NOT NULL,
            created_at TEXT NOT NULL,
            updated_at TEXT NOT NULL
          );
        ''');

        await db.execute('''
          CREATE TABLE service_records(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            car_id INTEGER NOT NULL,
            type TEXT NOT NULL,
            custom_type TEXT,
            date TEXT NOT NULL,
            mileage INTEGER NOT NULL,
            notes TEXT NOT NULL,
            cost REAL NOT NULL,
            FOREIGN KEY (car_id) REFERENCES cars(id) ON DELETE CASCADE
          );
        ''');

        await db.execute('''
          CREATE TABLE service_intervals(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            car_id INTEGER NOT NULL,
            type TEXT NOT NULL,
            custom_type TEXT,
            interval_km INTEGER,
            interval_months INTEGER,
            FOREIGN KEY (car_id) REFERENCES cars(id) ON DELETE CASCADE
          );
        ''');
      },
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON;');
      },
    );
  }

  Future<List<Car>> getCars({String query = '', String sort = 'mileage_desc'}) async {
    final database = await db;
    String orderBy = 'mileage DESC';
    if (sort == 'mileage_asc') orderBy = 'mileage ASC';
    if (sort == 'updated_desc') orderBy = 'updated_at DESC';

    final rows = await database.query(
      'cars',
      where: query.trim().isEmpty ? null : '(brand LIKE ? OR model LIKE ? OR vin LIKE ?)',
      whereArgs: query.trim().isEmpty ? null : ['%$query%', '%$query%', '%$query%'],
      orderBy: orderBy,
    );

    return rows.map(Car.fromMap).toList();
  }

  Future<int> upsertCar(Car car) async {
    final database = await db;
    final now = DateTime.now().toIso8601String();
    if (car.id == null) {
      return database.insert('cars', car.copyWith(createdAt: DateTime.now(), updatedAt: DateTime.now()).toMap());
    }
    await database.update(
      'cars',
      car.copyWith(updatedAt: DateTime.parse(now)).toMap()..remove('created_at'),
      where: 'id = ?',
      whereArgs: [car.id],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return car.id!;
  }

  Future<void> deleteCar(int carId) async {
    final database = await db;
    await database.delete('cars', where: 'id = ?', whereArgs: [carId]);
  }

  Future<List<ServiceRecord>> getServiceRecords(int carId) async {
    final database = await db;
    final rows = await database.query('service_records', where: 'car_id = ?', whereArgs: [carId], orderBy: 'date DESC');
    return rows.map(ServiceRecord.fromMap).toList();
  }

  Future<int> addServiceRecord(ServiceRecord record) async {
    final database = await db;
    await database.update(
      'cars',
      {
        'mileage': record.mileage,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [record.carId],
    );
    return database.insert('service_records', record.toMap());
  }

  Future<List<ServiceInterval>> getIntervals(int carId) async {
    final database = await db;
    final rows = await database.query('service_intervals', where: 'car_id = ?', whereArgs: [carId]);
    return rows.map(ServiceInterval.fromMap).toList();
  }

  Future<void> upsertInterval(ServiceInterval interval) async {
    final database = await db;
    final existing = await database.query(
      'service_intervals',
      where: 'car_id = ? AND type = ? AND COALESCE(custom_type, "") = ?',
      whereArgs: [interval.carId, interval.type.key, interval.customType ?? ''],
      limit: 1,
    );

    if (existing.isEmpty) {
      await database.insert('service_intervals', interval.toMap());
    } else {
      await database.update(
        'service_intervals',
        interval.toMap()..remove('id'),
        where: 'id = ?',
        whereArgs: [existing.first['id']],
      );
    }
  }

  Future<double> totalCost() async {
    final database = await db;
    final result = await database.rawQuery('SELECT SUM(cost) AS total FROM service_records');
    return ((result.first['total'] as num?) ?? 0).toDouble();
  }

  Future<Map<String, dynamic>> exportAsJson() async {
    final database = await db;
    final cars = await database.query('cars');
    final records = await database.query('service_records');
    final intervals = await database.query('service_intervals');

    return {
      'exported_at': DateTime.now().toIso8601String(),
      'cars': cars,
      'service_records': records,
      'service_intervals': intervals,
    };
  }

  Future<String> saveExportFile() async {
    final data = await exportAsJson();
    final dir = await getApplicationDocumentsDirectory();
    final path = p.join(dir.path, 'automaster_export_${DateTime.now().millisecondsSinceEpoch}.json');
    final file = File(path);
    await file.writeAsString(const JsonEncoder.withIndent('  ').convert(data));
    return path;
  }
}
