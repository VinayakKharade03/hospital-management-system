package com.hospital.management.auth.service;

import com.hospital.management.auth.entity.RefreshToken;
import com.hospital.management.user.entity.User;

public interface RefreshTokenService {

    RefreshToken createRefreshToken(User user);

    RefreshToken verifyRefreshToken(String token);

    void deleteByUser(User user);

    // 🔥 ADD THIS
    void deleteByToken(String token);
}