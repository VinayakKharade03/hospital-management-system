package com.hospital.management.pharmacy.service;

import com.hospital.management.pharmacy.dto.MedicineRequest;
import com.hospital.management.pharmacy.dto.MedicineResponse;
import com.hospital.management.pharmacy.entity.Medicine;
import com.hospital.management.pharmacy.repository.MedicineRepository;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class MedicineServiceImpl implements MedicineService {

    private final MedicineRepository medicineRepository;

    @Override
    public MedicineResponse addMedicine(MedicineRequest request) {

        Medicine medicine = new Medicine();
        medicine.setName(request.getName());
        medicine.setUnitPrice(request.getUnitPrice());

        return map(medicineRepository.save(medicine));
    }

    @Override
    public List<MedicineResponse> getAllMedicines() {
        return medicineRepository.findAll()
                .stream()
                .map(this::map)
                .toList();
    }

    @Override
    public MedicineResponse getMedicine(Long id) {
        return map(medicineRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Medicine not found")));
    }

    @Override
    public void deleteMedicine(Long id) {
        if (!medicineRepository.existsById(id)) {
            throw new RuntimeException("Medicine not found");
        }
        medicineRepository.deleteById(id);
    }

    @Override
    public List<MedicineResponse> searchMedicines(String query) {
        return medicineRepository.findByNameContainingIgnoreCase(query)
                .stream()
                .map(this::map)
                .toList();
    }

    private MedicineResponse map(Medicine m) {
        MedicineResponse res = new MedicineResponse();
        res.setId(m.getId());
        res.setName(m.getName());
        res.setUnitPrice(m.getUnitPrice());
        return res;
    }
}