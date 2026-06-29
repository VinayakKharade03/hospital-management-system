package com.hospital.management.auth.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class LoginEntityResponse {

    private Long id;
    private String firstName;
    private String lastName;
    private String email;
    private String specialization;
    private Double consultationFee;
    private String phone;
}