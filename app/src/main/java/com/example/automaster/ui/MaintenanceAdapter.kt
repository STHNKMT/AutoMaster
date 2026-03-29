package com.example.automaster.ui

import android.view.LayoutInflater
import android.view.ViewGroup
import androidx.recyclerview.widget.DiffUtil
import androidx.recyclerview.widget.ListAdapter
import androidx.recyclerview.widget.RecyclerView
import com.example.automaster.databinding.ItemMaintenanceBinding
import com.example.automaster.model.MaintenanceRecord
import java.text.NumberFormat
import java.util.Locale

class MaintenanceAdapter(
    private val onEdit: (MaintenanceRecord) -> Unit,
    private val onDelete: (MaintenanceRecord) -> Unit
) : ListAdapter<MaintenanceRecord, MaintenanceAdapter.MaintenanceViewHolder>(DiffCallback) {

    private val moneyFormatter = NumberFormat.getCurrencyInstance(Locale("ru", "RU"))

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): MaintenanceViewHolder {
        val binding = ItemMaintenanceBinding.inflate(LayoutInflater.from(parent.context), parent, false)
        return MaintenanceViewHolder(binding)
    }

    override fun onBindViewHolder(holder: MaintenanceViewHolder, position: Int) {
        holder.bind(getItem(position))
    }

    inner class MaintenanceViewHolder(private val binding: ItemMaintenanceBinding) : RecyclerView.ViewHolder(binding.root) {
        fun bind(item: MaintenanceRecord) {
            binding.tvMaintenanceType.text = item.type
            binding.tvMaintenanceDetails.text = "${item.date} • ${item.mileage} км"
            binding.tvMaintenanceCost.text = moneyFormatter.format(item.cost)

            binding.btnEditMaintenance.setOnClickListener { onEdit(item) }
            binding.btnDeleteMaintenance.setOnClickListener { onDelete(item) }
        }
    }

    companion object {
        private val DiffCallback = object : DiffUtil.ItemCallback<MaintenanceRecord>() {
            override fun areItemsTheSame(oldItem: MaintenanceRecord, newItem: MaintenanceRecord): Boolean = oldItem.id == newItem.id
            override fun areContentsTheSame(oldItem: MaintenanceRecord, newItem: MaintenanceRecord): Boolean = oldItem == newItem
        }
    }
}
