package com.hospital.management.auth.dto;

import lombok.*;

@Getter
@Setter
public class LoginRequest {
    private String username;
    private String password;
}
