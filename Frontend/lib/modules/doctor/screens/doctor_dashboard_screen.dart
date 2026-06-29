import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:hospital_management_app/modules/auth/providers/auth_provider.dart';

import '../../appointment/models/appointment.dart';
import '../../appointment/screen/appointments_screen.dart';
import '../../appointment/services/appointment_service.dart';

import '../../availability/screens/add_availability_screen.dart';

import '../../patient/models/patient.dart';
import '../../patient/screens/patients_screen.dart';
import '../../patient/services/patient_service.dart';
import '../../lab/screens/lab_tests_screen.dart';
import '../../lab/services/lab_service.dart';

class DoctorDashboardScreen extends StatefulWidget {
  const DoctorDashboardScreen({super.key});

  @override
  State<DoctorDashboardScreen> createState() =>
      _DoctorDashboardScreenState();
}

class _DoctorDashboardScreenState
    extends State<DoctorDashboardScreen> {

  final AppointmentService _appointmentService =
  AppointmentService();

  final PatientService _patientService =
  PatientService();

  final LabService _labService =
  LabService();

  bool isLoading = true;

  List<Appointment> appointments = [];
  List<Patient> patients = [];

  int todayAppointments = 0;
  int completedAppointments = 0;
  int upcomingAppointments = 0;
  int totalPatients = 0;
  int labTestsOrdered = 0;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    try {

      final auth =
      Provider.of<AuthProvider>(
        context,
        listen: false,
      );

      final doctorId =
          auth.doctor?.id;

      if (doctorId == null) {
        setState(() {
          isLoading = false;
        });
        return;
      }

      final fetchedAppointments =
      await _appointmentService
          .getAppointmentsByDoctor(
        doctorId,
      );

      final fetchedPatients =
      await _patientService.getPatients();

      int labCount = 0;

      try {
        final labReports = await _labService.getAllOrders();

        labCount = labReports.length;
      } catch (e) {
        debugPrint("Lab Count Error: $e");
      }
      final now = DateTime.now();

      int today = 0;
      int completed = 0;
      int upcoming = 0;

      for (var appt in fetchedAppointments) {

        try {

          final date =
          DateTime.parse(
            appt.appointmentTime,
          );

          if (date.year == now.year &&
              date.month == now.month &&
              date.day == now.day) {

            today++;
          }

          if (appt.status
              .toLowerCase()
              .contains("completed")) {

            completed++;
          }

          if (date.isAfter(now)) {
            upcoming++;
          }

        } catch (_) {}
      }

      setState(() {

        appointments =
            fetchedAppointments;

        patients =
            fetchedPatients;

        todayAppointments =
            today;

        completedAppointments =
            completed;

        upcomingAppointments =
            upcoming;

        totalPatients =
            fetchedPatients.length;

        labTestsOrdered =
            labCount;

        isLoading = false;
      });

    } catch (e) {

      setState(() {
        isLoading = false;
      });

      debugPrint(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {

    final auth =
    Provider.of<AuthProvider>(context);

    return Scaffold(

      backgroundColor:
      const Color(0xFFF5F7FB),

      body: Row(

        children: [

          // ================= SIDEBAR =================

          Container(
            width: 230,

            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                right: BorderSide(
                  color: Color(0xFFE5E7EB),
                ),
              ),
            ),

            child: Column(
              children: [

                // ================= LOGO =================

                Container(
                  height: 90,

                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                  ),

                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Color(0xFFE5E7EB),
                      ),
                    ),
                  ),

                  child: Row(
                    children: [

                      Container(
                        width: 42,
                        height: 42,

                        decoration: BoxDecoration(
                          color: const Color(0xFF2563EB),
                          borderRadius: BorderRadius.circular(12),
                        ),

                        child: const Icon(
                          Icons.local_hospital_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),

                      const SizedBox(width: 10),

                      const Expanded(
                        child: Text(
                          "CareConnect",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,

                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF2563EB),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                Expanded(
                  child: Column(
                    children: [
                      _sideItem(
                        Icons.dashboard_outlined,
                        "Dashboard",
                        true,
                            () {},
                      ),

                      _sideItem(
                        Icons.calendar_today_outlined,
                        "Appointments",
                        false,
                            () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AppointmentsScreen(),
                            ),
                          );
                        },
                      ),

                      _sideItem(
                        Icons.people_outline,
                        "Patients",
                        false,
                            () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const PatientsScreen(),
                            ),
                          );
                        },
                      ),

                      _sideItem(
                        Icons.access_time_outlined,
                        "Availability",
                        false,
                            () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AddAvailabilityScreen(),
                            ),
                          );
                        },
                      ),

                      _sideItem(
                        Icons.science_outlined,
                        "Lab Tests",
                        false,
                            () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LabTestsScreen(),
                            ),
                          );
                        },
                      ),

                      _sideItem(
                        Icons.receipt_long_outlined,
                        "Prescriptions",
                        false,
                            () {},
                      ),

                    ],
                  ),
                ),

                // ── Logout above Help & Support ──
                _sideItem(
                  Icons.logout_rounded,
                  "Logout",
                  false,
                      () => _confirmLogout(context, auth),
                ),

                // ================= HELP =================

                Padding(
                  padding: const EdgeInsets.all(20),

                  child: Row(
                    children: [

                      Icon(
                        Icons.help_outline,
                        color: Colors.grey.shade600,
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        child: Text(
                          "Help & Support",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,

                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // ================= MAIN CONTENT =================

          Expanded(

            child: isLoading
                ? const Center(
              child:
              CircularProgressIndicator(),
            )

                : Column(

              children: [

                // ================= TOP BAR =================

                Container(

                  height: 90,

                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                  ),

                  decoration: const BoxDecoration(
                    color: Colors.white,

                    border: Border(
                      bottom: BorderSide(
                        color: Color(0xFFE5E7EB),
                      ),
                    ),
                  ),

                  child: Row(

                    mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,

                    children: [

                      const Text(
                        "Doctor ",

                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF111827),
                        ),
                      ),

                      Row(

                        children: [

                          // ── Date capsule pill ──
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFF6FF),
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color: const Color(0xFF2563EB).withOpacity(0.25),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.calendar_today_outlined,
                                  size: 14,
                                  color: Color(0xFF2563EB),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                      () {
                                    const months = ['Jan','Feb','Mar','Apr','May','Jun',
                                      'Jul','Aug','Sep','Oct','Nov','Dec'];
                                    final now = DateTime.now();
                                    return '${now.day} ${months[now.month - 1]} ${now.year}';
                                  }(),
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF2563EB),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(width: 14),

                          // ================= DOCTOR PROFILE =================
                          GestureDetector(
                            onTap: () {
                              _openProfile(
                                context,
                                auth,
                              );
                            },

                            child: Container(
                              width: 58,
                              height: 58,

                              decoration: BoxDecoration(
                                shape: BoxShape.circle,

                                image: const DecorationImage(
                                  image: NetworkImage(
                                    "https://cdn-icons-png.flaticon.com/512/387/387561.png",
                                  ),
                                  fit: BoxFit.cover,
                                ),

                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.08),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // ================= BODY =================

                Expanded(

                  child: SingleChildScrollView(

                    padding:
                    const EdgeInsets.all(28),

                    child: Column(

                      children: [

                        // ================= PROFILE CARD =================

                        Container(

                          width: double.infinity,

                          padding:
                          const EdgeInsets.all(28),

                          decoration: BoxDecoration(
                            color: Colors.white,

                            borderRadius:
                            BorderRadius.circular(
                                18),

                            border: Border.all(
                              color: const Color(
                                  0xFFE5E7EB),
                            ),
                          ),

                          child: Row(

                            children: [

                              CircleAvatar(
                                radius: 52,
                                backgroundColor:
                                const Color(
                                    0xFFDBEAFE),

                                child: const Icon(
                                  Icons.medical_services_outlined,
                                  color:
                                  Color(0xFF2563EB),
                                  size: 48,
                                ),
                              ),

                              const SizedBox(width: 24),

                              Expanded(

                                child: Column(

                                  crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,

                                  children: [

                                    Text(
                                      "Dr. ${auth.doctor?.fullName ?? ''}",

                                      style:
                                      const TextStyle(
                                        fontSize: 28,
                                        fontWeight:
                                        FontWeight
                                            .w700,
                                      ),
                                    ),

                                    const SizedBox(
                                        height: 8),

                                    Text(
                                      auth.doctor
                                          ?.specialization ??
                                          "",

                                      style:
                                      TextStyle(
                                        fontSize: 18,
                                        color:
                                        Colors.grey
                                            .shade700,
                                      ),
                                    ),

                                    const SizedBox(
                                        height: 12),

                                    Text(
                                      "MBBS, MD (${auth.doctor?.specialization ?? ''}) • 12+ Years Experience",

                                      style:
                                      TextStyle(
                                        color:
                                        Colors.grey
                                            .shade700,
                                        fontSize: 14,
                                      ),
                                    ),


                                  ],
                                ),
                              ),

                              OutlinedButton(

                                style:
                                OutlinedButton
                                    .styleFrom(
                                  padding:
                                  const EdgeInsets
                                      .symmetric(
                                    horizontal: 22,
                                    vertical: 18,
                                  ),

                                  shape:
                                  RoundedRectangleBorder(
                                    borderRadius:
                                    BorderRadius
                                        .circular(
                                        12),
                                  ),
                                ),

                                onPressed: () {
                                  _openProfile(
                                    context,
                                    auth,
                                  );
                                },

                                child: const Row(

                                  children: [

                                    Text(
                                      "View Profile",

                                      style: TextStyle(
                                        color:
                                        Colors.black,
                                        fontWeight:
                                        FontWeight
                                            .w600,
                                      ),
                                    ),

                                    SizedBox(width: 8),

                                    Icon(
                                      Icons.arrow_forward,
                                      color:
                                      Colors.black,
                                      size: 18,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // ================= STATS =================

                        Row(

                          children: [

                            Expanded(
                              child: _modernStatCard(
                                "Today's Appointments",
                                todayAppointments
                                    .toString(),
                                "Total",
                                Icons.calendar_today_outlined,
                                const Color(
                                    0xFF2563EB),
                              ),
                            ),

                            const SizedBox(width: 18),

                            Expanded(
                              child: _modernStatCard(
                                "Patients Seen",
                                completedAppointments
                                    .toString(),
                                "Completed",
                                Icons.groups_outlined,
                                const Color(
                                    0xFF9333EA),
                              ),
                            ),

                            const SizedBox(width: 18),

                            Expanded(
                              child: _modernStatCard(
                                "Upcoming Appointments",
                                upcomingAppointments
                                    .toString(),
                                "Next 24 Hours",
                                Icons.access_time,
                                const Color(
                                    0xFF16A34A),
                              ),
                            ),

                            const SizedBox(width: 18),

                            Expanded(
                              child: _modernStatCard(
                                "Lab Tests Ordered",
                                labTestsOrdered.toString(),
                                "Total Orders",
                                Icons.science_outlined,
                                const Color(0xFFF97316),
                              ),
                            ),

                          ],
                        ),

                        const SizedBox(height: 24),
                        // ================= MIDDLE SECTION =================

                        Row(

                          crossAxisAlignment:
                          CrossAxisAlignment
                              .start,

                          children: [

                            Expanded(
                              child: _scheduleCard(),
                            ),

                            const SizedBox(width: 20),


                          ],
                        ),

                        const SizedBox(height: 24),

                        // ================= BOTTOM =================

                        const SizedBox(height: 24),

                        Text(
                          "© 2024 Care Connect Hospital Management System. All rights reserved.",

                          style: TextStyle(
                            color:
                            Colors.grey.shade500,
                            fontSize: 13,
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
    );
  }

  // ================= SIDEBAR ITEM =================

  Widget _sideItem(
      IconData icon,
      String title,
      bool active,
      VoidCallback onTap,
      ) {

    return Padding(

      padding:
      const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 4,
      ),

      child: Material(

        color: active
            ? const Color(0xFFEFF6FF)
            : Colors.transparent,

        borderRadius:
        BorderRadius.circular(12),

        child: ListTile(

          shape: RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(12),
          ),

          leading: Icon(
            icon,

            color: active
                ? const Color(0xFF2563EB)
                : Colors.grey.shade700,
          ),

          title: Text(
            title,

            style: TextStyle(
              color: active
                  ? const Color(0xFF2563EB)
                  : Colors.grey.shade800,

              fontWeight:
              FontWeight.w600,
            ),
          ),

          onTap: onTap,
        ),
      ),
    );
  }

  // ================= MODERN STAT CARD =================

  Widget _modernStatCard(
      String title,
      String value,
      String subtitle,
      IconData icon,
      Color color,
      ) {

    return Container(

      padding: const EdgeInsets.all(22),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius:
        BorderRadius.circular(18),

        border: Border.all(
          color: const Color(0xFFE5E7EB),
        ),
      ),

      child: Column(

        crossAxisAlignment:
        CrossAxisAlignment.start,

        children: [

          CircleAvatar(
            radius: 24,

            backgroundColor:
            color.withOpacity(0.10),

            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),

          const SizedBox(height: 18),

          Text(
            title,

            style: TextStyle(
              color:
              Colors.grey.shade700,
              fontSize: 14,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            value,

            style: const TextStyle(
              fontSize: 34,
              fontWeight:
              FontWeight.w700,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            subtitle,

            style: TextStyle(
              color:
              Colors.grey.shade600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  // ================= CARD BOX =================

  Widget _cardBox({
    required Widget child,
  }) {

    return Container(

      padding: const EdgeInsets.all(22),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius:
        BorderRadius.circular(18),

        border: Border.all(
          color: const Color(0xFFE5E7EB),
        ),
      ),

      child: child,
    );
  }

  // ================= SCHEDULE CARD =================

  Widget _scheduleCard() {

    final now = DateTime.now();

    final todaysAppointments = appointments.where((appointment) {
      try {
        final date = DateTime.parse(appointment.appointmentTime);
        return date.year == now.year &&
            date.month == now.month &&
            date.day == now.day;
      } catch (_) {
        return false;
      }
    }).toList()
      ..sort((a, b) => DateTime.parse(a.appointmentTime)
          .compareTo(DateTime.parse(b.appointmentTime)));

    return _cardBox(

      child: Column(

        crossAxisAlignment:
        CrossAxisAlignment.start,

        children: [

          Row(

            mainAxisAlignment:
            MainAxisAlignment
                .spaceBetween,

            children: [

              const Row(

                children: [

                  Icon(
                    Icons.calendar_today_outlined,
                    size: 20,
                  ),

                  SizedBox(width: 10),

                  Text(
                    "Today's Schedule",

                    style: TextStyle(
                      fontSize: 18,
                      fontWeight:
                      FontWeight.w700,
                    ),
                  ),
                ],
              ),

              Text(
                "View all",

                style: TextStyle(
                  color:
                  Colors.blue.shade700,
                  fontWeight:
                  FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 22),

          ...todaysAppointments.take(5).map((appointment) {

            String formatted =
                appointment.appointmentTime;

            try {

              formatted =
                  DateFormat(
                    "hh:mm a",
                  ).format(
                    DateTime.parse(
                      appointment.appointmentTime,
                    ),
                  );

            } catch (_) {}

            Color statusColor =
                Colors.blue;

            if (appointment.status
                .toLowerCase()
                .contains(
                "completed")) {

              statusColor =
                  Colors.green;
            }

            return Padding(

              padding:
              const EdgeInsets.only(
                bottom: 18,
              ),

              child: Row(

                children: [

                  SizedBox(
                    width: 85,

                    child: Text(
                      formatted,

                      style:
                      const TextStyle(
                        fontWeight:
                        FontWeight.w600,
                      ),
                    ),
                  ),

                  Expanded(

                    child: Column(

                      crossAxisAlignment:
                      CrossAxisAlignment
                          .start,

                      children: [

                        Text(
                          appointment.patientName,

                          style:
                          const TextStyle(
                            fontWeight:
                            FontWeight
                                .w700,
                          ),
                        ),

                        const SizedBox(
                            height: 4),

                        Text(
                          appointment.notes ??
                              "Consultation",

                          style: TextStyle(
                            color: Colors
                                .grey.shade600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Container(

                    padding:
                    const EdgeInsets
                        .symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),

                    decoration:
                    BoxDecoration(
                      color:
                      statusColor.withOpacity(
                          0.10),

                      borderRadius:
                      BorderRadius
                          .circular(
                          8),
                    ),

                    child: Text(
                      appointment.status,

                      style: TextStyle(
                        color:
                        statusColor,
                        fontWeight:
                        FontWeight
                            .w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ================= RECENT PATIENTS =================

  Widget _recentPatientsCard() {

    return _cardBox(

      child: Column(

        crossAxisAlignment:
        CrossAxisAlignment.start,

        children: [

          Row(

            mainAxisAlignment:
            MainAxisAlignment
                .spaceBetween,

            children: [

              const Row(

                children: [

                  Icon(Icons.access_time),

                  SizedBox(width: 10),

                  Text(
                    "Recent Patients",

                    style: TextStyle(
                      fontSize: 18,
                      fontWeight:
                      FontWeight.w700,
                    ),
                  ),
                ],
              ),

              Text(
                "View all",

                style: TextStyle(
                  color:
                  Colors.blue.shade700,
                  fontWeight:
                  FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          ...patients.take(5).map(
                (patient) => Padding(

              padding:
              const EdgeInsets.only(
                bottom: 20,
              ),

              child: Row(

                children: [

                  CircleAvatar(
                    radius: 22,
                    backgroundColor:
                    const Color(
                        0xFFDBEAFE),

                    child: Text(
                      patient.firstName[0],

                      style:
                      const TextStyle(
                        color: Color(
                            0xFF2563EB),
                        fontWeight:
                        FontWeight
                            .w700,
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(

                    child: Column(

                      crossAxisAlignment:
                      CrossAxisAlignment
                          .start,

                      children: [

                        Text(
                          patient.fullName,

                          style:
                          const TextStyle(
                            fontWeight:
                            FontWeight
                                .w700,
                          ),
                        ),

                        const SizedBox(
                            height: 4),

                        Text(
                          patient.phone,

                          style:
                          TextStyle(
                            color: Colors
                                .grey
                                .shade600,
                            fontSize:
                            13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= PENDING TASKS =================

  Widget _pendingTasksCard() {

    return _cardBox(

      child: Column(

        crossAxisAlignment:
        CrossAxisAlignment.start,

        children: [

          Row(

            mainAxisAlignment:
            MainAxisAlignment
                .spaceBetween,

            children: [

              const Row(

                children: [

                  Icon(Icons.access_time),

                  SizedBox(width: 10),

                  Text(
                    "Pending Tasks",

                    style: TextStyle(
                      fontSize: 18,
                      fontWeight:
                      FontWeight.w700,
                    ),
                  ),
                ],
              ),

              Text(
                "View all",

                style: TextStyle(
                  color:
                  Colors.blue.shade700,
                  fontWeight:
                  FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          _taskTile(
            Icons.science_outlined,
            "Review Lab Reports",
            "3 pending",
            Colors.blue,
          ),

          _taskTile(
            Icons.notifications_none,
            "Follow-up Reminders",
            "2 pending",
            Colors.red,
          ),

          _taskTile(
            Icons.description_outlined,
            "Prescription Requests",
            "1 pending",
            Colors.blue,
          ),

          _taskTile(
            Icons.mark_chat_unread_outlined,
            "Unread Messages",
            "5 unread",
            Colors.orange,
          ),
        ],
      ),
    );
  }

  // ================= TASK TILE =================

  Widget _taskTile(
      IconData icon,
      String title,
      String status,
      Color color,
      ) {

    return Padding(

      padding:
      const EdgeInsets.only(
        bottom: 22,
      ),

      child: Row(

        children: [

          Container(

            padding:
            const EdgeInsets.all(10),

            decoration: BoxDecoration(
              color:
              color.withOpacity(0.10),

              borderRadius:
              BorderRadius.circular(
                  10),
            ),

            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Text(
              title,

              style: const TextStyle(
                fontWeight:
                FontWeight.w500,
              ),
            ),
          ),

          Text(
            status,

            style: TextStyle(
              color: Colors.red.shade400,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  // ================= UPCOMING APPOINTMENTS =================

  Widget _upcomingAppointmentsCard() {

    return _cardBox(

      child: Column(

        crossAxisAlignment:
        CrossAxisAlignment.start,

        children: [

          Row(

            mainAxisAlignment:
            MainAxisAlignment
                .spaceBetween,

            children: [

              const Row(

                children: [

                  Icon(Icons.calendar_today),

                  SizedBox(width: 10),

                  Text(
                    "Upcoming Appointments",

                    style: TextStyle(
                      fontSize: 18,
                      fontWeight:
                      FontWeight.w700,
                    ),
                  ),
                ],
              ),

              Text(
                "View calendar",

                style: TextStyle(
                  color:
                  Colors.blue.shade700,
                  fontWeight:
                  FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          Row(

            children: [

              Container(

                width: 90,
                height: 90,

                decoration: BoxDecoration(
                  color:
                  const Color(0xFFF3F4F6),

                  borderRadius:
                  BorderRadius.circular(
                      14),
                ),

                child: const Column(

                  mainAxisAlignment:
                  MainAxisAlignment
                      .center,

                  children: [

                    Text(
                      "24",

                      style: TextStyle(
                        fontSize: 34,
                        fontWeight:
                        FontWeight.w700,
                      ),
                    ),

                    Text(
                      "May",

                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 24),

              const Expanded(

                child: Column(

                  children: [

                    _AppointmentRow(
                      time: "02:00 PM",
                      patient:
                      "Vikram Gupta",
                      type:
                      "Consultation",
                    ),

                    SizedBox(height: 18),

                    _AppointmentRow(
                      time: "03:00 PM",
                      patient:
                      "Neha Agarwal",
                      type:
                      "Follow-up",
                    ),

                    SizedBox(height: 18),

                    _AppointmentRow(
                      time: "04:00 PM",
                      patient:
                      "Rajesh Kumar",
                      type: "ECG",
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }


  // ================= ACTION BOX =================

  Widget _actionBox(
      IconData icon,
      String title,
      Color color,
      ) {

    return Container(

      height: 120,

      decoration: BoxDecoration(
        color:
        color.withOpacity(0.08),

        borderRadius:
        BorderRadius.circular(16),

        border: Border.all(
          color:
          color.withOpacity(0.15),
        ),
      ),

      child: Column(

        mainAxisAlignment:
        MainAxisAlignment.center,

        children: [

          Icon(
            icon,
            color: color,
            size: 34,
          ),

          const SizedBox(height: 16),

          Text(
            title,

            textAlign: TextAlign.center,

            style: const TextStyle(
              fontWeight:
              FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ================= PROFILE =================

  static void _openProfile(
      BuildContext context,
      AuthProvider auth,
      ) {

    showDialog(

      context: context,

      builder: (_) => Dialog(

        shape: RoundedRectangleBorder(
          borderRadius:
          BorderRadius.circular(24),
        ),

        child: Container(

          width: 450,

          padding:
          const EdgeInsets.all(30),

          child: Column(

            mainAxisSize:
            MainAxisSize.min,

            children: [

              CircleAvatar(
                radius: 55,
                backgroundColor:
                Colors.blue.shade100,

                child: const Icon(
                  Icons.medical_services,
                  size: 50,
                  color: Colors.blue,
                ),
              ),

              const SizedBox(height: 20),

              Text(
                "Dr. ${auth.doctor?.fullName ?? ''}",

                style: const TextStyle(
                  fontSize: 26,
                  fontWeight:
                  FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                auth.doctor
                    ?.specialization ??
                    "",

                style: TextStyle(
                  color:
                  Colors.grey.shade700,
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 30),

              _profileTile(
                Icons.email,
                "Email",
                auth.doctor?.email ?? "",
              ),

              const SizedBox(height: 14),

              _profileTile(
                Icons.phone,
                "Phone",
                auth.doctor?.phone ?? "",
              ),

              const SizedBox(height: 14),

              _profileTile(
                Icons.currency_rupee,
                "Consultation Fee",
                "₹${auth.doctor?.consultationFee ?? 0}",
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= PROFILE TILE =================

  static Widget _profileTile(
      IconData icon,
      String title,
      String value,
      ) {

    return Container(

      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: const Color(0xFFF7F9FC),

        borderRadius:
        BorderRadius.circular(16),
      ),

      child: Row(

        children: [

          CircleAvatar(
            backgroundColor:
            Colors.blue.shade100,

            child: Icon(
              icon,
              color: Colors.blue,
            ),
          ),

          const SizedBox(width: 15),

          Expanded(

            child: Column(

              crossAxisAlignment:
              CrossAxisAlignment.start,

              children: [

                Text(
                  title,

                  style: TextStyle(
                    color:
                    Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  value,

                  style: const TextStyle(
                    fontWeight:
                    FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================= LOGOUT =================

  static void _confirmLogout(
      BuildContext context,
      AuthProvider auth,
      ) {

    showDialog(

      context: context,

      builder: (_) => AlertDialog(

        title: const Text("Logout"),

        content:
        const Text(
          "Are you sure you want to logout?",
        ),

        actions: [

          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },

            child: const Text("Cancel"),
          ),

          ElevatedButton(

            onPressed: () async {

              Navigator.pop(context);

              await auth.logout();
            },

            child: const Text("Logout"),
          ),
        ],
      ),
    );
  }
}

// ================= APPOINTMENT ROW =================

class _AppointmentRow extends StatelessWidget {

  final String time;
  final String patient;
  final String type;

  const _AppointmentRow({
    required this.time,
    required this.patient,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {

    return Row(

      children: [

        SizedBox(
          width: 90,

          child: Text(
            time,

            style: const TextStyle(
              fontWeight:
              FontWeight.w600,
            ),
          ),
        ),

        Expanded(
          child: Text(patient),
        ),

        Text(
          type,

          style: TextStyle(
            color:
            Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}