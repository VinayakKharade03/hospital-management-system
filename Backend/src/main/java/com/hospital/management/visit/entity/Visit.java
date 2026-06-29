package com.hospital.management.visit.entity;

import com.hospital.management.patient.entity.Patient;
import com.hospital.management.doctor.entity.Doctor;
import com.hospital.management.appointment.entity.Appointment;
import com.hospital.management.visit.enums.VisitStatus;

import jakarta.persistence.*;

import java.time.LocalDateTime;

@Entity
@Table(name = "visits")
public class Visit {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "patient_id")
    private Patient patient;

    @ManyToOne
    @JoinColumn(name = "doctor_id")
    private Doctor doctor;

    @OneToOne
    @JoinColumn(name = "appointment_id")
    private Appointment appointment;

    private LocalDateTime checkInTime;

    // ✅ ENUM INSTEAD OF STRING
    @Enumerated(EnumType.STRING)
    private VisitStatus status;

    public Visit() {}

    public Visit(Patient patient,
                 Doctor doctor,
                 Appointment appointment,
                 LocalDateTime checkInTime,
                 VisitStatus status) {
        this.patient = patient;
        this.doctor = doctor;
        this.appointment = appointment;
        this.checkInTime = checkInTime;
        this.status = status;
    }

    public Long getId() { return id; }

    public Patient getPatient() { return patient; }
    public void setPatient(Patient patient) { this.patient = patient; }

    public Doctor getDoctor() { return doctor; }
    public void setDoctor(Doctor doctor) { this.doctor = doctor; }

    public Appointment getAppointment() { return appointment; }
    public void setAppointment(Appointment appointment) { this.appointment = appointment; }

    public LocalDateTime getCheckInTime() { return checkInTime; }
    public void setCheckInTime(LocalDateTime checkInTime) { this.checkInTime = checkInTime; }

    public VisitStatus getStatus() { return status; }
    public void setStatus(VisitStatus status) { this.status = status; }
}