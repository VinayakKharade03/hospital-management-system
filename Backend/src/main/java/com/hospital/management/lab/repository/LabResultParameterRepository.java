package com.hospital.management.lab.repository;

import com.hospital.management.lab.entity.LabResultParameter;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface LabResultParameterRepository extends JpaRepository<LabResultParameter, Long> {

    List<LabResultParameter> findByOrderId(Long orderId);

}