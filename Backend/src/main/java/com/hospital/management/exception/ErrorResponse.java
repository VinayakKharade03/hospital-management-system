package com.hospital.management.exception;

import lombok.Builder;
import lombok.Data;

import java.time.LocalDateTime;
import java.util.Map;

@Data
@Builder
public class ErrorResponse {

    private LocalDateTime timestamp;

    private int status;

    private String error;

    private String message;

    private String path;

    // 🔥 NEW (important)
    private String errorCode;

    // 🔥 NEW (for validation)
    private Map<String, String> validationErrors;
}