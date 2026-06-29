package com.hospital.management.pharmacy.service;

import com.hospital.management.pharmacy.dto.MedicineRequest;
import com.hospital.management.pharmacy.dto.MedicineResponse;

import java.util.List;

public interface MedicineService {

    MedicineResponse addMedicine(MedicineRequest request);

    List<MedicineResponse> getAllMedicines();

    MedicineResponse getMedicine(Long id);

    void deleteMedicine(Long id);

    List<MedicineResponse> searchMedicines(String query);
}