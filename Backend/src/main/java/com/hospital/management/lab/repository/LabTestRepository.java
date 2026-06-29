package com.hospital.management.lab.repository;

import com.hospital.management.lab.entity.LabTest;
import org.springframework.data.jpa.repository.JpaRepository;

public interface LabTestRepository extends JpaRepository<LabTest, Long> {
}