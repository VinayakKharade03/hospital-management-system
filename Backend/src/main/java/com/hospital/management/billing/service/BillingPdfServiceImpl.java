package com.hospital.management.billing.service;

import com.hospital.management.billing.entity.Invoice;
import com.hospital.management.billing.entity.InvoiceItem;
import com.hospital.management.billing.repository.InvoiceRepository;

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

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.io.ByteArrayOutputStream;
import java.time.format.DateTimeFormatter;

@Service
public class BillingPdfServiceImpl implements BillingPdfService {

    // ── Brand colours ─────────────────────────────────────────────────────────
    private static final DeviceRgb BRAND_BLUE  = new DeviceRgb(0,   102, 179);
    private static final DeviceRgb BRAND_LIGHT = new DeviceRgb(230, 243, 255);
    private static final DeviceRgb HEADER_GRAY = new DeviceRgb(60,  60,  60);
    private static final DeviceRgb ROW_ALT     = new DeviceRgb(245, 249, 253);
    private static final DeviceRgb DIVIDER     = new DeviceRgb(200, 215, 230);
    private static final DeviceRgb TEXT_DARK   = new DeviceRgb(30,  30,  30);
    private static final DeviceRgb WHITE       = new DeviceRgb(255, 255, 255);

    private final InvoiceRepository invoiceRepository;

    public BillingPdfServiceImpl(InvoiceRepository invoiceRepository) {
        this.invoiceRepository = invoiceRepository;
    }

