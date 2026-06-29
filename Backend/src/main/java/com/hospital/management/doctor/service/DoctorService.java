package com.hospital.management.doctor.service;

import com.hospital.management.doctor.dto.DoctorRequest;
import com.hospital.management.doctor.dto.DoctorResponse;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

public interface DoctorService {

    DoctorResponse createDoctor(DoctorRequest request);

    Page<DoctorResponse> getAllDoctors(Pageable pageable);

    DoctorResponse getDoctorById(Long id);

    DoctorResponse updateDoctor(Long id, DoctorRequest request);

    void deleteDoctor(Long id);
}
