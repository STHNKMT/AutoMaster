package com.example.automaster.model

data class Car(
    val id: Int,
    val brand: String,
    val model: String,
    val year: Int,
    val mileage: Int,
    val logoResId: Int,
    val maintenances: MutableList<MaintenanceRecord> = mutableListOf()
)

data class MaintenanceRecord(
    val id: Int,
    var type: String,
    var date: String,
    var mileage: Int,
    var cost: Double
)
