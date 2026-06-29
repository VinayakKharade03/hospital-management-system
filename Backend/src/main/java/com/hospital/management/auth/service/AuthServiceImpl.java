package com.hospital.management.auth.service;

import com.hospital.management.auth.dto.*;
import com.hospital.management.auth.entity.RefreshToken;
import com.hospital.management.doctor.entity.Doctor;
import com.hospital.management.doctor.repository.DoctorRepository;
import com.hospital.management.security.JwtBlacklistService;
import com.hospital.management.security.JwtTokenProvider;
import com.hospital.management.user.entity.Role;
import com.hospital.management.user.entity.User;
import com.hospital.management.user.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class AuthServiceImpl implements AuthService {

    private final UserRepository userRepository;
    private final DoctorRepository doctorRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtTokenProvider jwtTokenProvider;
    private final AuthenticationManager authenticationManager;
    private final RefreshTokenService refreshTokenService;
    private final JwtBlacklistService blacklistService;

    // ================= REGISTER =================
    @Override
    public String register(RegisterRequest request) {

        if (userRepository.existsByUsername(request.getUsername())) {
            throw new RuntimeException("Username already exists");
        }

        User user = new User();
        user.setUsername(request.getUsername());
        user.setPassword(passwordEncoder.encode(request.getPassword()));
        user.setRole(Role.valueOf(request.getRole()));

        userRepository.save(user);

        return "User registered successfully";
    }

    // ================= LOGIN =================
    @Override
    public LoginResponse login(LoginRequest request) {

        authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(
                        request.getUsername(),
                        request.getPassword()
                )
        );

        User user = userRepository.findByUsername(request.getUsername())
                .orElseThrow(() -> new RuntimeException("User not found"));

        String accessToken = jwtTokenProvider.generateToken(
                user.getUsername(),
                user.getRole().name()
        );

        RefreshToken refreshToken = refreshTokenService.createRefreshToken(user);

        LoginEntityResponse entity = null;

        if (user.getRole() == Role.DOCTOR) {

            Doctor doctor = doctorRepository.findByUser_Id(user.getId())
                    .orElseThrow(() -> new RuntimeException("Doctor not found"));

            entity = LoginEntityResponse.builder()
                    .id(doctor.getId())
                    .firstName(doctor.getFirstName())
                    .lastName(doctor.getLastName())
                    .email(doctor.getEmail())
                    .specialization(doctor.getSpecialization())
                    .consultationFee(doctor.getConsultationFee())
                    .phone(doctor.getPhone())
                    .build();
        }
        return new LoginResponse(
                accessToken,
                refreshToken.getToken(),
                user.getRole().name(),
                user.getId(),
                entity
        );
    }

    // ================= LOGOUT =================
    @Override
    public void logout(String token) {

        long expiry = jwtTokenProvider.getExpiration(token).getTime()
                - System.currentTimeMillis();

        blacklistService.blacklistToken(token, expiry);

        String username = jwtTokenProvider.getUsernameFromToken(token);

        User user = userRepository.findByUsername(username)
                .orElseThrow(() -> new RuntimeException("User not found"));

        refreshTokenService.deleteByUser(user);
    }
}