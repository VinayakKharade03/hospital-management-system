package com.hospital.management.doctor.service;

import com.hospital.management.doctor.dto.AvailabilityRequest;
import com.hospital.management.doctor.dto.AvailabilityResponse;

import java.util.List;

public interface DoctorAvailabilityService {

    AvailabilityResponse addAvailability(Long doctorId, AvailabilityRequest request);

    List<AvailabilityResponse> getDoctorAvailability(Long doctorId);
}