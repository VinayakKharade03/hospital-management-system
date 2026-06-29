import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../auth/providers/auth_provider.dart';
import '../services/availability_service.dart';

class AddAvailabilityScreen extends StatefulWidget {
  const AddAvailabilityScreen({super.key});

  @override
  State<AddAvailabilityScreen> createState() =>
      _AddAvailabilityScreenState();
}

class _AddAvailabilityScreenState extends State<AddAvailabilityScreen> {

  final AvailabilityService _service = AvailabilityService();

  DateTime? selectedDate;
  String selectedDay = "MONDAY";
  TimeOfDay startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay endTime = const TimeOfDay(hour: 17, minute: 0);
  int slotDuration = 30;
  final TextEditingController customSlotController = TextEditingController();
  bool useCustomSlot = false;
  bool isLoading = false;

  final slotOptions = [15, 20, 30, 45, 60];

  @override
  void dispose() {
    customSlotController.dispose();
    super.dispose();
  }

  // ── Date Picker ──────────────────────────────
  Future<void> pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );

    if (picked == null) return;

    setState(() {
      selectedDate = picked;
      // ✅ Auto-extract day of week
      selectedDay = DateFormat('EEEE').format(picked).toUpperCase();
    });
  }

  // ── Time Picker ──────────────────────────────
  Future<void> pickTime({required bool isStart}) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? startTime : endTime,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );

    if (picked == null) return;

    setState(() {
      if (isStart) {
        startTime = picked;
        if (endTime.hour < picked.hour ||
            (endTime.hour == picked.hour && endTime.minute <= picked.minute)) {
          endTime = picked.replacing(hour: picked.hour + 1);
        }
      } else {
        endTime = picked;
      }
    });
  }

  String _formatTime(TimeOfDay t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return "$h:$m";
  }

  int get effectiveSlotDuration {
    if (useCustomSlot) {
      return int.tryParse(customSlotController.text) ?? slotDuration;
    }
    return slotDuration;
  }

  // ── Save ─────────────────────────────────────
  Future<void> save() async {
    final auth = context.read<AuthProvider>();
    final doctorId = auth.doctorId;

    if (doctorId == null || doctorId <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid doctor profile")),
      );
      return;
    }

    if (selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a date")),
      );
      return;
    }

    final startMinutes = startTime.hour * 60 + startTime.minute;
    final endMinutes = endTime.hour * 60 + endTime.minute;

    if (endMinutes <= startMinutes) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("End time must be after start time")),
      );
      return;
    }

    if (useCustomSlot && (int.tryParse(customSlotController.text) == null || int.parse(customSlotController.text) <= 0)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter a valid slot duration")),
      );
      return;
    }

    try {
      setState(() => isLoading = true);

      await _service.createAvailability(
        doctorId: doctorId,
        data: {
          "dayOfWeek": selectedDay,
          "startTime": _formatTime(startTime),
          "endTime": _formatTime(endTime),
          "slotDurationMinutes": effectiveSlotDuration,
        },
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Availability added ✅")),
      );

      Navigator.pop(context);

    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),

      appBar: AppBar(
        title: const Text("Add Availability"),
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

            // ── Date Picker ──────────────────────────────
            _sectionLabel("Select Date"),
            const SizedBox(height: 12),

            GestureDetector(
              onTap: pickDate,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: selectedDate != null
                        ? const Color(0xFF2563EB)
                        : const Color(0xFFE5E7EB),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.calendar_month_outlined,
                        color: Color(0xFF2563EB),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            selectedDate == null
                                ? "Tap to pick a date"
                                : DateFormat('EEEE, MMM d, yyyy').format(selectedDate!),
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                              color: selectedDate != null
                                  ? const Color(0xFF111827)
                                  : Colors.grey.shade500,
                            ),
                          ),
                          if (selectedDate != null) ...[
                            const SizedBox(height: 4),
                            // ✅ Show extracted day of week
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2563EB),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                "Recurring every $selectedDay",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: Colors.grey.shade400,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 28),

            // ── Time Selection ───────────────────────────
            _sectionLabel("Working Hours"),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _timePicker(
                    label: "Start Time",
                    time: startTime,
                    icon: Icons.access_time_outlined,
                    color: const Color(0xFF2563EB),
                    onTap: () => pickTime(isStart: true),
                  ),
                ),
                const SizedBox(width: 12),
                const Icon(Icons.arrow_forward,
                    color: Color(0xFF9CA3AF), size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: _timePicker(
                    label: "End Time",
                    time: endTime,
                    icon: Icons.access_time_filled_outlined,
                    color: const Color(0xFF16A34A),
                    onTap: () => pickTime(isStart: false),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Center(
              child: Text(
                "Total: ${_totalHours()} hours",
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              ),
            ),

            const SizedBox(height: 28),

            // ── Slot Duration ────────────────────────────
            _sectionLabel("Slot Duration"),
            const SizedBox(height: 12),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ...slotOptions.map((mins) {
                  final isSelected = !useCustomSlot && slotDuration == mins;
                  return GestureDetector(
                    onTap: () => setState(() {
                      slotDuration = mins;
                      useCustomSlot = false;
                    }),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF2563EB)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF2563EB)
                              : const Color(0xFFE5E7EB),
                        ),
                      ),
                      child: Text(
                        "${mins}m",
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF374151),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                }),

                // ✅ Custom chip
                GestureDetector(
                  onTap: () => setState(() => useCustomSlot = true),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: useCustomSlot
                          ? const Color(0xFF2563EB)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: useCustomSlot
                            ? const Color(0xFF2563EB)
                            : const Color(0xFFE5E7EB),
                      ),
                    ),
                    child: Text(
                      "Custom",
                      style: TextStyle(
                        color: useCustomSlot
                            ? Colors.white
                            : const Color(0xFF374151),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // ✅ Custom slot input — shown only when Custom is selected
            if (useCustomSlot) ...[
              const SizedBox(height: 12),
              TextField(
                controller: customSlotController,
                keyboardType: TextInputType.number,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: "Enter slot duration (minutes)",
                  border: const OutlineInputBorder(),
                  suffixText: "min",
                  filled: true,
                  fillColor: Colors.white,
                ),
                onChanged: (_) => setState(() {}),
              ),
            ],

            const SizedBox(height: 28),

            // ── Summary Card ─────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFBFDBFE)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Summary",
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E40AF),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _summaryRow("Date", selectedDate == null
                      ? "Not selected"
                      : DateFormat('MMM d, yyyy').format(selectedDate!)),
                  _summaryRow("Recurring", selectedDay),
                  _summaryRow("Hours",
                      "${_formatTime(startTime)} – ${_formatTime(endTime)}"),
                  _summaryRow("Slot", "$effectiveSlotDuration minutes"),
                  _summaryRow("Slots available", _totalSlots().toString()),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // ── Save Button ──────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: isLoading ? null : save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: isLoading
                    ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                    : const Icon(Icons.save_outlined),
                label: Text(
                  isLoading ? "Saving..." : "Add Availability",
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Helpers ──────────────────────────────────

  Widget _sectionLabel(String text) => Text(
    text,
    style: const TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w700,
      color: Color(0xFF111827),
    ),
  );

  Widget _timePicker({
    required String label,
    required TimeOfDay time,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style:
                TextStyle(color: Colors.grey.shade600, fontSize: 12)),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(
                  _formatTime(time),
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryRow(String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Row(
      children: [
        Text("$label: ",
            style: const TextStyle(
                color: Color(0xFF3B82F6), fontSize: 13)),
        Text(value,
            style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E40AF),
                fontSize: 13)),
      ],
    ),
  );

  String _totalHours() {
    final diff = (endTime.hour * 60 + endTime.minute) -
        (startTime.hour * 60 + startTime.minute);
    if (diff <= 0) return "0";
    final h = diff ~/ 60;
    final m = diff % 60;
    return m == 0 ? "$h" : "$h h $m m";
  }

  int _totalSlots() {
    final diff = (endTime.hour * 60 + endTime.minute) -
        (startTime.hour * 60 + startTime.minute);
    if (diff <= 0 || effectiveSlotDuration <= 0) return 0;
    return diff ~/ effectiveSlotDuration;
  }
}