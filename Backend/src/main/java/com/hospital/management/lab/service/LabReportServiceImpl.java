package com.hospital.management.lab.service;

import com.hospital.management.lab.entity.LabResultParameter;
import com.hospital.management.lab.entity.LabTestOrder;
import com.hospital.management.lab.repository.LabResultParameterRepository;

import com.itextpdf.kernel.colors.DeviceRgb;
import com.itextpdf.kernel.geom.PageSize;
import com.itextpdf.kernel.pdf.PdfDocument;
import com.itextpdf.kernel.pdf.PdfWriter;
import com.itextpdf.layout.Document;
import com.itextpdf.layout.borders.Border;
import com.itextpdf.layout.borders.SolidBorder;
import com.itextpdf.layout.element.Cell;
import com.itextpdf.layout.element.Paragraph;
import com.itextpdf.layout.element.Table;
import com.itextpdf.layout.properties.TextAlignment;
import com.itextpdf.layout.properties.UnitValue;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.io.ByteArrayOutputStream;
import java.time.format.DateTimeFormatter;
import java.util.List;

@Service
@RequiredArgsConstructor
public class LabReportServiceImpl implements LabReportService {

    // ── Brand colours (matches BillingPdfServiceImpl) ─────────────────────────
    private static final DeviceRgb BRAND_BLUE  = new DeviceRgb(0,   102, 179);
    private static final DeviceRgb BRAND_LIGHT = new DeviceRgb(230, 243, 255);
    private static final DeviceRgb HEADER_GRAY = new DeviceRgb(60,  60,  60);
    private static final DeviceRgb ROW_ALT     = new DeviceRgb(245, 249, 253);
    private static final DeviceRgb DIVIDER     = new DeviceRgb(200, 215, 230);
    private static final DeviceRgb TEXT_DARK   = new DeviceRgb(30,  30,  30);
    private static final DeviceRgb WHITE       = new DeviceRgb(255, 255, 255);
    private static final DeviceRgb RED         = new DeviceRgb(200, 0,   0);
    private static final DeviceRgb GREEN       = new DeviceRgb(0,   140, 70);

    private final LabResultParameterRepository parameterRepository;

