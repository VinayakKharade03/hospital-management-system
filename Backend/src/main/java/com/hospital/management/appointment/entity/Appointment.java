package com.hospital.management.appointment.entity;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.hospital.management.appointment.enums.AppointmentStatus;
import com.hospital.management.doctor.entity.Doctor;
import com.hospital.management.patient.entity.Patient;
import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;

@Entity
@Table(
        name = "appointments",
        uniqueConstraints = {
                @UniqueConstraint(
                        name = "uk_doctor_time",
                        columnNames = {"doctor_id", "appointment_time"}
                )
        },
        indexes = {
                @Index(name = "idx_appointment_time", columnList = "appointment_time"),
                @Index(name = "idx_doctor_id", columnList = "doctor_id"),
                @Index(name = "idx_patient_id", columnList = "patient_id")
        }
)
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
@JsonIgnoreProperties({"hibernateLazyInitializer", "handler"})
public class Appointment {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    // Many appointments can belong to one patient
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "patient_id", nullable = false)
    @JsonIgnoreProperties({"appointments"})
    private Patient patient;

    // Many appointments can belong to one doctor
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "doctor_id", nullable = false)
    @JsonIgnoreProperties({"appointments"})
    private Doctor doctor;

    @Column(nullable = false)
    private LocalDateTime appointmentTime;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private AppointmentStatus status;

    @Column(length = 1000)
    private String notes;
}