package com.hospital.management.auth.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public class LoginResponse {

    private String accessToken;
    private String refreshToken;
    private String role;
    private Long userId;

    private LoginEntityResponse entity; // 🔥 polymorphic payload
}