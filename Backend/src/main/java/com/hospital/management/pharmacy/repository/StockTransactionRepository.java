package com.hospital.management.pharmacy.repository;

import com.hospital.management.pharmacy.entity.StockTransaction;
import org.springframework.data.jpa.repository.JpaRepository;

public interface StockTransactionRepository extends JpaRepository<StockTransaction, Long> {
}