package com.example.automaster.ui

import android.os.Bundle
import android.view.LayoutInflater
import android.widget.ArrayAdapter
import android.widget.Toast
import androidx.appcompat.app.AlertDialog
import androidx.appcompat.app.AppCompatActivity
import androidx.recyclerview.widget.DefaultItemAnimator
import androidx.recyclerview.widget.LinearLayoutManager
import com.example.automaster.data.CarRepository
import com.example.automaster.databinding.ActivityCarDetailBinding
import com.example.automaster.databinding.DialogMaintenanceBinding
import com.example.automaster.model.MaintenanceRecord
import java.text.NumberFormat
import java.util.Locale

class CarDetailActivity : AppCompatActivity() {

    private lateinit var binding: ActivityCarDetailBinding
    private lateinit var adapter: MaintenanceAdapter
    private var carId: Int = -1
    private val moneyFormatter = NumberFormat.getCurrencyInstance(Locale("ru", "RU"))

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityCarDetailBinding.inflate(layoutInflater)
        setContentView(binding.root)

        carId = intent.getIntExtra(EXTRA_CAR_ID, -1)

        if (carId < 0 || CarRepository.getCarById(carId) == null) {
            Toast.makeText(this, "Автомобиль не найден", Toast.LENGTH_SHORT).show()
            finish()
            return
        }

        setupHeader()
        setupMaintenanceList()
        setupActions()
        refreshMaintenance()
    }

    private fun setupHeader() {
        val car = CarRepository.getCarById(carId) ?: return
        binding.ivCarLogo.setImageResource(car.logoResId)
        binding.tvCarTitle.text = "${car.brand} ${car.model}"
        binding.tvCarSubtitle.text = "Год: ${car.year} • Пробег: ${car.mileage} км"
    }

    private fun setupMaintenanceList() {
        adapter = MaintenanceAdapter(
            onEdit = { record -> showMaintenanceDialog(record) },
            onDelete = { record ->
                CarRepository.deleteMaintenance(carId, record.id)
                refreshMaintenance()
            }
        )

        binding.recyclerMaintenance.layoutManager = LinearLayoutManager(this)
        binding.recyclerMaintenance.itemAnimator = DefaultItemAnimator().apply {
            addDuration = 200
            removeDuration = 200
        }
        binding.recyclerMaintenance.adapter = adapter
    }

    private fun setupActions() {
        binding.fabAddMaintenance.setOnClickListener {
            showMaintenanceDialog(null)
        }
    }

    private fun refreshMaintenance() {
        val car = CarRepository.getCarById(carId) ?: return
        adapter.submitList(car.maintenances.toList())

        val total = car.maintenances.sumOf { it.cost }
        binding.tvTotalCost.text = "Общие расходы: ${moneyFormatter.format(total)}"
        binding.tvMaintenanceEmpty.visibility = if (car.maintenances.isEmpty()) android.view.View.VISIBLE else android.view.View.GONE
    }

    private fun showMaintenanceDialog(existing: MaintenanceRecord?) {
        val dialogBinding = DialogMaintenanceBinding.inflate(LayoutInflater.from(this))

        val types = listOf("Замена масла", "Диагностика", "Тормозная система", "Шиномонтаж", "Другое")
        dialogBinding.actvMaintenanceType.setAdapter(
            ArrayAdapter(this, android.R.layout.simple_dropdown_item_1line, types)
        )

        if (existing != null) {
            dialogBinding.actvMaintenanceType.setText(existing.type, false)
            dialogBinding.etDate.setText(existing.date)
            dialogBinding.etMileage.setText(existing.mileage.toString())
            dialogBinding.etCost.setText(existing.cost.toString())
        }

        AlertDialog.Builder(this)
            .setTitle(if (existing == null) "Добавить ТО" else "Редактировать ТО")
            .setView(dialogBinding.root)
            .setNegativeButton("Отмена", null)
            .setPositiveButton("Сохранить") { _, _ ->
                val type = dialogBinding.actvMaintenanceType.text.toString().trim()
                val date = dialogBinding.etDate.text.toString().trim()
                val mileage = dialogBinding.etMileage.text.toString().toIntOrNull()
                val cost = dialogBinding.etCost.text.toString().replace(',', '.').toDoubleOrNull()

                if (type.isBlank() || date.isBlank() || mileage == null || cost == null) {
                    Toast.makeText(this, "Заполните поля корректно", Toast.LENGTH_SHORT).show()
                    return@setPositiveButton
                }

                if (existing == null) {
                    CarRepository.addMaintenance(carId, type, date, mileage, cost)
                } else {
                    CarRepository.updateMaintenance(
                        carId,
                        existing.copy(type = type, date = date, mileage = mileage, cost = cost)
                    )
                }

                refreshMaintenance()
            }
            .show()
    }

    companion object {
        const val EXTRA_CAR_ID = "extra_car_id"
    }
}
