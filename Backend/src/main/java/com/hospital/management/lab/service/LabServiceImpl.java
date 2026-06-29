package com.hospital.management.lab.service;

import com.hospital.management.billing.service.InvoiceService;
import com.hospital.management.lab.dto.LabResultFormResponse;
import com.hospital.management.lab.dto.LabResultParameterDto;
import com.hospital.management.lab.dto.LabResultValueUpdateRequest;
import com.hospital.management.lab.dto.LabTestOrderResponse;
import com.hospital.management.lab.entity.*;
import com.hospital.management.lab.enums.LabTestStatus;
import com.hospital.management.lab.repository.*;
import com.hospital.management.notification.service.NotificationService;
import com.hospital.management.visit.entity.Visit;
import com.hospital.management.visit.repository.VisitRepository;
import com.hospital.management.lab.dto.LabTestResponse;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.io.File;
import java.io.FileOutputStream;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Transactional
public class LabServiceImpl implements LabService {

    private final LabTestRepository labTestRepository;
    private final LabTestOrderRepository labTestOrderRepository;
    private final LabResultParameterRepository parameterRepository;
    private final LabTestParameterRepository parameterTemplateRepository;
    private final VisitRepository visitRepository;
    private final InvoiceService invoiceService;
    private final LabReportService labReportService;
    private final NotificationService notificationService;

    @Override
    public LabTestOrderResponse orderTest(String doctorEmail, Long visitId, Long testId) {

        Visit visit = visitRepository.findById(visitId)
                .orElseThrow(() -> new RuntimeException("Visit not found"));

        LabTest test = labTestRepository.findById(testId)
                .orElseThrow(() -> new RuntimeException("Test not found"));

        LabTestOrder order = new LabTestOrder();
        order.setVisit(visit);
        order.setTest(test);
        order.setStatus(LabTestStatus.ORDERED);

        LabTestOrder saved = labTestOrderRepository.save(order);

        List<LabTestParameter> templates =
                parameterTemplateRepository.findByLabTestId(testId);

        List<LabResultParameter> parameters = templates.stream()
                .map(t -> {
                    LabResultParameter p = new LabResultParameter();
                    p.setParameterName(t.getParameterName());
                    p.setUnit(t.getUnit());
                    p.setNormalRange(t.getNormalRange());
                    p.setOrder(saved);
                    return p;
                }).toList();

        parameterRepository.saveAll(parameters);

        Long invoiceId = invoiceService
                .getOrCreateByVisit(visit.getId())
                .getId();

        invoiceService.addServiceItem(
                invoiceId,
                test.getName(),
                1,
                test.getPrice()
        );

        return mapToResponse(saved);
    }

    // 🔥 NEW: returns the order header + its already-saved parameter rows,
    // ready to be rendered as the "Add Lab Result" form
    @Override
    @Transactional(readOnly = true)
    public LabResultFormResponse getResultForm(Long orderId) {

        LabTestOrder order = labTestOrderRepository.findFullOrder(orderId)
                .orElseThrow(() -> new RuntimeException("Order not found"));

        List<LabResultParameter> params = parameterRepository.findByOrderId(orderId);

        List<LabResultParameterDto> paramDtos = params.stream()
                .map(p -> new LabResultParameterDto(
                        p.getId(),
                        p.getParameterName(),
                        p.getValue(),
                        p.getUnit(),
                        p.getNormalRange()))
                .toList();

        Visit visit = order.getVisit();
        String patientName = "Unknown Patient";
        String doctorName = "Unknown Doctor";

        if (visit != null) {
            if (visit.getPatient() != null) {
                patientName = visit.getPatient().getFirstName() + " " + visit.getPatient().getLastName();
            }
            if (visit.getDoctor() != null) {
                doctorName = visit.getDoctor().getFirstName() + " " + visit.getDoctor().getLastName();
            }
        }

        String testName = (order.getTest() != null) ? order.getTest().getName() : "Unknown Test";
        String status = (order.getStatus() != null) ? order.getStatus().name() : "PENDING";

        return new LabResultFormResponse(
                order.getId(),
                testName,
                patientName,
                doctorName,
                status,
                paramDtos
        );
    }

