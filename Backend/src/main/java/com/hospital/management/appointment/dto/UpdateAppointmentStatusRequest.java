package com.hospital.management.appointment.dto;

import com.hospital.management.appointment.enums.AppointmentStatus;
import lombok.Data;

@Data
public class UpdateAppointmentStatusRequest {

    private AppointmentStatus status;
}