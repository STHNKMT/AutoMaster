package com.example.automaster.ui

import android.os.Bundle
import android.widget.ArrayAdapter
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import com.example.automaster.data.CarCatalog
import com.example.automaster.data.CarRepository
import com.example.automaster.databinding.ActivityAddCarBinding

class AddCarActivity : AppCompatActivity() {

    private lateinit var binding: ActivityAddCarBinding

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityAddCarBinding.inflate(layoutInflater)
        setContentView(binding.root)

        setupBrandInput()
        setupSave()
    }

    private fun setupBrandInput() {
        val brands = CarCatalog.getBrands()
        val brandAdapter = ArrayAdapter(this, android.R.layout.simple_dropdown_item_1line, brands)
        binding.actvBrand.setAdapter(brandAdapter)

        binding.actvBrand.setOnItemClickListener { _, _, _, _ ->
            val selectedBrand = binding.actvBrand.text.toString()
            val models = CarCatalog.getModels(selectedBrand)
            val modelAdapter = ArrayAdapter(this, android.R.layout.simple_dropdown_item_1line, models)
            binding.actvModel.setAdapter(modelAdapter)
            binding.actvModel.text = null
            binding.ivLogoPreview.setImageResource(CarCatalog.getLogoRes(selectedBrand))
        }

        binding.actvModel.setOnItemClickListener { _, _, _, _ ->
            val selectedBrand = binding.actvBrand.text.toString()
            binding.ivLogoPreview.setImageResource(CarCatalog.getLogoRes(selectedBrand))
        }
    }

    private fun setupSave() {
        binding.btnSaveCar.setOnClickListener {
            val brand = binding.actvBrand.text.toString().trim()
            val model = binding.actvModel.text.toString().trim()
            val year = binding.etYear.text.toString().toIntOrNull()
            val mileage = binding.etMileage.text.toString().toIntOrNull()

            if (brand.isBlank() || model.isBlank() || year == null || mileage == null) {
                Toast.makeText(this, "Заполните все поля корректно", Toast.LENGTH_SHORT).show()
                return@setOnClickListener
            }

            CarRepository.addCar(
                brand = brand,
                model = model,
                year = year,
                mileage = mileage,
                logoResId = CarCatalog.getLogoRes(brand)
            )

            Toast.makeText(this, "Автомобиль добавлен", Toast.LENGTH_SHORT).show()
            finish()
        }
    }
}
