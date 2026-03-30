import 'package:flutter/material.dart';

import '../models/car.dart';
import '../models/service_interval.dart';
import '../models/service_record.dart';
import '../services/local_db_service.dart';
import '../widgets/dashboard_section.dart';
import 'add_edit_car_screen.dart';
import 'car_details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();
  List<Car> _cars = const [];
  bool _loading = true;
  String _sort = 'mileage_desc';
  int _upcoming = 0;
  int _overdue = 0;
  double _totalCost = 0;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    final cars = await LocalDbService.instance.getCars(query: _searchController.text.trim(), sort: _sort);

    int upcoming = 0;
    int overdue = 0;
    for (final car in cars) {
      final intervals = await LocalDbService.instance.getIntervals(car.id!);
      final records = await LocalDbService.instance.getServiceRecords(car.id!);
      for (final i in intervals) {
        final r = _latestRecord(i, records);
        final nextDate = i.calculateNextDate(r?.date);
        final nextMileage = i.calculateNextMileage(r?.mileage);
        if (nextDate != null) {
          if (nextDate.isBefore(DateTime.now())) {
            overdue++;
          } else if (nextDate.difference(DateTime.now()).inDays <= 30) {
            upcoming++;
          }
        }
        if (nextMileage != null) {
          if (car.mileage >= nextMileage) {
            overdue++;
          } else if (nextMileage - car.mileage <= 500) {
            upcoming++;
          }
        }
      }
    }

    final totalCost = await LocalDbService.instance.totalCost();

    if (!mounted) return;
    setState(() {
      _cars = cars;
      _upcoming = upcoming;
      _overdue = overdue;
      _totalCost = totalCost;
      _loading = false;
    });
  }

  ServiceRecord? _latestRecord(ServiceInterval interval, List<ServiceRecord> records) {
    final matches = records
        .where((r) => r.type == interval.type && (r.customType ?? '') == (interval.customType ?? ''))
        .toList();
    if (matches.isEmpty) return null;
    matches.sort((a, b) => b.date.compareTo(a.date));
    return matches.first;
  }

  Future<void> _openCarForm([Car? car]) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => AddEditCarScreen(car: car)),
    );
    if (changed == true) await _refresh();
  }

  Future<void> _deleteCar(Car car) async {
    await LocalDbService.instance.deleteCar(car.id!);
    await _refresh();
  }

  Future<void> _export() async {
    final path = await LocalDbService.instance.saveExportFile();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Exported: $path')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Auto Service / ТО'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (v) async {
              setState(() => _sort = v);
              await _refresh();
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'mileage_desc', child: Text('Sort: mileage ↓')),
              PopupMenuItem(value: 'mileage_asc', child: Text('Sort: mileage ↑')),
              PopupMenuItem(value: 'updated_desc', child: Text('Sort: last service')),
            ],
          ),
          IconButton(onPressed: _export, icon: const Icon(Icons.download)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openCarForm(),
        child: const Icon(Icons.add),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                padding: const EdgeInsets.all(12),
                children: [
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: IconButton(
                        onPressed: _refresh,
                        icon: const Icon(Icons.filter_alt_outlined),
                      ),
                      hintText: 'Search by brand/model/VIN',
                    ),
                    onSubmitted: (_) => _refresh(),
                  ),
                  const SizedBox(height: 10),
                  DashboardSection(upcoming: _upcoming, overdue: _overdue, totalCost: _totalCost),
                  const SizedBox(height: 10),
                  if (_cars.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 40),
                      child: Center(child: Text('No cars yet. Tap + to add.')),
                    ),
                  ..._cars.map(
                    (car) => Card(
                      child: ListTile(
                        title: Text(car.title),
                        subtitle: Text('Mileage: ${car.mileage} km • Fuel: ${car.fuelType}${car.vin == null ? '' : '\nVIN: ${car.vin}'}'),
                        onTap: () async {
                          await Navigator.push(context, MaterialPageRoute(builder: (_) => CarDetailsScreen(car: car)));
                          await _refresh();
                        },
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(onPressed: () => _openCarForm(car), icon: const Icon(Icons.edit)),
                            IconButton(onPressed: () => _deleteCar(car), icon: const Icon(Icons.delete_outline)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
