package com.hospital.management.appointment.dto;

import com.hospital.management.appointment.enums.AppointmentStatus;
import lombok.Builder;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@Builder
public class AppointmentResponse {

    private Long id;
    private Long patientId;
    private String patientName;

    private Long doctorId;
    private String doctorName;

    private LocalDateTime appointmentTime;
    private AppointmentStatus status;
    private String notes;
    private String doctorSpecialization;

    private Double consultationFee;

    private Boolean checkedIn;

    private Integer queueNumber;
}
