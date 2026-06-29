package com.hospital.management.lab.service;

import com.hospital.management.lab.dto.LabResultFormResponse;
import com.hospital.management.lab.dto.LabResultValueUpdateRequest;
import com.hospital.management.lab.dto.LabTestOrderResponse;
import com.hospital.management.lab.dto.LabTestResponse;
import com.hospital.management.lab.entity.LabTestOrder;

import java.util.List;

public interface LabService {

    LabTestOrderResponse orderTest(
            String doctorEmail,
            Long visitId,
            Long testId
    );

    // 🔥 NEW: fetch the pre-populated parameter template for this order
    LabResultFormResponse getResultForm(Long orderId);

    LabTestOrder addResult(Long orderId, List<LabResultValueUpdateRequest> results);

    byte[] generateReport(Long orderId);

    List<LabTestOrderResponse> getPatientReports(Long patientId);

    List<LabTestOrderResponse> getAllOrders();

    List<LabTestResponse> getAvailableTests();
}