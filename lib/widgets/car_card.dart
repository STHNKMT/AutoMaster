import 'dart:io';

import 'package:flutter/material.dart';

import '../l10n/app_strings.dart';
import '../models/car.dart';

class CarCard extends StatelessWidget {
  const CarCard({
    super.key,
    required this.car,
    required this.statusText,
    required this.statusColor,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    required this.onUpdateMileage,
    required this.onAddPhoto,
  });

  final Car car;
  final String statusText;
  final Color statusColor;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onUpdateMileage;
  final VoidCallback onAddPhoto;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (car.photoPath != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.file(File(car.photoPath!), height: 140, width: double.infinity, fit: BoxFit.cover),
                ),
              if (car.photoPath != null) const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: Text('${car.brand} ${car.model}', style: Theme.of(context).textTheme.titleMedium)),
                  PopupMenuButton<String>(
                    onSelected: (v) {
                      if (v == 'edit') onEdit();
                      if (v == 'delete') onDelete();
                      if (v == 'mileage') onUpdateMileage();
                      if (v == 'photo') onAddPhoto();
                    },
                    itemBuilder: (_) => [
                      PopupMenuItem(value: 'edit', child: Text(AppStrings.t('edit_car'))),
                      PopupMenuItem(value: 'mileage', child: Text(AppStrings.t('update_mileage'))),
                      PopupMenuItem(value: 'photo', child: Text(AppStrings.t('add_car_photo'))),
                      PopupMenuItem(value: 'delete', child: Text(AppStrings.t('delete'))),
                    ],
                  )
                ],
              ),
              const SizedBox(height: 6),
              Text('${AppStrings.t('year')}: ${car.year} • ${AppStrings.t('mileage')}: ${car.mileage} км'),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: statusColor.withOpacity(0.15), borderRadius: BorderRadius.circular(999)),
                child: Text(statusText, style: TextStyle(color: statusColor, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
