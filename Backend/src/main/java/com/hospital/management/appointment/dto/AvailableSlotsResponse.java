package com.hospital.management.appointment.dto;

import lombok.Builder;
import lombok.Data;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;

@Data
@Builder
public class AvailableSlotsResponse {

    private Long doctorId;
    private LocalDate date;
    private List<LocalTime> availableSlots;
}