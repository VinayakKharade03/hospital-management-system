package com.hospital.management.lab.repository;

import com.hospital.management.lab.entity.LabTestParameter;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface LabTestParameterRepository extends JpaRepository<LabTestParameter, Long> {

    List<LabTestParameter> findByLabTestId(Long testId);

}