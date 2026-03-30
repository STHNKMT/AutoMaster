import 'package:flutter/material.dart';

import '../models/car.dart';
import '../models/service_interval.dart';
import '../models/service_record.dart';
import '../services/local_db_service.dart';
import '../services/reminder_service.dart';

class CarDetailsScreen extends StatefulWidget {
  const CarDetailsScreen({super.key, required this.car});

  final Car car;

  @override
  State<CarDetailsScreen> createState() => _CarDetailsScreenState();
}

class _CarDetailsScreenState extends State<CarDetailsScreen> {
  List<ServiceRecord> _records = const [];
  List<ServiceInterval> _intervals = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final records = await LocalDbService.instance.getServiceRecords(widget.car.id!);
    final intervals = await LocalDbService.instance.getIntervals(widget.car.id!);
    if (!mounted) return;
    setState(() {
      _records = records;
      _intervals = intervals;
      _loading = false;
    });
  }

  Future<void> _addRecord() async {
    final result = await showDialog<ServiceRecord>(
      context: context,
      builder: (_) => _ServiceRecordDialog(carId: widget.car.id!, currentMileage: widget.car.mileage),
    );
    if (result == null) return;
    await LocalDbService.instance.addServiceRecord(result);
    await _scheduleReminders();
    await _load();
  }

  Future<void> _setInterval() async {
    final interval = await showDialog<ServiceInterval>(
      context: context,
      builder: (_) => _IntervalDialog(carId: widget.car.id!),
    );
    if (interval == null) return;
    await LocalDbService.instance.upsertInterval(interval);
    await _scheduleReminders();
    await _load();
  }

  Future<void> _scheduleReminders() async {
    for (final interval in _intervals) {
      final matching = _records.where((r) => r.type == interval.type && (r.customType ?? '') == (interval.customType ?? '')).toList();
      final last = matching.isEmpty ? null : matching.first;

      final nextDate = interval.calculateNextDate(last?.date);
      final nextMileage = interval.calculateNextMileage(last?.mileage);

      if (nextDate != null) {
        await ReminderService.instance.scheduleDateReminder(
          id: (widget.car.id! * 1000) + interval.type.index,
          title: 'Service reminder: ${widget.car.title}',
          body: 'Upcoming ${interval.typeKey} on ${nextDate.toLocal().toString().split(' ').first}',
          dueDate: nextDate,
        );
      }

      if (nextMileage != null && widget.car.mileage >= nextMileage - 200) {
        await ReminderService.instance.notifyMileageDue(
          id: (widget.car.id! * 10000) + interval.type.index,
          title: 'Mileage reminder: ${widget.car.title}',
          body: '${interval.typeKey} due around $nextMileage km',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.car.title),
        actions: [IconButton(onPressed: _setInterval, icon: const Icon(Icons.tune))],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addRecord,
        icon: const Icon(Icons.add),
        label: const Text('Add service'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _records.length,
              itemBuilder: (context, index) {
                final r = _records[index];
                return ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.build)),
                  title: Text(r.typeLabel),
                  subtitle: Text('${r.date.toLocal().toString().split(' ').first} • ${r.mileage} km\n${r.notes}'),
                  trailing: Text('\$${r.cost.toStringAsFixed(2)}'),
                );
              },
            ),
    );
  }
}

class _ServiceRecordDialog extends StatefulWidget {
  const _ServiceRecordDialog({required this.carId, required this.currentMileage});

  final int carId;
  final int currentMileage;

  @override
  State<_ServiceRecordDialog> createState() => _ServiceRecordDialogState();
}

class _ServiceRecordDialogState extends State<_ServiceRecordDialog> {
  ServiceType _type = ServiceType.oilChange;
  final _customType = TextEditingController();
  final _mileage = TextEditingController();
  final _notes = TextEditingController();
  final _cost = TextEditingController(text: '0');
  DateTime _date = DateTime.now();

  @override
  void initState() {
    super.initState();
    _mileage.text = widget.currentMileage.toString();
  }

  @override
  void dispose() {
    _customType.dispose();
    _mileage.dispose();
    _notes.dispose();
    _cost.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add service record'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<ServiceType>(
              value: _type,
              items: ServiceType.values.map((e) => DropdownMenuItem(value: e, child: Text(e.key))).toList(),
              onChanged: (v) => setState(() => _type = v ?? ServiceType.oilChange),
              decoration: const InputDecoration(labelText: 'Type'),
            ),
            if (_type == ServiceType.custom)
              TextField(controller: _customType, decoration: const InputDecoration(labelText: 'Custom type')),
            TextField(controller: _mileage, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Mileage')),
            TextField(controller: _cost, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Cost')),
            TextField(controller: _notes, decoration: const InputDecoration(labelText: 'Notes')),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: Text('Date: ${_date.toLocal().toString().split(' ').first}')),
                IconButton(
                  onPressed: () async {
                    final picked = await showDatePicker(context: context, initialDate: _date, firstDate: DateTime(2000), lastDate: DateTime(2100));
                    if (picked != null) setState(() => _date = picked);
                  },
                  icon: const Icon(Icons.calendar_month),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(
          onPressed: () {
            final mileage = int.tryParse(_mileage.text.trim());
            final cost = double.tryParse(_cost.text.trim());
            if (mileage == null || cost == null) return;
            Navigator.pop(
              context,
              ServiceRecord(
                carId: widget.carId,
                type: _type,
                customType: _type == ServiceType.custom ? _customType.text.trim() : null,
                date: _date,
                mileage: mileage,
                notes: _notes.text.trim(),
                cost: cost,
              ),
            );
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}

class _IntervalDialog extends StatefulWidget {
  const _IntervalDialog({required this.carId});

  final int carId;

  @override
  State<_IntervalDialog> createState() => _IntervalDialogState();
}

class _IntervalDialogState extends State<_IntervalDialog> {
  ServiceType _type = ServiceType.oilChange;
  final _customType = TextEditingController();
  final _km = TextEditingController();
  final _months = TextEditingController();

  @override
  void dispose() {
    _customType.dispose();
    _km.dispose();
    _months.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Set service interval'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<ServiceType>(
              value: _type,
              items: ServiceType.values.map((e) => DropdownMenuItem(value: e, child: Text(e.key))).toList(),
              onChanged: (v) => setState(() => _type = v ?? ServiceType.oilChange),
            ),
            if (_type == ServiceType.custom)
              TextField(controller: _customType, decoration: const InputDecoration(labelText: 'Custom type')),
            TextField(controller: _km, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Interval km (optional)')),
            TextField(controller: _months, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Interval months (optional)')),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(
          onPressed: () {
            final km = int.tryParse(_km.text.trim());
            final months = int.tryParse(_months.text.trim());
            if (km == null && months == null) return;
            Navigator.pop(
              context,
              ServiceInterval(
                carId: widget.carId,
                type: _type,
                customType: _type == ServiceType.custom ? _customType.text.trim() : null,
                intervalKm: km,
                intervalMonths: months,
              ),
            );
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
