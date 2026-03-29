package com.example.automaster.ui

import android.view.LayoutInflater
import android.view.ViewGroup
import androidx.recyclerview.widget.DiffUtil
import androidx.recyclerview.widget.ListAdapter
import androidx.recyclerview.widget.RecyclerView
import com.example.automaster.databinding.ItemCarBinding
import com.example.automaster.model.Car

class CarAdapter(
    private val onClick: (Car) -> Unit,
    private val onDelete: (Car) -> Unit
) : ListAdapter<Car, CarAdapter.CarViewHolder>(DiffCallback) {

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): CarViewHolder {
        val binding = ItemCarBinding.inflate(LayoutInflater.from(parent.context), parent, false)
        return CarViewHolder(binding)
    }

    override fun onBindViewHolder(holder: CarViewHolder, position: Int) {
        holder.bind(getItem(position))
    }

    inner class CarViewHolder(private val binding: ItemCarBinding) : RecyclerView.ViewHolder(binding.root) {
        fun bind(car: Car) {
            binding.ivLogo.setImageResource(car.logoResId)
            binding.tvBrandModel.text = "${car.brand} ${car.model}"
            binding.tvYearMileage.text = "Год: ${car.year} • Пробег: ${car.mileage} км"

            binding.root.setOnClickListener { onClick(car) }
            binding.btnDelete.setOnClickListener { onDelete(car) }
        }
    }

    companion object {
        private val DiffCallback = object : DiffUtil.ItemCallback<Car>() {
            override fun areItemsTheSame(oldItem: Car, newItem: Car): Boolean = oldItem.id == newItem.id
            override fun areContentsTheSame(oldItem: Car, newItem: Car): Boolean = oldItem == newItem
        }
    }
}
