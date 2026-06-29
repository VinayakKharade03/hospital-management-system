import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../auth/providers/auth_provider.dart';
import '../../auth/models/user_role.dart';

import '../../visit/services/visit_service.dart';

import '../models/appointment.dart';
import '../services/appointment_service.dart';
import 'add_edit_appointment_screen.dart';
import '../../billing/screen/billing_screen.dart';
import '../../visit/screens/visit_detail_screen.dart';
import '../../visit/model/visit.dart';
import '../../prescription/screens/write_prescription_screen.dart';
import '../../lab/screens/lab_reports_screen.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() =>
      _AppointmentsScreenState();
}

class _AppointmentsScreenState
    extends State<AppointmentsScreen> {

  final AppointmentService _service = AppointmentService();
  final VisitService _visitService = VisitService();

  // Scroll controller drives infinite-scroll pagination
  final ScrollController _scrollController = ScrollController();

  List<Appointment> appointments = [];
  String selectedFilter = "ALL";
  bool isLoading = true;

  // Pagination state (only used for admin/receptionist path)
  int _currentPage = 0;
  bool _hasMore = false;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchAllData();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // =====================================================
  // SCROLL LISTENER — load next page near bottom
  // =====================================================

  void _onScroll() {
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  // =====================================================
  // LOAD MORE (next page)
  // =====================================================

  Future<void> _loadMore() async {
    // Doctors load all their own appointments at once — no pagination needed
    final auth = context.read<AuthProvider>();
    if (auth.role == UserRole.DOCTOR) return;

    if (_isLoadingMore || !_hasMore) return;

    setState(() => _isLoadingMore = true);

    try {
      final result = await _service.getAppointments(
        page: _currentPage + 1,
      );

      setState(() {
        _currentPage++;
        _hasMore = result.hasMore;
        // Append and re-sort so newest stays on top
        appointments.addAll(result.appointments);
        appointments.sort(
              (a, b) => DateTime.parse(b.appointmentTime)
              .compareTo(DateTime.parse(a.appointmentTime)),
        );
        _isLoadingMore = false;
      });
    } catch (e) {
      setState(() => _isLoadingMore = false);
    }
  }

  // =====================================================
  // LOAD DATA (first page / full refresh)
  // =====================================================

  Future<void> fetchAllData() async {

    try {

      setState(() => isLoading = true);

      final auth = context.read<AuthProvider>();
      final isDoctor = auth.role == UserRole.DOCTOR;

      // ✅ DOCTOR -> only own appointments (no pagination needed)

      if (isDoctor) {

        final doctorId = auth.doctorId;

        if (doctorId == null) {
          throw Exception("Doctor profile missing");
        }

        final data = await _service.getAppointmentsByDoctor(doctorId);

        data.sort(
              (a, b) => DateTime.parse(b.appointmentTime)
              .compareTo(DateTime.parse(a.appointmentTime)),
        );

        setState(() {
          appointments = data;
          _hasMore = false;
          isLoading = false;
        });

        return;
      }

      // ✅ ADMIN / RECEPTIONIST — start from page 0

      final result = await _service.getAppointments(page: 0);

      result.appointments.sort(
            (a1, a2) => DateTime.parse(a2.appointmentTime)
            .compareTo(DateTime.parse(a1.appointmentTime)),
      );

      setState(() {
        _currentPage = 0;
        _hasMore = result.hasMore;
        appointments = result.appointments;
        isLoading = false;
      });

    } catch (e) {

      setState(() => isLoading = false);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  // =====================================================
  // DELETE
  // =====================================================

  Future<void> deleteAppointment(int id) async {

    try {

      await _service.deleteAppointment(id);

      // Full refresh so page numbers stay consistent
      await fetchAllData();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Appointment deleted")),
      );

    } catch (e) {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Delete failed: $e")),
      );
    }
  }

  // =====================================================
  // COMPLETE
  // =====================================================

  Future<void> updateStatus(int id) async {

    try {

      await _service.updateAppointment(id, {"status": "COMPLETED"});

      await fetchAllData();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Appointment completed")),
      );

    } catch (e) {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Update failed: $e")),
      );
    }
  }

  // =====================================================
  // CHECK-IN
  // =====================================================
  Future<void> checkInAppointment(Appointment appointment) async {
    try {
      await _visitService.checkIn(
        patientId: appointment.patientId,
        doctorId: appointment.doctorId,
        appointmentId: appointment.id,
      );

      await _service.updateAppointment(
        appointment.id,
        {"status": "CHECKED_IN"},
      );

      // ✅ Full refresh — same as updateStatus and deleteAppointment
      await fetchAllData();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Patient checked in")),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Check-in failed: $e")),
      );
    }
  }

  // =====================================================
  // OPEN VISIT
  // =====================================================

  Future<void> openVisit(Appointment appointment) async {
    try {
      final visit = await _visitService.getVisitByAppointment(appointment.id);

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => VisitDetailScreen(visit: visit),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Could not open visit: $e")),
      );
    }
  }

  // =====================================================
  // OPEN PRESCRIPTION
  // =====================================================

  Future<void> openPrescription(Appointment appointment) async {
    try {
      final visit = await _visitService.getVisitByAppointment(appointment.id);

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => WritePrescriptionScreen(visit: visit),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Could not open prescription: $e")),
      );
    }
  }

  // =====================================================
  // OPEN LAB REPORTS
  // =====================================================

  Future<void> openLabReports(Appointment appointment) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LabReportsScreen(
          patientId: appointment.patientId,
          patientName: appointment.patientName,
        ),
      ),
    );
  }

  // =====================================================
  // BILLING
  // =====================================================

  Future<void> openBilling(Appointment appointment) async {
    try {
      final visit = await _visitService.getVisitByAppointment(appointment.id);

      if (!mounted) return;

      if (visit.id == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("No visit found for this appointment yet"),
          ),
        );
        return;
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BillingScreen(visitId: visit.id!),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Could not open billing: $e")),
      );
    }
  }

  // =====================================================
  // OPEN FORM
  // =====================================================

  void openForm() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AddEditAppointmentScreen(),
      ),
    ).then((_) {
      // Reset filter to ALL so the new appointment is always visible
      setState(() => selectedFilter = "ALL");
      fetchAllData();
    });
  }

  // =====================================================
  // UI
  // =====================================================

  @override
  Widget build(BuildContext context) {

    final auth = Provider.of<AuthProvider>(context);

    final isAdmin        = auth.role == UserRole.ADMIN;
    final isReceptionist = auth.role == UserRole.RECEPTIONIST;
    final isDoctor       = auth.role == UserRole.DOCTOR;

    final canCreate       = isAdmin || isReceptionist;
    final canEdit         = isAdmin;
    final canDelete       = isAdmin;
    final canUpdateStatus = isDoctor || isAdmin;
    final canBill         = isReceptionist;

    final now = DateTime.now();

    final filteredAppointments = appointments.where((a) {
      final date = DateTime.parse(a.appointmentTime);

      if (selectedFilter == "TODAY") {
        return date.year == now.year &&
            date.month == now.month &&
            date.day == now.day;
      }

      if (selectedFilter == "UPCOMING") {
        return date.isAfter(now);
      }

      return true;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isDoctor ? "Your Appointments" : "Manage Appointments",
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [

          // =======================================
          // FILTER CHIPS + NEW BUTTON
          // =======================================

          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [

                Wrap(
                  spacing: 10,
                  children: [

                    ChoiceChip(
                      label: const Text("All"),
                      selected: selectedFilter == "ALL",
                      onSelected: (_) {
                        setState(() => selectedFilter = "ALL");
                      },
                    ),

                    ChoiceChip(
                      label: const Text("Today's"),
                      selected: selectedFilter == "TODAY",
                      onSelected: (_) {
                        setState(() => selectedFilter = "TODAY");
                      },
                    ),

                    ChoiceChip(
                      label: const Text("Upcoming"),
                      selected: selectedFilter == "UPCOMING",
                      onSelected: (_) {
                        setState(() => selectedFilter = "UPCOMING");
                      },
                    ),
                  ],
                ),

                if (canCreate)
                  ElevatedButton.icon(
                    onPressed: openForm,
                    icon: const Icon(Icons.add),
                    label: const Text("New Appointment"),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // =======================================
          // LIST
          // =======================================

          Expanded(
            child: filteredAppointments.isEmpty
                ? const Center(child: Text("No appointments found"))
                : ListView.builder(
              controller: _scrollController,
              // Extra slot at the bottom for the loading spinner
              itemCount: filteredAppointments.length +
                  (_hasMore ? 1 : 0),
              itemBuilder: (context, index) {

                // Bottom loader — shown only while fetching next page
                if (index == filteredAppointments.length) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                final a = filteredAppointments[index];

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  child: ListTile(
                    onTap: (isDoctor && a.status == "CHECKED_IN")
                        ? () => openVisit(a)
                        : null,
                    title: Text(
                      "${a.patientName} → ${a.doctorName}",
                    ),
                    subtitle: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [

                        Text(
                          a.appointmentTime.replaceAll("T", " "),
                        ),

                        const SizedBox(height: 4),

                        Row(
                          children: [

                            Container(
                              padding:
                              const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: a.status == "COMPLETED"
                                    ? Colors.green.shade100
                                    : a.status == "CHECKED_IN"
                                    ? Colors.orange.shade100
                                    : Colors.blue.shade100,
                                borderRadius:
                                BorderRadius.circular(20),
                              ),
                              child: Text(
                                a.status,
                                style: TextStyle(
                                  color: a.status == "COMPLETED"
                                      ? Colors.green
                                      : a.status == "CHECKED_IN"
                                      ? Colors.orange
                                      : Colors.blue,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),

                            if (a.queueNumber != null) ...[
                              const SizedBox(width: 10),
                              Text("Queue: ${a.queueNumber}"),
                            ],
                          ],
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [

                        // ✏️ EDIT
                        if (canEdit)
                          IconButton(
                            icon: const Icon(
                              Icons.edit,
                              color: Colors.blue,
                            ),
                            onPressed: () {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(
                                const SnackBar(
                                  content:
                                  Text("Edit coming soon"),
                                ),
                              );
                            },
                          ),

                        // ✅ CHECK-IN
                        if (!isDoctor &&
                            a.status != "CHECKED_IN" &&
                            a.status != "COMPLETED")
                          IconButton(
                            icon: const Icon(
                              Icons.login,
                              color: Colors.orange,
                            ),
                            onPressed: () =>
                                checkInAppointment(a),
                          ),

                        // ✅ COMPLETE
                        if (canUpdateStatus &&
                            a.status != "COMPLETED")
                          IconButton(
                            icon: const Icon(
                              Icons.check_circle,
                              color: Colors.green,
                            ),
                            onPressed: () => updateStatus(a.id),
                          ),

                        // 🧪 LAB REPORTS
                        if (isReceptionist || isAdmin)
                          IconButton(
                            icon: const Icon(
                              Icons.science_outlined,
                              color: Colors.teal,
                            ),
                            onPressed: () => openLabReports(a),
                          ),

                        // 💳 BILLING
                        if (canBill &&
                            (a.status == "CHECKED_IN" ||
                                a.status == "COMPLETED"))
                          IconButton(
                            icon: const Icon(
                              Icons.receipt_long,
                              color: Colors.purple,
                            ),
                            onPressed: () => openBilling(a),
                          ),

                        // 🗑 DELETE
                        if (canDelete)
                          IconButton(
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.red,
                            ),
                            onPressed: () =>
                                deleteAppointment(a.id),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}