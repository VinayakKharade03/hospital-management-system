import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../auth/providers/auth_provider.dart';
import '../../auth/screens/auth_screen.dart';

import '../../patient/screens/patients_screen.dart';
import '../../doctor/screens/doctors_screen.dart';
import '../../appointment/screen/appointments_screen.dart';
import '../../patient/screens/add_edit_patient_screen.dart';

import '../widgets/SideMenuItem.dart';
import '../widgets/StatCard.dart';
import '../widgets/quick_action_button.dart';
import '../widgets/EmptyStateCard.dart';
import '../../appointment/services/appointment_service.dart';
import '../../appointment/models/appointment.dart';

import '../../doctor/services/doctor_service.dart';
import '../../doctor/services/doctor_availability_service.dart';
import '../../doctor/models/doctor.dart';
import '../../billing/screen/billing_screen.dart';
import '../../lab/screens/lab_tests_screen.dart';

class ReceptionistDashboardScreen extends StatefulWidget {
  const ReceptionistDashboardScreen({
    super.key,
  });

  @override
  State<ReceptionistDashboardScreen> createState() =>
      _ReceptionistDashboardScreenState();
}

class _ReceptionistDashboardScreenState
    extends State<ReceptionistDashboardScreen> {

  bool isSidebarExpanded = true;

  final AppointmentService _appointmentService =
  AppointmentService();

  final DoctorService _doctorService =
  DoctorService();

  final DoctorAvailabilityService _availabilityService =
  DoctorAvailabilityService();

  List<Appointment> appointments = [];
  List<Doctor> doctors = [];

  int availableDoctorsToday = 0;

  bool isLoadingStats = true;

  @override
  void initState() {
    super.initState();
    loadDashboardData();
  }

  Future<void> loadDashboardData() async {
    try {

      final page = await _appointmentService.getAppointments(
        page: 0,
        size: 100,
        sort: "appointmentTime,desc",
      );

      final d =
      await _doctorService.getDoctors(0);

      final doctorsList =
      d["data"] as List<Doctor>;

      int availableCount = 0;

      final todayName = [
        "MONDAY",
        "TUESDAY",
        "WEDNESDAY",
        "THURSDAY",
        "FRIDAY",
        "SATURDAY",
        "SUNDAY"
      ][DateTime.now().weekday - 1];

      for (final doctor in doctorsList) {

        try {

          final availability =
          await _availabilityService
              .getAvailability(
            doctor.id,
          );

          if (availability.any(
                (a) =>
            a.dayOfWeek ==
                todayName,
          )) {

            availableCount++;
          }

        } catch (_) {}
      }

      setState(() {

        appointments = page.appointments;

        doctors = doctorsList;

        availableDoctorsToday =
            availableCount;

        isLoadingStats = false;
      });

    } catch (e) {

      setState(() {
        isLoadingStats = false;
      });
    }
  }

  int get todaysAppointments {

    final today = DateTime.now();

    return appointments.where((a) {

      final date =
      DateTime.tryParse(a.appointmentTime);

      if (date == null) return false;

      return date.year == today.year &&
          date.month == today.month &&
          date.day == today.day;

    }).length;
  }

  int get checkedInCount {

    final today = DateTime.now();

    return appointments.where((a) {

      if (a.status != "CHECKED_IN") {
        return false;
      }

      final date =
      DateTime.tryParse(a.appointmentTime);

      if (date == null) {
        return false;
      }

      return date.year == today.year &&
          date.month == today.month &&
          date.day == today.day;

    }).length;
  }

  List<Appointment> get todaysQueue {

    final today = DateTime.now();

    return appointments.where((a) {

      final date =
      DateTime.tryParse(a.appointmentTime);

      if (date == null) return false;

      return a.status == "CHECKED_IN" &&
          date.year == today.year &&
          date.month == today.month &&
          date.day == today.day;

    }).toList()

      ..sort(
            (a, b) => a.appointmentTime.compareTo(
          b.appointmentTime,
        ),
      );
  }

  List<Appointment> get upcomingAppointments {
    final today = DateTime.now();
    final startOfTomorrow = DateTime(today.year, today.month, today.day + 1);

    return appointments.where((a) {
      final date = DateTime.tryParse(a.appointmentTime);
      if (date == null) return false;

      return date.isAfter(startOfTomorrow.subtract(const Duration(milliseconds: 1))) &&
          a.status != "CANCELLED" &&
          a.status != "COMPLETED" &&
          a.status != "NO_SHOW";
    }).toList()
      ..sort((a, b) => a.appointmentTime.compareTo(b.appointmentTime));
  }

  // ── helpers ───────────────────────────────────────────────────────────────

  /// E.g.  "Mon, 27 Jun 2026"
  String get _formattedDate {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final now = DateTime.now();
    return '${now.day} ${months[now.month - 1]} ${now.year}';
  }

  // ── profile popup ─────────────────────────────────────────────────────────

  void _showProfilePopup(BuildContext context, AuthProvider auth) {
    final button = context.findRenderObject() as RenderBox?;
    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;

    // Fall back to top-right if we can't locate the button
    final offset = button == null
        ? const Offset(0, 60)
        : button.localToGlobal(
      Offset(button.size.width - 200, button.size.height + 8),
      ancestor: overlay,
    );

    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        offset.dx, offset.dy, offset.dx + 200, offset.dy + 200,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 8,
      items: <PopupMenuEntry<dynamic>>[
        PopupMenuItem(
          enabled: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.green.shade100,
                    child: const Icon(Icons.person, color: Colors.green, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Receptionist',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        'ID: ${auth.userId ?? 101}',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.circle, color: Colors.green, size: 8),
                    SizedBox(width: 5),
                    Text('Online',
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        )),
                  ],
                ),
              ),
            ],
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          onTap: () async => await auth.logout(),
          child: const Row(
            children: [
              Icon(Icons.logout, size: 18, color: Colors.red),
              SizedBox(width: 10),
              Text('Logout', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {

    final auth =
    Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      body: SafeArea(
        child: Row(
          children: [

            // =========================================================
            // SIDEBAR
            // =========================================================

            AnimatedContainer(
              duration: const Duration(milliseconds: 250),

              width: isSidebarExpanded ? 270 : 88,

              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                  ),
                ],
              ),

              child: Column(
                children: [

                  // ===================================================
                  // TOP LOGO
                  // ===================================================

                  ClipRect(
                    child: Container(
                      height: 110,
                      width: double.infinity,

                      padding: EdgeInsets.symmetric(
                        horizontal: isSidebarExpanded ? 18 : 0,
                      ),

                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFF18864B),
                            Color(0xFF2FA15F),
                          ],
                        ),
                      ),

                      child: Row(
                        mainAxisAlignment: isSidebarExpanded
                            ? MainAxisAlignment.start
                            : MainAxisAlignment.center,

                        children: [

                          Container(
                            width: 54,
                            height: 54,

                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                            ),

                            child: const Icon(
                              Icons.local_hospital,
                              color: Color(0xFF18864B),
                              size: 32,
                            ),
                          ),

                          if (isSidebarExpanded) ...[
                            const SizedBox(width: 16),

                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Care Connect\nHospital",
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    "Reception Module",
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      letterSpacing: 0.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // ===================================================
                  // MENU ITEMS  (Reports item removed)
                  // ===================================================

                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [

                          SideMenuItem(
                            expanded: isSidebarExpanded,
                            icon: Icons.dashboard,
                            title: "Dashboard",
                            selected: true,
                            onTap: () {},
                          ),

                          SideMenuItem(
                            expanded: isSidebarExpanded,
                            icon: Icons.people,
                            title: "Patients",
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                  const PatientsScreen(),
                                ),
                              );
                            },
                          ),

                          SideMenuItem(
                            expanded: isSidebarExpanded,
                            icon: Icons.calendar_month,
                            title: "Appointments",
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                  const AppointmentsScreen(),
                                ),
                              );
                            },
                          ),

                          SideMenuItem(
                            expanded: isSidebarExpanded,
                            icon: Icons.medical_services,
                            title: "Doctors",
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                  const DoctorsScreen(),
                                ),
                              );
                            },
                          ),

                          // ── "Reports" menu item removed ──
                        ],
                      ),
                    ),
                  ),

                  // ===================================================
                  // LOGOUT — styled as a standard SideMenuItem
                  // ===================================================

                  SideMenuItem(
                    expanded: isSidebarExpanded,
                    icon: Icons.logout,
                    title: "Logout",
                    onTap: () async => await auth.logout(),
                  ),

                  const SizedBox(height: 12),

                ],
              ),
            ),

            // =========================================================
            // MAIN CONTENT
            // =========================================================

            Expanded(
              child: Column(
                children: [

                  // ===================================================
                  // TOP BAR
                  // ===================================================

                  Container(
                    height: 80,

                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                    ),

                    decoration: const BoxDecoration(
                      color: Colors.white,

                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                        ),
                      ],
                    ),

                    child: Row(
                      children: [

                        IconButton(
                          onPressed: () {
                            setState(() {
                              isSidebarExpanded =
                              !isSidebarExpanded;
                            });
                          },

                          icon: const Icon(
                            Icons.menu,
                            size: 28,
                          ),
                        ),

                        const SizedBox(width: 10),

                        const Text(
                          "Reception",

                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const Spacer(),

                        // ── Styled date capsule pill ──────────────────
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEDF7F1),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: const Color(0xFF18864B).withOpacity(0.25),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.calendar_today_outlined,
                                size: 14,
                                color: Color(0xFF18864B),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _formattedDate,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF18864B),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 14),

                        // ── Profile avatar with popup ─────────────────
                        Builder(
                          builder: (ctx) => GestureDetector(
                            onTap: () => _showProfilePopup(ctx, auth),
                            child: CircleAvatar(
                              radius: 20,
                              backgroundColor: Colors.green.shade100,
                              child: const Icon(
                                Icons.person,
                                color: Colors.green,
                                size: 22,
                              ),
                            ),
                          ),
                        ),

                        // ── Refresh IconButton removed ────────────────
                      ],
                    ),
                  ),

                  // ===================================================
                  // CONTENT
                  // ===================================================

                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),

                      child: Column(
                        children: [

                          // ===========================================
                          // STATS
                          // ===========================================

                          LayoutBuilder(
                            builder: (context, constraints) {
                              return Wrap(
                                spacing: 20,
                                runSpacing: 20,
                                children: [

                                  SizedBox(
                                    width: (constraints.maxWidth / 3) - 15,
                                    child: StatCard(
                                      title: "Today's Appointments",
                                      value: isLoadingStats
                                          ? "..."
                                          : todaysAppointments.toString(),
                                      icon: Icons.calendar_today,
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => const AppointmentsScreen(),
                                          ),
                                        );
                                      },
                                    ),
                                  ),

                                  SizedBox(
                                    width: (constraints.maxWidth / 3) - 15,
                                    child: StatCard(
                                      title: "Checked-In",
                                      value: isLoadingStats
                                          ? "..."
                                          : checkedInCount.toString(),
                                      icon: Icons.person_add_alt,
                                    ),
                                  ),

                                  SizedBox(
                                    width: (constraints.maxWidth / 3) - 15,
                                    child: StatCard(
                                      title: "Available Doctors",
                                      value: isLoadingStats
                                          ? "..."
                                          : availableDoctorsToday.toString(),
                                      icon: Icons.groups,
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => const DoctorsScreen(),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),

                          const SizedBox(height: 28),

                          // ===========================================
                          // QUICK ACTIONS
                          // ===========================================

                          Container(
                            width: double.infinity,

                            padding: const EdgeInsets.all(24),

                            decoration: BoxDecoration(
                              color: Colors.white,

                              borderRadius:
                              BorderRadius.circular(20),

                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 4,
                                ),
                              ],
                            ),

                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,

                              children: [

                                const Text(
                                  "Quick Actions",

                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight:
                                    FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(height: 22),

                                LayoutBuilder(
                                  builder:
                                      (context, constraints) {
                                    return Wrap(
                                      spacing: 18,
                                      runSpacing: 18,

                                      children: [

                                        SizedBox(
                                          width:
                                          (constraints.maxWidth / 4) -
                                              14,

                                          child: QuickActionCard(
                                            title:
                                            "Register Patient",

                                            icon:
                                            Icons.person_add,

                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) =>
                                                  const AddEditPatientScreen(),
                                                ),
                                              );
                                            },
                                          ),
                                        ),

                                        SizedBox(
                                          width: (constraints.maxWidth / 4) - 14,

                                          child: QuickActionCard(
                                            title: "Appointment",

                                            icon: Icons.calendar_month,

                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) => const AppointmentsScreen(),
                                                ),
                                              );
                                            },
                                          ),
                                        ),

                                      ],
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 28),

                          // ===========================================
                          // LOWER SECTION
                          // ===========================================

                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [

                              // =======================================
                              // TODAY'S QUEUE
                              // =======================================

                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Colors.black12,
                                        blurRadius: 4,
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [

                                      const Text(
                                        "Today's Queue",
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),

                                      const SizedBox(height: 16),

                                      if (todaysQueue.isEmpty)
                                        const Text(
                                          "No checked-in patients",
                                        ),

                                      ...todaysQueue.take(5).toList().asMap().entries.map(
                                            (entry) {
                                          final index = entry.key;
                                          final a = entry.value;

                                          return ListTile(
                                            contentPadding: EdgeInsets.zero,

                                            leading: Container(
                                              width: 36,
                                              height: 36,
                                              alignment: Alignment.center,
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFF1EFE8),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                "${index + 1}",
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.grey.shade700,
                                                ),
                                              ),
                                            ),

                                            title: Text(
                                              a.patientName,
                                            ),

                                            subtitle: Text(
                                              a.doctorName,
                                            ),

                                            trailing: Text(
                                              a.appointmentTime.length >= 16
                                                  ? a.appointmentTime.substring(11, 16)
                                                  : "",
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: Colors.grey.shade500,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              const SizedBox(width: 24),

                              // =======================================
                              // UPCOMING APPOINTMENTS
                              // =======================================

                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Colors.black12,
                                        blurRadius: 4,
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [

                                      const Text(
                                        "Upcoming Appointments",
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),

                                      const SizedBox(height: 16),

                                      if (upcomingAppointments.isEmpty)
                                        const Text(
                                          "No upcoming appointments",
                                        ),

                                      ...upcomingAppointments.take(5).map(
                                            (a) => ListTile(
                                          contentPadding: EdgeInsets.zero,

                                          leading: const Icon(
                                            Icons.calendar_month,
                                          ),

                                          title: Text(
                                            a.patientName,
                                          ),

                                          subtitle: Text(
                                            a.doctorName,
                                          ),

                                          trailing: Text(
                                            a.appointmentTime.length >= 16
                                                ? a.appointmentTime.substring(11, 16)
                                                : "",
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 250),

                          Align(
                            alignment: Alignment.bottomCenter,
                            child: Text(
                              "© 2025 Hospital Management System. All rights reserved.",
                              style: TextStyle(
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}