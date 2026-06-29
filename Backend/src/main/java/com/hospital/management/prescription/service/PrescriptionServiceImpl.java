package com.hospital.management.prescription.service;

import com.hospital.management.prescription.dto.*;
import com.hospital.management.prescription.entity.*;
import com.hospital.management.prescription.enums.PrescriptionStatus;
import com.hospital.management.prescription.repository.PrescriptionRepository;
import com.hospital.management.visit.entity.Visit;
import com.hospital.management.visit.repository.VisitRepository;
import com.hospital.management.pharmacy.entity.Medicine;
import com.hospital.management.pharmacy.repository.MedicineRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional; // 🟢 Added for handling session boundaries safely

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Service
public class PrescriptionServiceImpl implements PrescriptionService {

    private final PrescriptionRepository prescriptionRepository;
    private final VisitRepository visitRepository;
    private final MedicineRepository medicineRepository;

    public PrescriptionServiceImpl(
            PrescriptionRepository prescriptionRepository,
            VisitRepository visitRepository,
            MedicineRepository medicineRepository) {
        this.prescriptionRepository = prescriptionRepository;
        this.visitRepository = visitRepository;
        this.medicineRepository = medicineRepository;
    }

    @Override
    @Transactional // 🟢 Ensures database transactional boundaries for writes
    public PrescriptionResponse createPrescription(PrescriptionRequest request) {

        Visit visit = visitRepository.findById(request.getVisitId())
                .orElseThrow(() -> new RuntimeException("Visit not found"));

        Prescription prescription = new Prescription();
        prescription.setVisit(visit);
        prescription.setCreatedAt(LocalDateTime.now());
        prescription.setStatus(PrescriptionStatus.PENDING);

        List<PrescriptionItem> items = new ArrayList<>();

        for (PrescriptionItemRequest itemReq : request.getItems()) {

            Medicine medicine = medicineRepository.findById(itemReq.getMedicineId())
                    .orElseThrow(() -> new RuntimeException("Medicine not found: " + itemReq.getMedicineId()));

            PrescriptionItem item = new PrescriptionItem();
            item.setPrescription(prescription);
            item.setMedicine(medicine);
            item.setDosage(itemReq.getDosage());
            item.setFrequency(itemReq.getFrequency());
            item.setDuration(itemReq.getDuration());

            item.setPrescribedQuantity(itemReq.getPrescribedQuantity());
            item.setDispensedQuantity(0);

            items.add(item);
        }

        prescription.setItems(items);
        Prescription saved = prescriptionRepository.save(prescription);
        return mapToResponse(saved);
    }

    @Override
    @Transactional(readOnly = true) // 🟢 Keeps session open during mapping fields
    public PrescriptionResponse getByVisit(Long visitId) {
        Prescription prescription = prescriptionRepository.findByVisitId(visitId)
                .orElseThrow(() -> new RuntimeException("Prescription not found for visitId: " + visitId));
        return mapToResponse(prescription);
    }

    @Override
    @Transactional(readOnly = true) // 🟢 Ensures session safety for collection rendering
    public List<PrescriptionResponse> getPending() {
        // 🟢 FIXED: Using the repository join-fetch method to preload lazy collections safely
        return prescriptionRepository.findByStatusNotWithItems(PrescriptionStatus.COMPLETED)
                .stream()
                .map(this::mapToResponse)
                .toList();
    }

    private PrescriptionResponse mapToResponse(Prescription prescription) {

        PrescriptionResponse res = new PrescriptionResponse();
        res.setPrescriptionId(prescription.getId());
        res.setVisitId(prescription.getVisit().getId());
        res.setPatientName(
                prescription.getVisit().getPatient().getFirstName() + " " +
                        prescription.getVisit().getPatient().getLastName()
        );
        res.setDoctorName(
                prescription.getVisit().getDoctor().getFirstName() + " " +
                        prescription.getVisit().getDoctor().getLastName()
        );
        res.setStatus(prescription.getStatus().name());

        List<PrescriptionItemResponse> itemResponses = prescription.getItems()
                .stream()
                .map(item -> {
                    PrescriptionItemResponse ir = new PrescriptionItemResponse();
                    ir.setMedicineId(item.getMedicine().getId());
                    ir.setMedicineName(item.getMedicine().getName());
                    ir.setPrescribedQuantity(item.getPrescribedQuantity());
                    ir.setDispensedQuantity(item.getDispensedQuantity());
                    ir.setFullyDispensed(item.getDispensedQuantity() >= item.getPrescribedQuantity());
                    return ir;
                })
                .toList();

        res.setItems(itemResponses);
        return res;
    }
}