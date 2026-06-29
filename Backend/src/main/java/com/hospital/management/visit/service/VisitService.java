package com.hospital.management.visit.service;

import com.hospital.management.visit.dto.VisitRequest;
import com.hospital.management.visit.dto.VisitResponse;

import java.util.List;

public interface VisitService {

    VisitResponse checkIn(VisitRequest request);

    VisitResponse getVisit(Long id);

    List<VisitResponse> getPatientVisits(Long patientId);

    VisitResponse getVisitByAppointmentId(Long appointmentId);   // ADD THIS LINE
}