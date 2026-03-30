import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../l10n/app_strings.dart';
import '../models/car.dart';
import '../services/storage_service.dart';
import '../widgets/car_card.dart';
import 'add_car_screen.dart';
import 'car_details_screen.dart';

enum CarsSort { mileage, lastMaintenance }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();
  final _imagePicker = ImagePicker();
  CarsSort _sort = CarsSort.mileage;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Car> _cars() {
    final q = _searchController.text.trim().toLowerCase();
    final list = StorageService.instance.getCars().where((c) {
      if (q.isEmpty) return true;
      return c.brand.toLowerCase().contains(q) || c.model.toLowerCase().contains(q);
    }).toList();

    if (_sort == CarsSort.mileage) {
      list.sort((a, b) => b.mileage.compareTo(a.mileage));
    } else {
      list.sort((a, b) {
        final al = StorageService.instance.getMaintenanceByCar(a.id);
        final bl = StorageService.instance.getMaintenanceByCar(b.id);
        final ad = al.isEmpty ? DateTime.fromMillisecondsSinceEpoch(0) : al.first.date;
        final bd = bl.isEmpty ? DateTime.fromMillisecondsSinceEpoch(0) : bl.first.date;
        return bd.compareTo(ad);
      });
    }
    return list;
  }

  String _statusText(Car car) {
    final list = StorageService.instance.getMaintenanceByCar(car.id);
    if (list.isEmpty) return 'Нет данных по ТО';
    final km = car.mileage - list.first.mileage;
    if (km >= 10000) return 'Просрочено';
    if (km >= 8000) return 'Скоро ТО';
    return 'Всё нормально';
  }

  Color _statusColor(Car car) {
    final s = _statusText(car);
    if (s == 'Просрочено') return Colors.red;
    if (s == 'Скоро ТО') return Colors.amber;
    if (s == 'Всё нормально') return Colors.green;
    return Colors.blueGrey;
  }

  Future<void> _openAddCar([Car? car]) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => AddCarScreen(initialCar: car)));
    if (mounted) setState(() {});
  }

  Future<void> _deleteCar(Car car) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(AppStrings.t('delete_car_title')),
        content: Text(AppStrings.t('delete_car_message')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(AppStrings.t('cancel'))),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(AppStrings.t('delete'))),
        ],
      ),
    );

    if (ok == true) {
      await StorageService.instance.deleteCar(car.id);
      if (mounted) setState(() {});
    }
  }

  Future<void> _updateMileage(Car car) async {
    final controller = TextEditingController(text: car.mileage.toString());
    final saved = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(AppStrings.t('update_mileage')),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: AppStrings.t('new_mileage')),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(AppStrings.t('cancel'))),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(AppStrings.t('save'))),
        ],
      ),
    );

    if (saved == true) {
      final value = int.tryParse(controller.text.trim());
      if (value != null && value >= 0) {
        await StorageService.instance.updateMileage(car.id, value);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppStrings.t('saved'))));
        setState(() {});
      }
    }

    controller.dispose();
  }

  Future<void> _addPhoto(Car car) async {
    final source = await showDialog<ImageSource>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(AppStrings.t('add_car_photo')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, ImageSource.gallery), child: Text(AppStrings.t('gallery'))),
          FilledButton(onPressed: () => Navigator.pop(context, ImageSource.camera), child: Text(AppStrings.t('camera'))),
        ],
      ),
    );

    if (source == null) return;
    final photo = await _imagePicker.pickImage(source: source, imageQuality: 85);
    if (photo == null) return;

    await StorageService.instance.updateCarPhoto(car.id, photo.path);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppStrings.t('saved'))));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final cars = _cars();

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.t('cars_tab')),
        actions: [
          PopupMenuButton<CarsSort>(
            initialValue: _sort,
            onSelected: (v) => setState(() => _sort = v),
            itemBuilder: (_) => [
              PopupMenuItem(value: CarsSort.mileage, child: Text(AppStrings.t('sort_mileage'))),
              PopupMenuItem(value: CarsSort.lastMaintenance, child: Text(AppStrings.t('sort_last_service'))),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddCar,
        icon: const Icon(Icons.add),
        label: Text(AppStrings.t('add_car')),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _searchController,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(hintText: AppStrings.t('search_hint'), prefixIcon: const Icon(Icons.search)),
          ),
          const SizedBox(height: 12),
          if (cars.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 40),
              child: Center(child: Text(AppStrings.t('no_cars'))),
            )
          else
            ...cars.map(
              (car) => CarCard(
                car: car,
                statusText: _statusText(car),
                statusColor: _statusColor(car),
                onTap: () async {
                  await Navigator.push(context, MaterialPageRoute(builder: (_) => CarDetailsScreen(car: car)));
                  if (mounted) setState(() {});
                },
                onEdit: () => _openAddCar(car),
                onDelete: () => _deleteCar(car),
                onUpdateMileage: () => _updateMileage(car),
                onAddPhoto: () => _addPhoto(car),
              ),
            ),
        ],
      ),
    );
  }
}