    @Override
    @Transactional(readOnly = true)
    public byte[] generateInvoicePdf(Long invoiceId) {
        try {
            Invoice invoice = invoiceRepository.findFullInvoice(invoiceId)
                    .orElseThrow(() -> new RuntimeException("Invoice not found: " + invoiceId));

            ByteArrayOutputStream out = new ByteArrayOutputStream();

            PdfWriter   writer = new PdfWriter(out);
            PdfDocument pdf    = new PdfDocument(writer);
            Document    doc    = new Document(pdf, PageSize.A4);
            doc.setMargins(36, 50, 36, 50);

            // ── HEADER BAR ────────────────────────────────────────────────────
            Table headerBar = new Table(UnitValue.createPercentArray(new float[]{1}))
                    .useAllAvailableWidth()
                    .setBackgroundColor(BRAND_BLUE);

            Cell brandCell = new Cell()
                    .setBorder(Border.NO_BORDER)
                    .setPadding(14)
                    .add(new Paragraph("CareConnect Hospital")
                            .setFontSize(22).setBold()
                            .setFontColor(WHITE)
                            .setTextAlignment(TextAlignment.CENTER))
                    .add(new Paragraph("Billing Invoice")
                            .setFontSize(11)
                            .setFontColor(WHITE)
                            .setTextAlignment(TextAlignment.CENTER));
            headerBar.addCell(brandCell);
            doc.add(headerBar);
            doc.add(spacer(8));

            // ── INVOICE META ──────────────────────────────────────────────────
            String dateStr = invoice.getCreatedAt() != null
                    ? invoice.getCreatedAt().format(DateTimeFormatter.ofPattern("dd MMM yyyy, hh:mm a"))
                    : "—";

            String patientName = "N/A";
            if (invoice.getPatient() != null) {
                patientName = invoice.getPatient().getFirstName()
                        + " " + invoice.getPatient().getLastName();
            }

            String payStatus = invoice.getPaymentStatus() != null ? invoice.getPaymentStatus().name() : "—";
            String invStatus = invoice.getStatus()        != null ? invoice.getStatus().name()        : "—";

            Table meta = new Table(UnitValue.createPercentArray(new float[]{1, 1}))
                    .useAllAvailableWidth()
                    .setBackgroundColor(BRAND_LIGHT)
                    .setBorder(new SolidBorder(DIVIDER, 0.5f));

            meta.addCell(metaCell("Invoice #",      String.valueOf(invoice.getId()), true));
            meta.addCell(metaCell("Date",           dateStr,                         true));
            meta.addCell(metaCell("Patient",        patientName,                     false));
            meta.addCell(metaCell("Invoice Status", invStatus,                       false));

            doc.add(meta);
            doc.add(spacer(14));

            // ── ITEMS TABLE ───────────────────────────────────────────────────
            Table table = new Table(UnitValue.createPercentArray(new float[]{5, 1.2f, 1.8f, 1.8f}))
                    .useAllAvailableWidth();

            // Column headers — use Rs. to avoid font encoding issues with ₹
            String[] headers = {"Description", "Qty", "Unit Price (Rs.)", "Total (Rs.)"};
            TextAlignment[] aligns = {
                    TextAlignment.LEFT,
                    TextAlignment.CENTER,
                    TextAlignment.RIGHT,
                    TextAlignment.RIGHT
            };

            for (int i = 0; i < headers.length; i++) {
                table.addHeaderCell(
                        new Cell()
                                .setBackgroundColor(BRAND_BLUE)
                                .setBorder(Border.NO_BORDER)
                                .setPaddingTop(8).setPaddingBottom(8)
                                .setPaddingLeft(6).setPaddingRight(6)
                                .add(new Paragraph(headers[i])
                                        .setBold().setFontSize(10)
                                        .setFontColor(WHITE)
                                        .setTextAlignment(aligns[i]))
                );
            }

            // Rows
            double grandTotal = 0;
            boolean odd = true;

            if (invoice.getItems() != null) {
                for (InvoiceItem item : invoice.getItems()) {
                    double rowTotal = item.getQuantity() * item.getPrice();
                    grandTotal += rowTotal;

                    DeviceRgb rowBg = odd ? WHITE : ROW_ALT;
                    odd = !odd;

                    table.addCell(itemCell(item.getItemName(),                 rowBg, TextAlignment.LEFT,   false));
                    table.addCell(itemCell(String.valueOf(item.getQuantity()), rowBg, TextAlignment.CENTER, false));
                    table.addCell(itemCell(formatRs(item.getPrice()),          rowBg, TextAlignment.RIGHT,  false));
                    table.addCell(itemCell(formatRs(rowTotal),                 rowBg, TextAlignment.RIGHT,  false));
                }
            }

            // Grand total footer row: [empty x2] [label] [value]
            table.addCell(totalFooterCell("", 2, false));
            table.addCell(totalFooterCell("Grand Total", 1, true));
            table.addCell(totalFooterCell(formatRs(grandTotal), 1, true));

            doc.add(table);

            // ── SUMMARY BOX ───────────────────────────────────────────────────
            doc.add(spacer(10));

            double totalAmt  = invoice.getTotalAmount()  != null ? invoice.getTotalAmount()  : 0.0;
            double paidAmt   = invoice.getPaidAmount()   != null ? invoice.getPaidAmount()   : 0.0;
            double remaining = totalAmt - paidAmt;

            Table summary = new Table(UnitValue.createPercentArray(new float[]{3, 1}))
                    .useAllAvailableWidth();
            addSummaryRow(summary, "Subtotal",      formatRs(grandTotal), false);
            addSummaryRow(summary, "Amount Billed", formatRs(totalAmt),   false);
            addSummaryRow(summary, "Amount Paid",   formatRs(paidAmt),    false);
            addSummaryRow(summary, "Balance Due",   formatRs(remaining),  true);

            doc.add(summary);

            // ── PAYMENT STATUS ────────────────────────────────────────────────
            doc.add(spacer(10));
            DeviceRgb badgeColor = switch (invoice.getPaymentStatus()) {
                case PAID    -> new DeviceRgb(0, 153, 76);
                case PARTIAL -> new DeviceRgb(204, 102, 0);
                default      -> new DeviceRgb(180, 0, 0);
            };

            doc.add(new Paragraph("Payment Status: " + payStatus)
                    .setBold().setFontSize(11)
                    .setFontColor(badgeColor)
                    .setTextAlignment(TextAlignment.RIGHT));

            // ── FOOTER ────────────────────────────────────────────────────────
            doc.add(spacer(24));
            doc.add(new Paragraph("─────────────────────────────────────────────────────────")
                    .setFontColor(DIVIDER).setFontSize(8));
            doc.add(new Paragraph("Thank you for choosing CareConnect Hospital. "
                    + "For queries please contact billing@careconnect.in")
                    .setFontSize(9).setFontColor(HEADER_GRAY)
                    .setTextAlignment(TextAlignment.CENTER));

            doc.close();
            return out.toByteArray();

        } catch (Exception e) {
            e.printStackTrace();
            throw new RuntimeException("PDF generation failed: " + e.getMessage());
        }
    }

