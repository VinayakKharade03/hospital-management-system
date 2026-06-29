package com.hospital.management.auth.service;

import com.hospital.management.auth.dto.*;

public interface AuthService {

    LoginResponse login(LoginRequest request);

    String register(RegisterRequest request);

    void logout(String token);

}
