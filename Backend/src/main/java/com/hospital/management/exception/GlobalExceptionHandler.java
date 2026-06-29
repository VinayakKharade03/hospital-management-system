package com.hospital.management.exception;

import jakarta.servlet.http.HttpServletRequest;
import lombok.extern.slf4j.Slf4j;

import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.FieldError;

import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.method.annotation.MethodArgumentTypeMismatchException;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;

@RestControllerAdvice
@Slf4j
public class GlobalExceptionHandler {

    // =========================
    // 404
    // =========================
    @ExceptionHandler(ResourceNotFoundException.class)
    public ResponseEntity<ErrorResponse> handleNotFound(
            ResourceNotFoundException ex,
            HttpServletRequest request) {

        log.warn("Resource not found: {}", ex.getMessage());

        return buildResponse(
                ex.getMessage(),
                "RESOURCE_NOT_FOUND",
                HttpStatus.NOT_FOUND,
                request,
                null
        );
    }

    // =========================
    // 400
    // =========================
    @ExceptionHandler(BadRequestException.class)
    public ResponseEntity<ErrorResponse> handleBadRequest(
            BadRequestException ex,
            HttpServletRequest request) {

        log.warn("Bad request: {}", ex.getMessage());

        return buildResponse(
                ex.getMessage(),
                "BAD_REQUEST",
                HttpStatus.BAD_REQUEST,
                request,
                null
        );
    }

    // =========================
    // 409
    // =========================
    @ExceptionHandler(ConflictException.class)
    public ResponseEntity<ErrorResponse> handleConflict(
            ConflictException ex,
            HttpServletRequest request) {

        log.warn("Conflict: {}", ex.getMessage());

        return buildResponse(
                ex.getMessage(),
                "CONFLICT",
                HttpStatus.CONFLICT,
                request,
                null
        );
    }

    // =========================
    // DB ERROR
    // =========================
    @ExceptionHandler(DataIntegrityViolationException.class)
    public ResponseEntity<ErrorResponse> handleDB(
            DataIntegrityViolationException ex,
            HttpServletRequest request) {

        log.error("DB Error: {}", ex.getMessage());

        return buildResponse(
                "Database constraint violation",
                "DATABASE_ERROR",
                HttpStatus.CONFLICT,
                request,
                null
        );
    }

    // =========================
    // VALIDATION ERROR
    // =========================
    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<ErrorResponse> handleValidation(
            MethodArgumentNotValidException ex,
            HttpServletRequest request) {

        Map<String, String> errors = new HashMap<>();

        for (FieldError error : ex.getBindingResult().getFieldErrors()) {
            errors.put(error.getField(), error.getDefaultMessage());
        }

        log.warn("Validation failed: {}", errors);

        return buildResponse(
                "Validation failed",
                "VALIDATION_ERROR",
                HttpStatus.BAD_REQUEST,
                request,
                errors
        );
    }

    // =========================
    // TYPE ERROR
    // =========================
    @ExceptionHandler(MethodArgumentTypeMismatchException.class)
    public ResponseEntity<ErrorResponse> handleTypeMismatch(
            MethodArgumentTypeMismatchException ex,
            HttpServletRequest request) {

        String message = "Invalid value for: " + ex.getName();

        log.warn("Type mismatch: {}", message);

        return buildResponse(
                message,
                "TYPE_MISMATCH",
                HttpStatus.BAD_REQUEST,
                request,
                null
        );
    }

    // =========================
    // GENERIC
    // =========================
    @ExceptionHandler(Exception.class)
    public ResponseEntity<ErrorResponse> handleGeneric(
            Exception ex,
            HttpServletRequest request) {

        log.error("Unexpected error", ex);

        return buildResponse(
                "Something went wrong",
                "INTERNAL_ERROR",
                HttpStatus.INTERNAL_SERVER_ERROR,
                request,
                null
        );
    }

    // =========================
    // BUILDER
    // =========================
    private ResponseEntity<ErrorResponse> buildResponse(
            String message,
            String errorCode,
            HttpStatus status,
            HttpServletRequest request,
            Map<String, String> validationErrors) {

        ErrorResponse response = ErrorResponse.builder()
                .timestamp(LocalDateTime.now())
                .status(status.value())
                .error(status.getReasonPhrase())
                .message(message)
                .errorCode(errorCode)
                .path(request.getRequestURI())
                .validationErrors(validationErrors)
                .build();

        return new ResponseEntity<>(response, status);
    }
}