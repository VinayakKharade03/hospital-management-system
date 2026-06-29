package com.hospital.management.lab.service;

import com.hospital.management.lab.entity.LabTestOrder;

public interface LabReportService {

    byte[] generateReport(LabTestOrder order);

}