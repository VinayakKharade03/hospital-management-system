package com.hospital.management.doctor.service;

import com.hospital.management.doctor.dto.AvailabilityRequest;
import com.hospital.management.doctor.dto.AvailabilityResponse;
import com.hospital.management.doctor.entity.Doctor;
import com.hospital.management.doctor.entity.DoctorAvailability;
import com.hospital.management.doctor.repository.DoctorAvailabilityRepository;
import com.hospital.management.doctor.repository.DoctorRepository;
import com.hospital.management.notification.service.NotificationService;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional; // Added for data safety

import java.util.List;

@Service
@RequiredArgsConstructor
public class DoctorAvailabilityServiceImpl implements DoctorAvailabilityService {

    private final DoctorRepository doctorRepository;
    private final DoctorAvailabilityRepository availabilityRepository;
    private final NotificationService notificationService;

    // ============================================
    // ADD / OVERWRITE AVAILABILITY
    // ============================================
    @Override
    @Transactional // Ensures both delete and save succeed together as a single atomic unit
    public AvailabilityResponse addAvailability(Long doctorId, AvailabilityRequest request) {

        // 1. Verify the doctor exists
        Doctor doctor = doctorRepository.findById(doctorId)
                .orElseThrow(() -> new RuntimeException("Doctor not found"));

        // 2. Clear out any existing availability for this doctor on this specific day
        availabilityRepository.deleteByDoctorIdAndDayOfWeek(doctorId, request.dayOfWeek());

        // 3. Build and save the fresh availability record
        DoctorAvailability availability = DoctorAvailability.builder()
                .doctor(doctor)
                .dayOfWeek(request.dayOfWeek())
                .startTime(request.startTime())
                .endTime(request.endTime())
                .slotDurationMinutes(request.slotDurationMinutes())
                .build();

        DoctorAvailability saved = availabilityRepository.save(availability);

        // ============================================
        // 📧 SEND EMAIL TO DOCTOR
        // ============================================
        try {
            if (doctor.getEmail() != null && !doctor.getEmail().isBlank()) {

                String doctorName = doctor.getFirstName() + " " + doctor.getLastName();

                String schedule = request.dayOfWeek() +
                        " | " + request.startTime() + " - " + request.endTime() +
                        " | Slot: " + request.slotDurationMinutes() + " mins";

                notificationService.sendDoctorAvailabilityEmail(
                        doctor.getEmail(),
                        doctorName,
                        schedule
                );
            }
        } catch (Exception e) {
            // ❗ Do NOT break main flow due to email failure
            e.printStackTrace();
        }

        return new AvailabilityResponse(
                saved.getId(),
                saved.getDoctor().getId(),
                saved.getDayOfWeek(),
                saved.getStartTime(),
                saved.getEndTime(),
                saved.getSlotDurationMinutes()
        );
    }

    // ============================================
    // GET AVAILABILITY
    // ============================================
    @Override
    public List<AvailabilityResponse> getDoctorAvailability(Long doctorId) {

        return availabilityRepository.findByDoctorId(doctorId)
                .stream()
                .map(a -> new AvailabilityResponse(
                        a.getId(),
                        a.getDoctor().getId(),
                        a.getDayOfWeek(),
                        a.getStartTime(),
                        a.getEndTime(),
                        a.getSlotDurationMinutes()
                ))
                .toList();
    }
}