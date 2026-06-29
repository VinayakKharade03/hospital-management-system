package com.hospital.management.doctor.service;

import com.hospital.management.doctor.dto.DoctorRequest;
import com.hospital.management.doctor.dto.DoctorResponse;
import com.hospital.management.doctor.entity.Doctor;
import com.hospital.management.doctor.repository.DoctorRepository;
import com.hospital.management.exception.ConflictException;
import com.hospital.management.exception.ResourceNotFoundException;
import com.hospital.management.user.entity.Role;
import com.hospital.management.user.entity.User;
import com.hospital.management.user.repository.UserRepository;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
@Transactional
@Slf4j
public class DoctorServiceImpl implements DoctorService {

    private final DoctorRepository doctorRepository;
    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;

    @Override
    public DoctorResponse createDoctor(DoctorRequest request) {

        log.info("Creating doctor with email: {}", request.getEmail());

        if (doctorRepository.existsByEmail(request.getEmail())) {
            throw new ConflictException("Email already exists: " + request.getEmail());
        }

        if (userRepository.existsByUsername(request.getEmail())) {
            throw new ConflictException("User already exists with email: " + request.getEmail());
        }

        if (request.getPhone() != null &&
                doctorRepository.existsByPhone(request.getPhone())) {
            throw new ConflictException("Phone already exists: " + request.getPhone());
        }

        // Create login account
        User user = new User();
        user.setUsername(request.getEmail()); // email used as login id
        user.setPassword(passwordEncoder.encode(request.getPassword()));
        user.setRole(Role.DOCTOR);

        userRepository.save(user);

        // Create doctor profile
        Doctor doctor = Doctor.builder()
                .firstName(request.getFirstName())
                .lastName(request.getLastName())
                .email(request.getEmail())
                .specialization(request.getSpecialization())
                .consultationFee(request.getConsultationFee())
                .phone(request.getPhone())
                .build();

        return mapToResponse(doctorRepository.save(doctor));
    }

    @Override
    @Transactional(readOnly = true)
    public Page<DoctorResponse> getAllDoctors(Pageable pageable) {

        log.info("Fetching doctors page: {}", pageable.getPageNumber());

        return doctorRepository.findAll(pageable)
                .map(this::mapToResponse);
    }

    @Override
    @Transactional(readOnly = true)
    public DoctorResponse getDoctorById(Long id) {

        Doctor doctor = doctorRepository.findById(id)
                .orElseThrow(() ->
                        new ResourceNotFoundException("Doctor not found with id: " + id));

        return mapToResponse(doctor);
    }

    @Override
    public DoctorResponse updateDoctor(Long id, DoctorRequest request) {

        Doctor doctor = doctorRepository.findById(id)
                .orElseThrow(() ->
                        new ResourceNotFoundException("Doctor not found with id: " + id));

        if (!doctor.getEmail().equals(request.getEmail()) &&
                doctorRepository.existsByEmail(request.getEmail())) {
            throw new ConflictException("Email already exists: " + request.getEmail());
        }

        if (request.getPhone() != null &&
                !request.getPhone().equals(doctor.getPhone()) &&
                doctorRepository.existsByPhone(request.getPhone())) {
            throw new ConflictException("Phone already exists: " + request.getPhone());
        }

        doctor.setFirstName(request.getFirstName());
        doctor.setLastName(request.getLastName());
        doctor.setEmail(request.getEmail());
        doctor.setSpecialization(request.getSpecialization());
        doctor.setConsultationFee(request.getConsultationFee());
        doctor.setPhone(request.getPhone());

        return mapToResponse(doctorRepository.save(doctor));
    }

    @Override
    public void deleteDoctor(Long id) {

        if (!doctorRepository.existsById(id)) {
            throw new ResourceNotFoundException("Doctor not found with id: " + id);
        }

        doctorRepository.deleteById(id);
    }

    private DoctorResponse mapToResponse(Doctor doctor) {
        return DoctorResponse.builder()
                .id(doctor.getId())
                .firstName(doctor.getFirstName())
                .lastName(doctor.getLastName())
                .email(doctor.getEmail())
                .specialization(doctor.getSpecialization())
                .consultationFee(doctor.getConsultationFee())
                .phone(doctor.getPhone())
                .build();
    }
}