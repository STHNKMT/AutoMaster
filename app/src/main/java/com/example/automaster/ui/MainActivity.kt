package com.example.automaster.ui

import android.content.Intent
import android.os.Bundle
import androidx.appcompat.app.AlertDialog
import androidx.appcompat.app.AppCompatActivity
import androidx.core.widget.addTextChangedListener
import androidx.recyclerview.widget.DefaultItemAnimator
import androidx.recyclerview.widget.LinearLayoutManager
import com.example.automaster.data.CarRepository
import com.example.automaster.databinding.ActivityMainBinding

class MainActivity : AppCompatActivity() {

    private lateinit var binding: ActivityMainBinding
    private lateinit var adapter: CarAdapter

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityMainBinding.inflate(layoutInflater)
        setContentView(binding.root)

        setupRecycler()
        setupActions()
    }

    override fun onResume() {
        super.onResume()
        updateList()
    }

    private fun setupRecycler() {
        adapter = CarAdapter(
            onClick = { car ->
                startActivity(Intent(this, CarDetailActivity::class.java).putExtra(CarDetailActivity.EXTRA_CAR_ID, car.id))
            },
            onDelete = { car ->
                AlertDialog.Builder(this)
                    .setTitle("Удаление автомобиля")
                    .setMessage("Удалить ${car.brand} ${car.model}?")
                    .setNegativeButton("Отмена", null)
                    .setPositiveButton("Удалить") { _, _ ->
                        CarRepository.deleteCar(car.id)
                        updateList()
                    }
                    .show()
            }
        )

        binding.recyclerCars.layoutManager = LinearLayoutManager(this)
        binding.recyclerCars.itemAnimator = DefaultItemAnimator().apply {
            addDuration = 220
            removeDuration = 220
        }
        binding.recyclerCars.adapter = adapter
    }

    private fun setupActions() {
        binding.fabAddCar.setOnClickListener {
            startActivity(Intent(this, AddCarActivity::class.java))
        }

        binding.etSearch.addTextChangedListener {
            updateList(it?.toString().orEmpty())
        }
    }

    private fun updateList(query: String = binding.etSearch.text?.toString().orEmpty()) {
        val allCars = CarRepository.getCars()
        val filtered = if (query.isBlank()) {
            allCars
        } else {
            allCars.filter {
                "${it.brand} ${it.model}".contains(query, ignoreCase = true)
            }
        }
        adapter.submitList(filtered.toList())
        binding.tvEmpty.visibility = if (filtered.isEmpty()) android.view.View.VISIBLE else android.view.View.GONE
    }
}
