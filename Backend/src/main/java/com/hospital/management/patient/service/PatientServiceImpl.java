package com.hospital.management.patient.service;

import com.hospital.management.exception.ConflictException;
import com.hospital.management.exception.ResourceNotFoundException;
import com.hospital.management.notification.service.NotificationService;
import com.hospital.management.patient.dto.PatientRequest;
import com.hospital.management.patient.dto.PatientResponse;
import com.hospital.management.patient.entity.Patient;
import com.hospital.management.patient.repository.PatientRepository;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
@Slf4j
public class PatientServiceImpl implements PatientService {

    private final PatientRepository patientRepository;
    private final NotificationService notificationService;

    // ============================================
    // CREATE
    // ============================================

    @Override
    public PatientResponse createPatient(PatientRequest request) {

        log.info("Creating patient with phone: {}", request.getPhone());

        // 🔒 Duplicate check
        if (patientRepository.existsByPhone(request.getPhone())) {
            throw new ConflictException("Phone number already exists: " + request.getPhone());
        }

        // 🧱 Build entity
        Patient patient = Patient.builder()
                .firstName(request.getFirstName())
                .lastName(request.getLastName())
                .phone(request.getPhone())
                .email(request.getEmail())
                .dateOfBirth(request.getDateOfBirth())
                .gender(request.getGender())
                .address(request.getAddress())
                .build();

        // 💾 Save patient
        Patient savedPatient = patientRepository.save(patient);

        // 📩 SEND WELCOME EMAIL (NON-BLOCKING)
        sendWelcomeEmailSafely(savedPatient);

        return map(savedPatient);
    }

    // ============================================
    // EMAIL HANDLER (CLEAN SEPARATION 🔥)
    // ============================================

    private void sendWelcomeEmailSafely(Patient patient) {

        if (patient.getEmail() == null || patient.getEmail().isBlank()) {
            log.warn("Patient {} has no email. Skipping notification.", patient.getId());
            return;
        }

        String fullName = buildFullName(patient);
        String patientId = "PAT-" + patient.getId(); // 🔥 realistic hospital ID

        try {
            notificationService.sendWelcomeEmail(
                    patient.getEmail(),
                    fullName + " (ID: " + patientId + ")"
            );

            log.info("✅ Welcome email sent to {}", patient.getEmail());

        } catch (Exception e) {
            // ⚠️ Never break main flow
            log.error("❌ Failed to send welcome email to {}", patient.getEmail(), e);
        }
    }

    // ============================================
    // GET BY ID
    // ============================================

    @Override
    public PatientResponse getPatientById(Long id) {

        Patient patient = patientRepository.findById(id)
                .orElseThrow(() ->
                        new ResourceNotFoundException("Patient not found with id: " + id));

        return map(patient);
    }

    // ============================================
    // GET ALL
    // ============================================

    @Override
    public Page<PatientResponse> getAllPatients(Pageable pageable) {

        return patientRepository.findAll(pageable)
                .map(this::map);
    }

    // ============================================
    // UPDATE
    // ============================================

    @Override
    public PatientResponse updatePatient(Long id, PatientRequest request) {

        Patient patient = patientRepository.findById(id)
                .orElseThrow(() ->
                        new ResourceNotFoundException("Patient not found with id: " + id));

        // 🔒 Phone uniqueness check
        if (!patient.getPhone().equals(request.getPhone()) &&
                patientRepository.existsByPhone(request.getPhone())) {
            throw new ConflictException("Phone number already exists: " + request.getPhone());
        }

        patient.setFirstName(request.getFirstName());
        patient.setLastName(request.getLastName());
        patient.setPhone(request.getPhone());
        patient.setEmail(request.getEmail());
        patient.setDateOfBirth(request.getDateOfBirth());
        patient.setGender(request.getGender());
        patient.setAddress(request.getAddress());

        return map(patientRepository.save(patient));
    }

    // ============================================
    // DELETE
    // ============================================

    @Override
    public void deletePatient(Long id) {

        if (!patientRepository.existsById(id)) {
            throw new ResourceNotFoundException("Patient not found with id: " + id);
        }

        patientRepository.deleteById(id);
    }

    // ============================================
    // UTIL METHODS
    // ============================================

    private String buildFullName(Patient patient) {
        String first = patient.getFirstName() != null ? patient.getFirstName() : "";
        String last = patient.getLastName() != null ? patient.getLastName() : "";
        return (first + " " + last).trim();
    }

    // ============================================
    // MAPPER
    // ============================================

    private PatientResponse map(Patient p) {
        return PatientResponse.builder()
                .id(p.getId())
                .firstName(p.getFirstName())
                .lastName(p.getLastName())
                .phone(p.getPhone())
                .email(p.getEmail())
                .dateOfBirth(p.getDateOfBirth())
                .gender(p.getGender())
                .address(p.getAddress())
                .build();
    }
}