package com.hospital.management.auth.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public class RefreshTokenResponse {

    private String accessToken;

    // ✅ ADD THESE
    private String role;

    private Long userId;
}