    @Override
    public byte[] generateReport(LabTestOrder order) {
        try {
            ByteArrayOutputStream out = new ByteArrayOutputStream();

            PdfWriter   writer = new PdfWriter(out);
            PdfDocument pdf    = new PdfDocument(writer);
            Document    doc    = new Document(pdf, PageSize.A4);
            doc.setMargins(36, 50, 36, 50);

            // ── HEADER BAR ────────────────────────────────────────────────────
            Table headerBar = new Table(UnitValue.createPercentArray(new float[]{1}))
                    .useAllAvailableWidth()
                    .setBackgroundColor(BRAND_BLUE);

            headerBar.addCell(new Cell()
                    .setBorder(Border.NO_BORDER)
                    .setPadding(14)
                    .add(new Paragraph("CareConnect Hospital")
                            .setFontSize(22).setBold()
                            .setFontColor(WHITE)
                            .setTextAlignment(TextAlignment.CENTER))
                    .add(new Paragraph("Laboratory Report")
                            .setFontSize(11)
                            .setFontColor(WHITE)
                            .setTextAlignment(TextAlignment.CENTER)));

            doc.add(headerBar);
            doc.add(spacer(8));

            // ── META SECTION ──────────────────────────────────────────────────
            String patientName = order.getVisit().getPatient().getFirstName()
                    + " " + order.getVisit().getPatient().getLastName();

            String doctorName = "Dr. "
                    + order.getVisit().getDoctor().getFirstName()
                    + " " + order.getVisit().getDoctor().getLastName();

            String testName  = order.getTest().getName();
            String status    = order.getStatus() != null ? order.getStatus().name() : "—";
            String orderedAt = order.getOrderedAt() != null
                    ? order.getOrderedAt().format(DateTimeFormatter.ofPattern("dd MMM yyyy, hh:mm a"))
                    : "—";

            Table meta = new Table(UnitValue.createPercentArray(new float[]{1, 1}))
                    .useAllAvailableWidth()
                    .setBackgroundColor(BRAND_LIGHT)
                    .setBorder(new SolidBorder(DIVIDER, 0.5f));

            meta.addCell(metaCell("Patient",    patientName, true));
            meta.addCell(metaCell("Doctor",     doctorName,  true));
            meta.addCell(metaCell("Test",       testName,    false));
            meta.addCell(metaCell("Ordered At", orderedAt,   false));

            // Full-width status row
            meta.addCell(new Cell(1, 2)
                    .setBorder(Border.NO_BORDER)
                    .setPaddingLeft(10).setPaddingBottom(10).setPaddingTop(4)
                    .add(new Paragraph("Status")
                            .setFontSize(8).setFontColor(HEADER_GRAY).setMarginBottom(2))
                    .add(new Paragraph(status)
                            .setFontSize(10).setBold().setFontColor(TEXT_DARK)));

            doc.add(meta);
            doc.add(spacer(14));

            // ── RESULTS TABLE ─────────────────────────────────────────────────
            List<LabResultParameter> params = parameterRepository.findByOrderId(order.getId());

            Table table = new Table(UnitValue.createPercentArray(new float[]{3f, 2f, 1.2f, 2f}))
                    .useAllAvailableWidth();

            String[] headers = {"Parameter", "Value", "Unit", "Normal Range"};
            TextAlignment[] aligns = {
                    TextAlignment.LEFT,
                    TextAlignment.CENTER,
                    TextAlignment.CENTER,
                    TextAlignment.CENTER
            };

            for (int i = 0; i < headers.length; i++) {
                table.addHeaderCell(new Cell()
                        .setBackgroundColor(BRAND_BLUE)
                        .setBorder(Border.NO_BORDER)
                        .setPaddingTop(8).setPaddingBottom(8)
                        .setPaddingLeft(6).setPaddingRight(6)
                        .add(new Paragraph(headers[i])
                                .setBold().setFontSize(10)
                                .setFontColor(WHITE)
                                .setTextAlignment(aligns[i])));
            }

            boolean odd = true;

            for (LabResultParameter p : params) {
                DeviceRgb rowBg = odd ? WHITE : ROW_ALT;
                odd = !odd;

                // Parameter name
                table.addCell(itemCell(p.getParameterName(), rowBg, TextAlignment.LEFT, false, TEXT_DARK));

                // Value — colour-coded normal/abnormal/pending
                String    displayValue = "Pending";
                boolean   abnormal     = false;
                DeviceRgb valueColor   = HEADER_GRAY;

                if (p.getValue() != null && !p.getValue().isBlank()) {
                    displayValue = p.getValue();
                    valueColor   = GREEN;

                    if (p.getNormalRange() != null && p.getNormalRange().contains("-")) {
                        try {
                            String[] range = p.getNormalRange().split("-");
                            double val = Double.parseDouble(p.getValue().trim());
                            double min = Double.parseDouble(range[0].trim());
                            double max = Double.parseDouble(range[1].trim());

                            if (val < min || val > max) {
                                abnormal     = true;
                                valueColor   = RED;
                                displayValue = p.getValue() + " (!)";
                            }
                        } catch (Exception ignored) {
                            // Non-numeric value — just display as-is
                        }
                    }
                }

                table.addCell(itemCell(displayValue, rowBg, TextAlignment.CENTER, abnormal, valueColor));
                table.addCell(itemCell(p.getUnit()        != null ? p.getUnit()        : "—", rowBg, TextAlignment.CENTER, false, TEXT_DARK));
                table.addCell(itemCell(p.getNormalRange() != null ? p.getNormalRange() : "—", rowBg, TextAlignment.CENTER, false, TEXT_DARK));
            }

            if (params.isEmpty()) {
                table.addCell(new Cell(1, 4)
                        .setBorder(Border.NO_BORDER)
                        .setPadding(14)
                        .add(new Paragraph("No parameters recorded yet.")
                                .setFontSize(10).setFontColor(HEADER_GRAY)
                                .setTextAlignment(TextAlignment.CENTER)));
            }

            doc.add(table);

            // ── LEGEND ────────────────────────────────────────────────────────
            doc.add(spacer(10));
            doc.add(new Paragraph("(!) = Value outside normal range")
                    .setFontSize(8).setFontColor(RED)
                    .setTextAlignment(TextAlignment.LEFT));

            // ── FOOTER ────────────────────────────────────────────────────────
            doc.add(spacer(20));
            doc.add(new Paragraph("─────────────────────────────────────────────────────────")
                    .setFontColor(DIVIDER).setFontSize(8));
            doc.add(new Paragraph("This report is generated by CareConnect Hospital. "
                    + "For queries contact lab@careconnect.in")
                    .setFontSize(9).setFontColor(HEADER_GRAY)
                    .setTextAlignment(TextAlignment.CENTER));

            doc.close();
            return out.toByteArray();

        } catch (Exception e) {
            e.printStackTrace();
            throw new RuntimeException("Lab PDF generation failed: " + e.getMessage());
        }
    }

    // ── Helpers ───────────────────────────────────────────────────────────────

    private static Paragraph spacer(float height) {
        return new Paragraph(" ").setFontSize(height / 2f).setMargin(0);
    }

    private static Cell metaCell(String label, String value, boolean topRow) {
        return new Cell()
                .setBorder(Border.NO_BORDER)
                .setPaddingTop(topRow ? 10 : 4)
                .setPaddingBottom(topRow ? 4 : 6)
                .setPaddingLeft(10).setPaddingRight(10)
                .add(new Paragraph(label)
                        .setFontSize(8).setFontColor(HEADER_GRAY).setMarginBottom(2))
                .add(new Paragraph(value)
                        .setFontSize(10).setBold().setFontColor(TEXT_DARK));
    }

    private static Cell itemCell(String text, DeviceRgb bg,
                                 TextAlignment align, boolean bold, DeviceRgb color) {
        Paragraph p = new Paragraph(text)
                .setFontSize(9.5f).setFontColor(color).setTextAlignment(align);
        if (bold) p.setBold();
        return new Cell()
                .setBackgroundColor(bg)
                .setBorderLeft(Border.NO_BORDER).setBorderRight(Border.NO_BORDER)
                .setBorderTop(new SolidBorder(DIVIDER, 0.3f)).setBorderBottom(Border.NO_BORDER)
                .setPaddingTop(7).setPaddingBottom(7)
                .setPaddingLeft(6).setPaddingRight(6)
                .add(p);
    }
}