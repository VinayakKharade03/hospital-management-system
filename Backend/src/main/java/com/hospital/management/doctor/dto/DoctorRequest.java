package com.hospital.management.doctor.dto;

import jakarta.validation.constraints.*;
import lombok.Data;

@Data
public class DoctorRequest {

    @NotBlank(message = "First name is required")
    @Size(max = 50)
    private String firstName;

    @NotBlank(message = "Last name is required")
    @Size(max = 50)
    private String lastName;

    @NotBlank(message = "Email is required")
    @Email(message = "Invalid email format")
    @Size(max = 100)
    private String email;

    @NotBlank(message = "Password is required")
    @Size(min = 6)
    private String password;

    @NotBlank(message = "Specialization is required")
    @Size(max = 100)
    private String specialization;

    @NotNull(message = "Consultation fee is required")
    @Positive
    private Double consultationFee;

    @Pattern(regexp = "^[6-9]\\d{9}$",
            message = "Invalid Indian phone number")
    private String phone;
}