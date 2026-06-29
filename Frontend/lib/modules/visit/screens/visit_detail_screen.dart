import 'package:flutter/material.dart';
import '../../lab/screens/lab_tests_screen.dart';
import '../model/visit.dart';
import '../../billing/screen/billing_screen.dart';
import '../../prescription/screens/write_prescription_screen.dart';
import '../../appointment/services/appointment_service.dart'; // 🟢 added

class VisitDetailScreen extends StatefulWidget { // 🟢 changed from StatelessWidget
  final Visit visit;
  final Future<void> Function()? onComplete;

  const VisitDetailScreen({super.key, required this.visit, this.onComplete});

  @override
  State<VisitDetailScreen> createState() => _VisitDetailScreenState(); // 🟢 added
}

class _VisitDetailScreenState extends State<VisitDetailScreen> { // 🟢 added
  final AppointmentService _appointmentService = AppointmentService(); // 🟢 added
  bool _completing = false; // 🟢 added

  Visit get visit => widget.visit; // 🟢 added

  // 🟢 added — actually performs the status update
  Future<void> _completeAppointment() async {
    if (_completing) return;
    setState(() => _completing = true);

    try {
      await _appointmentService.updateAppointment(
        visit.appointmentId,
        {"status": "COMPLETED"},
      );

      if (widget.onComplete != null) {
        await widget.onComplete!();
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Appointment completed")),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() => _completing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to complete appointment: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),

      appBar: AppBar(
        title: const Text("Visit Details"),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF111827),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFE5E7EB), height: 1),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Visit Info Card ──────────────────────────
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: const Color(0xFFDBEAFE),
                        child: const Icon(
                          Icons.medical_services_outlined,
                          color: Color(0xFF2563EB),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Visit",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            "ID #${visit.id ?? '-'}",
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      _statusBadge(visit.status ?? "UNKNOWN"),
                    ],
                  ),

                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 16),

                  _infoRow(Icons.person_outline, "Patient ID", visit.patientId.toString()),
                  const SizedBox(height: 12),
                  _infoRow(Icons.medical_services_outlined, "Doctor ID", visit.doctorId.toString()),
                  const SizedBox(height: 12),
                  _infoRow(Icons.calendar_today_outlined, "Appointment ID", visit.appointmentId.toString()),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Actions ─────────────────────────────────
            const Text(
              "Actions",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF111827),
              ),
            ),

            const SizedBox(height: 12),

            // Order Lab Test button
            _actionButton(
              icon: Icons.science_outlined,
              label: "Order Lab Test",
              subtitle: "Send patient for a lab test",
              color: const Color(0xFF2563EB),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => LabTestsScreen(
                      visitId: visit.id,
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 12),

            // Write Prescription button
            _actionButton(
              icon: Icons.receipt_long_outlined,
              label: "Write Prescription",
              subtitle: "Add medicines for this visit",
              color: const Color(0xFF9333EA),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => WritePrescriptionScreen(visit: visit),
                  ),
                );
              },
            ),

            const SizedBox(height: 12),

            // Complete Visit button
            _actionButton(
              icon: Icons.check_circle_outline,
              label: _completing ? "Completing..." : "Complete Appointment", // 🟢 small UX feedback
              subtitle: "Mark appointment as completed",
              color: const Color(0xFF16A34A),
              onTap: _completing ? () {} : _completeAppointment, // 🟢 wired to real logic
            ),
          ],
        ),
      ),
    );
  }

  // ── Helpers ─────────────────────────────────────

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: child,
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey.shade500),
        const SizedBox(width: 10),
        Text(
          "$label:",
          style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ],
    );
  }

  Widget _statusBadge(String status) {
    Color color;
    switch (status.toUpperCase()) {
      case "CHECKED_IN":  color = Colors.blue;   break;
      case "COMPLETED":   color = Colors.green;  break;
      case "CANCELLED":   color = Colors.red;    break;
      default:            color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }
}