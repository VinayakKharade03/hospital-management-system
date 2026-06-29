package com.hospital.management.doctor.dto;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class DoctorResponse {

    private Long id;
    private String firstName;
    private String lastName;
    private String email;
    private String specialization;
    private Double consultationFee;
    private String phone;
}
