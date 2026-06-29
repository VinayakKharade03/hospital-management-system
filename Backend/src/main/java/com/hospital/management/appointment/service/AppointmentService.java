package com.hospital.management.appointment.service;

import com.hospital.management.appointment.dto.AppointmentRequest;
import com.hospital.management.appointment.dto.AppointmentResponse;
import com.hospital.management.appointment.dto.AvailableSlotsResponse;
import com.hospital.management.appointment.enums.AppointmentStatus;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

public interface AppointmentService {

    AppointmentResponse createAppointment(AppointmentRequest request);

    Page<AppointmentResponse> getAllAppointments(Pageable pageable);

    AppointmentResponse getAppointmentById(Long id);

    AppointmentResponse updateStatus(Long id, AppointmentStatus status);

    void deleteAppointment(Long id);
    List<String> getBookedSlots(Long doctorId, LocalDate date);

    Page<AppointmentResponse> getByDoctor(Long doctorId, Pageable pageable);

    Page<AppointmentResponse> getByPatient(Long patientId, Pageable pageable);

    Page<AppointmentResponse> getByDate(LocalDate date, Pageable pageable);

    AvailableSlotsResponse getAvailableSlots(Long doctorId, LocalDate date);

    AppointmentResponse rescheduleAppointment(Long id, LocalDateTime newTime);
}
