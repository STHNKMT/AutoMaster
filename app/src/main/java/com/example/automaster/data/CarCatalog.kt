package com.example.automaster.data

import com.example.automaster.R

object CarCatalog {
    private val brandModels = linkedMapOf(
        "Toyota" to listOf("Camry", "Corolla", "RAV4", "Land Cruiser"),
        "BMW" to listOf("3 Series", "5 Series", "X5", "X3"),
        "Mercedes-Benz" to listOf("C-Class", "E-Class", "GLC", "GLE"),
        "Audi" to listOf("A4", "A6", "Q5", "Q7"),
        "Volkswagen" to listOf("Polo", "Passat", "Tiguan", "Touareg"),
        "Kia" to listOf("Rio", "Sportage", "K5", "Sorento"),
        "Hyundai" to listOf("Solaris", "Elantra", "Tucson", "Santa Fe")
    )

    fun getBrands(): List<String> = brandModels.keys.toList()

    fun getModels(brand: String): List<String> = brandModels[brand].orEmpty()

    fun getLogoRes(brand: String): Int = when (brand) {
        "Toyota" -> R.drawable.logo_toyota
        "BMW" -> R.drawable.logo_bmw
        "Mercedes-Benz" -> R.drawable.logo_mercedes
        "Audi" -> R.drawable.logo_audi
        "Volkswagen" -> R.drawable.logo_vw
        "Kia" -> R.drawable.logo_kia
        "Hyundai" -> R.drawable.logo_hyundai
        else -> R.drawable.logo_default
    }
}