    // 🔥 UPDATED: matches by parameterId instead of by name
    @Override
    public LabTestOrder addResult(Long orderId, List<LabResultValueUpdateRequest> results) {

        LabTestOrder order = labTestOrderRepository.findById(orderId)
                .orElseThrow(() -> new RuntimeException("Order not found"));

        List<LabResultParameter> existing =
                parameterRepository.findByOrderId(orderId);

        Map<Long, LabResultParameter> map = existing.stream()
                .collect(Collectors.toMap(LabResultParameter::getId, p -> p));

        for (LabResultValueUpdateRequest input : results) {
            LabResultParameter db = map.get(input.getParameterId());
            if (db != null) {
                db.setValue(input.getValue());
            }
        }

        parameterRepository.saveAll(existing);

        order.setStatus(LabTestStatus.COMPLETED);
        LabTestOrder savedOrder = labTestOrderRepository.save(order);

        byte[] pdfBytes = labReportService.generateReport(savedOrder);

        String filePath = System.getProperty("java.io.tmpdir")
                + "/Lab_Report_" + savedOrder.getId() + ".pdf";
        // 🔧 FIX: FileOutputStream does NOT create missing parent directories.
        // If C:\hospital-pdfs doesn't exist yet, opening the stream throws
        // FileNotFoundException, which was being wrapped as "Failed to save PDF".
        File pdfFile = new File(filePath);
        File parentDir = pdfFile.getParentFile();
        if (parentDir != null && !parentDir.exists()) {
            boolean created = parentDir.mkdirs();
            if (!created && !parentDir.exists()) {
                throw new RuntimeException("Failed to create PDF storage directory: " + parentDir.getAbsolutePath());
            }
        }

        try (FileOutputStream fos = new FileOutputStream(pdfFile)) {
            fos.write(pdfBytes);
        } catch (Exception e) {
            throw new RuntimeException("Failed to save PDF", e);
        }

        String email = savedOrder.getVisit().getPatient().getEmail();
        String name = savedOrder.getVisit().getPatient().getFirstName();

        if (email != null && !email.isBlank()) {
            try {
                notificationService.sendLabReportEmail(email, name, filePath);
            } catch (Exception e) {
                e.printStackTrace();
            }
        }

        return savedOrder;
    }

    @Override
    public byte[] generateReport(Long orderId) {
        LabTestOrder order = labTestOrderRepository
                .findFullOrder(orderId)
                .orElseThrow(() -> new RuntimeException("Order not found"));

        return labReportService.generateReport(order);
    }

    @Override
    public List<LabTestOrderResponse> getPatientReports(Long patientId) {
        return labTestOrderRepository
                .findByVisitPatientId(patientId)
                .stream()
                .map(this::mapToResponse)
                .toList();
    }

    @Override
    public List<LabTestOrderResponse> getAllOrders() {
        return labTestOrderRepository
                .findAll()
                .stream()
                .map(this::mapToResponse)
                .toList();
    }

    private LabTestOrderResponse mapToResponse(LabTestOrder order) {
        Visit visit = order.getVisit();
        LabTest test = order.getTest();

        String patientName = "Unknown Patient";
        String doctorName = "Unknown Doctor";

        if (visit != null) {
            if (visit.getPatient() != null) {
                patientName = visit.getPatient().getFirstName() + " " + visit.getPatient().getLastName();
            }
            if (visit.getDoctor() != null) {
                doctorName = visit.getDoctor().getFirstName() + " " + visit.getDoctor().getLastName();
            }
        }

        String testName = (test != null) ? test.getName() : "Unknown Test";
        String status = (order.getStatus() != null) ? order.getStatus().name() : "PENDING";

        return new LabTestOrderResponse(
                order.getId(),
                patientName,
                doctorName,
                testName,
                status,
                order.getOrderedAt()
        );
    }
    @Override
    @Transactional(readOnly = true)
    public List<LabTestResponse> getAvailableTests() {
        return labTestRepository.findAll().stream()
                .map(test -> new LabTestResponse(test.getId(), test.getName()))
                .collect(Collectors.toList());
    }
}