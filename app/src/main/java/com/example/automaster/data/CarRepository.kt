package com.example.automaster.data

import com.example.automaster.model.Car
import com.example.automaster.model.MaintenanceRecord
import kotlin.math.roundToInt

object CarRepository {
    private val cars = mutableListOf<Car>()
    private var carIdCounter = 1
    private var maintenanceIdCounter = 1

    fun getCars(): List<Car> = cars

    fun addCar(brand: String, model: String, year: Int, mileage: Int, logoResId: Int) {
        cars.add(
            Car(
                id = carIdCounter++,
                brand = brand,
                model = model,
                year = year,
                mileage = mileage,
                logoResId = logoResId
            )
        )
    }

    fun deleteCar(id: Int) {
        cars.removeAll { it.id == id }
    }

    fun getCarById(id: Int): Car? = cars.find { it.id == id }

    fun addMaintenance(carId: Int, type: String, date: String, mileage: Int, cost: Double) {
        getCarById(carId)?.maintenances?.add(
            MaintenanceRecord(
                id = maintenanceIdCounter++,
                type = type,
                date = date,
                mileage = mileage,
                cost = (cost * 100).roundToInt() / 100.0
            )
        )
    }

    fun updateMaintenance(carId: Int, maintenance: MaintenanceRecord) {
        val car = getCarById(carId) ?: return
        val index = car.maintenances.indexOfFirst { it.id == maintenance.id }
        if (index >= 0) {
            car.maintenances[index] = maintenance.copy(cost = (maintenance.cost * 100).roundToInt() / 100.0)
        }
    }

    fun deleteMaintenance(carId: Int, maintenanceId: Int) {
        getCarById(carId)?.maintenances?.removeAll { it.id == maintenanceId }
    }
}