    // ── Helpers ───────────────────────────────────────────────────────────────

    private static Paragraph spacer(float height) {
        return new Paragraph(" ").setFontSize(height / 2f).setMargin(0);
    }

    private static String formatRs(double val) {
        return String.format("Rs. %,.2f", val);
    }

    private static Cell metaCell(String label, String value, boolean topRow) {
        return new Cell()
                .setBorder(Border.NO_BORDER)
                .setPaddingTop(topRow ? 10 : 4)
                .setPaddingBottom(topRow ? 4 : 10)
                .setPaddingLeft(10).setPaddingRight(10)
                .add(new Paragraph(label)
                        .setFontSize(8).setFontColor(HEADER_GRAY).setMarginBottom(2))
                .add(new Paragraph(value)
                        .setFontSize(10).setBold().setFontColor(TEXT_DARK));
    }

    private static Cell itemCell(String text, DeviceRgb bg,
                                 TextAlignment align, boolean bold) {
        Paragraph p = new Paragraph(text)
                .setFontSize(9.5f).setFontColor(TEXT_DARK).setTextAlignment(align);
        if (bold) p.setBold();
        return new Cell()
                .setBackgroundColor(bg)
                .setBorderLeft(Border.NO_BORDER).setBorderRight(Border.NO_BORDER)
                .setBorderTop(new SolidBorder(DIVIDER, 0.3f)).setBorderBottom(Border.NO_BORDER)
                .setPaddingTop(7).setPaddingBottom(7)
                .setPaddingLeft(6).setPaddingRight(6)
                .add(p);
    }

    private static Cell totalFooterCell(String text, int colspan, boolean highlight) {
        Paragraph p = new Paragraph(text.isEmpty() ? " " : text)
                .setFontSize(10).setBold()
                .setFontColor(highlight ? WHITE : TEXT_DARK)
                .setTextAlignment(highlight ? TextAlignment.CENTER : TextAlignment.LEFT);
        return new Cell(1, colspan == 0 ? 1 : colspan)
                .setBackgroundColor(highlight ? BRAND_BLUE : WHITE)
                .setBorder(Border.NO_BORDER)
                .setBorderTop(new SolidBorder(DIVIDER, 0.5f))
                .setPaddingTop(6).setPaddingBottom(6)
                .setPaddingLeft(6).setPaddingRight(6)
                .add(p);
    }

    private static void addSummaryRow(Table t, String label, String value, boolean highlight) {
        DeviceRgb bg    = highlight ? BRAND_BLUE : WHITE;
        DeviceRgb color = highlight ? WHITE : TEXT_DARK;

        t.addCell(new Cell()
                .setBackgroundColor(bg)
                .setBorder(new SolidBorder(DIVIDER, 0.4f))
                .setPadding(6)
                .add(new Paragraph(label)
                        .setFontSize(10).setBold().setFontColor(color)));

        t.addCell(new Cell()
                .setBackgroundColor(bg)
                .setBorder(new SolidBorder(DIVIDER, 0.4f))
                .setPadding(6)
                .add(new Paragraph(value)
                        .setFontSize(10).setBold().setFontColor(color)
                        .setTextAlignment(TextAlignment.RIGHT)));
    }
}