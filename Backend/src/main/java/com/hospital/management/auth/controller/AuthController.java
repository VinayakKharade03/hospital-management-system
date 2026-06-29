package com.hospital.management.auth.controller;

import com.hospital.management.auth.dto.LoginRequest;
import com.hospital.management.auth.dto.LoginResponse;
import com.hospital.management.auth.dto.RefreshTokenRequest;
import com.hospital.management.auth.dto.RegisterRequest;
import com.hospital.management.auth.service.AuthService;
import com.hospital.management.auth.service.RefreshTokenService;
import com.hospital.management.security.JwtTokenProvider;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
public class AuthController {

    private final AuthService authService;
    private final RefreshTokenService refreshTokenService;
    private final JwtTokenProvider jwtTokenProvider;

    // ================= REGISTER =================
    @PostMapping("/register")
    public String register(@RequestBody RegisterRequest request) {
        return authService.register(request);
    }

    // ================= LOGIN =================
    @PostMapping("/login")
    public LoginResponse login(@RequestBody LoginRequest request) {
        return authService.login(request);
    }

    // ================= REFRESH TOKEN =================
    @PostMapping("/refresh")
    public LoginResponse refresh(@RequestBody RefreshTokenRequest request) {

        var refreshToken =
                refreshTokenService.verifyRefreshToken(
                        request.getRefreshToken()
                );

        String newAccessToken = jwtTokenProvider.generateToken(
                refreshToken.getUser().getUsername(),
                refreshToken.getUser().getRole().name()
        );

        // 🔥 FIX: entity is not available in refresh, so pass null
        return new LoginResponse(
                newAccessToken,
                refreshToken.getToken(),
                refreshToken.getUser().getRole().name(),
                refreshToken.getUser().getId(),
                null
        );
    }

    // ================= LOGOUT =================
    @PostMapping("/logout")
    public String logout(
            @RequestBody RefreshTokenRequest request
    ) {

        refreshTokenService.deleteByToken(
                request.getRefreshToken()
        );

        return "Logged out successfully";
    }
}