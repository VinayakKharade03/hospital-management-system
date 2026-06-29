import 'package:flutter/material.dart';

import '../../availability/services/availability_service.dart';
import '../../availability/models/availability.dart';

import '../../../core/utils/slot_generator.dart';

import '../services/appointment_service.dart';

import '../../doctor/services/doctor_service.dart';
import '../../doctor/models/doctor.dart';

import '../../patient/services/patient_service.dart';
import '../../patient/models/patient.dart';

class AddEditAppointmentScreen
    extends StatefulWidget {

  final int? doctorId;
  final int? patientId;

  const AddEditAppointmentScreen({
    super.key,
    this.doctorId,
    this.patientId,
  });

  @override
  State<AddEditAppointmentScreen>
  createState() =>
      _AddEditAppointmentScreenState();
}

class _AddEditAppointmentScreenState
    extends State<AddEditAppointmentScreen> {

  final AppointmentService
  _appointmentService =
  AppointmentService();

  final AvailabilityService
  _availabilityService =
  AvailabilityService();

  final DoctorService
  _doctorService =
  DoctorService();

  final PatientService
  _patientService =
  PatientService();

  List<Doctor> doctors = [];
  List<Patient> patients = [];

  int? selectedDoctorId;
  int? selectedPatientId;

  Doctor? selectedDoctor;

  bool showBooking = false;

  DateTime? selectedDate;

  String? selectedSlot;

  List<Availability>
  availabilityList = [];

  List<TimeSlot> slots = [];

  List<String> bookedSlots = [];

  bool isLoadingLists = true;

  bool isLoadingAvailability = false;

  @override
  void initState() {
    super.initState();

    selectedDoctorId = widget.doctorId;
    selectedPatientId = widget.patientId;

    loadLists();
  }

  // ================= LOAD DOCTOR/PATIENT LISTS =================

  Future<void> loadLists() async {

    try {

      final doctorResponse =
      await _doctorService.getDoctors(0);

      final patientList =
      await _patientService.getPatients();

      setState(() {

        doctors = doctorResponse["data"];

        patients = patientList;

        isLoadingLists = false;
      });

      // ✅ IF DOCTOR PRE-SELECTED (e.g. passed in)

      if (selectedDoctorId != null) {

        selectedDoctor = doctors.firstWhere(
              (d) => d.id == selectedDoctorId,
          orElse: () => doctors.first,
        );

        await loadAvailability();

        await findAndSetNextAvailableDate();
      }

    } catch (e) {

      setState(() => isLoadingLists = false);

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            "Failed to load doctors/patients: $e",
          ),
        ),
      );
    }
  }

  // ================= ON DOCTOR SELECTED =================

  Future<void> onDoctorSelected(int? id) async {

    setState(() {

      selectedDoctorId = id;

      selectedDoctor = doctors.firstWhere(
            (d) => d.id == id,
      );

      // ✅ RESET BOOKING STATE

      showBooking = false;
      selectedDate = null;
      selectedSlot = null;
      slots = [];
      bookedSlots = [];
      availabilityList = [];
    });

    await loadAvailability();

    await findAndSetNextAvailableDate();
  }

  // ================= LOAD AVAILABILITY =================

  Future<void> loadAvailability() async {

    if (selectedDoctorId == null) return;

    try {

      setState(() => isLoadingAvailability = true);

      final data =
      await _availabilityService
          .getAvailability(
        selectedDoctorId!,
      );

      setState(() {

        availabilityList = data;

        isLoadingAvailability = false;
      });

    } catch (e) {

      setState(() => isLoadingAvailability = false);

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            "Failed to load availability: $e",
          ),
        ),
      );
    }
  }

  // ================= FIND NEXT AVAILABLE DATE =================

  Future<void> findAndSetNextAvailableDate() async {

    if (availabilityList.isEmpty) {

      setState(() {

        selectedDate = null;

        slots = [];

        showBooking = true;
      });

      return;
    }

    // ✅ SET OF DAYS DOCTOR IS AVAILABLE ON

    final availableDays = availabilityList
        .map((a) => a.dayOfWeek)
        .toSet();

    final today = DateTime.now();

    // ✅ SCAN NEXT 14 DAYS FOR A MATCHING AVAILABILITY DAY

    for (int i = 0; i < 14; i++) {

      final candidate =
      today.add(Duration(days: i));

      final day = _getDayOfWeek(candidate);

      if (availableDays.contains(day)) {

        selectedDate = candidate;

        showBooking = true;

        await generateSlots();

        return;
      }
    }

    // ✅ NO AVAILABLE DAY FOUND IN NEXT 14 DAYS

    setState(() {

      selectedDate = null;

      slots = [];

      showBooking = true;
    });
  }

  // ================= LOAD BOOKED SLOTS =================

  Future<void> loadBookedSlots() async {

    if (selectedDate == null ||
        selectedDoctorId == null) return;

    try {

      final data =
      await _appointmentService
          .getBookedSlots(
        selectedDoctorId!,
        selectedDate!
            .toString()
            .split(" ")[0],
      );

      setState(() {
        bookedSlots = data;
      });

    } catch (e) {

      bookedSlots = [];
    }
  }

  // ================= GENERATE SLOTS =================

  Future<void> generateSlots() async {

    if (selectedDate == null) return;

    final day =
    _getDayOfWeek(selectedDate!);

    final availability =
    availabilityList.where(
          (a) => a.dayOfWeek == day,
    ).toList();

    // ✅ NO AVAILABILITY

    if (availability.isEmpty) {

      setState(() {

        slots = [];

        selectedSlot = null;
      });

      return;
    }

    final selectedAvailability =
        availability.first;

    slots =
        SlotGenerator.generateSlots(

          startTime:
          selectedAvailability
              .startTime,

          endTime:
          selectedAvailability
              .endTime,

          duration:
          selectedAvailability
              .slotDurationMinutes,
        );

    // ✅ LOAD BOOKED SLOTS

    await loadBookedSlots();

    selectedSlot = null;

    setState(() {});
  }

  // ================= GET DAY =================

  String _getDayOfWeek(
      DateTime date,
      ) {

    const days = [

      "MONDAY",
      "TUESDAY",
      "WEDNESDAY",
      "THURSDAY",
      "FRIDAY",
      "SATURDAY",
      "SUNDAY",
    ];

    return days[date.weekday - 1];
  }

  // ================= SAVE =================

  Future<void> save() async {

    if (selectedDoctorId == null ||
        selectedPatientId == null) {

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            "Please select doctor and patient",
          ),
        ),
      );

      return;
    }

    if (selectedDate == null ||
        selectedSlot == null) {

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            "Please select date and slot",
          ),
        ),
      );

      return;
    }

    // ✅ SLOT ALREADY BOOKED

    if (bookedSlots
        .contains(selectedSlot)) {

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content:
          Text("Slot already booked"),
        ),
      );

      return;
    }

    try {

      setState(() => isLoadingAvailability = true);

      // ✅ GET SLOT START TIME (already in "HH:mm" 24-hour format)

      final startTime =
      selectedSlot!
          .split(" - ")[0];

      // ✅ CREATE DATETIME

      final appointmentDateTime =

          "${selectedDate!.toString().split(" ")[0]}T$startTime:00";

      final data = {

        "doctorId":
        selectedDoctorId,

        "patientId":
        selectedPatientId,

        "appointmentTime":
        appointmentDateTime,

        "notes":
        "Appointment booked from app",
      };

      await _appointmentService
          .createAppointment(data);

      if (mounted) {

        ScaffoldMessenger.of(context)
            .showSnackBar(
          const SnackBar(
            content: Text(
              "Appointment booked successfully",
            ),
          ),
        );

        Navigator.pop(context);
      }

    } catch (e) {

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content:
          Text("Error: $e"),
        ),
      );

    } finally {

      if (mounted) {

        setState(
              () => isLoadingAvailability = false,
        );
      }
    }
  }

  // ================= DOCTOR CARD =================

  Widget _doctorCard() {

    return InkWell(

      onTap: () {

        setState(() {
          showBooking = !showBooking;
        });
      },

      borderRadius: BorderRadius.circular(12),

      child: Container(

        width: double.infinity,

        padding: const EdgeInsets.all(16),

        decoration: BoxDecoration(
          color: Colors.white,

          borderRadius: BorderRadius.circular(12),

          border: Border.all(
            color: Colors.grey.shade300,
          ),
        ),

        child: Row(

          children: [

            CircleAvatar(
              radius: 28,

              backgroundColor:
              Colors.blue.shade50,

              child: const Icon(
                Icons.medical_services_outlined,
                color: Colors.blue,
              ),
            ),

            const SizedBox(width: 16),

            Expanded(

              child: Column(

                crossAxisAlignment:
                CrossAxisAlignment.start,

                children: [

                  Text(
                    "Dr. ${selectedDoctor?.fullName ?? ''}",

                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    selectedDoctor?.specialization ?? "",

                    style: TextStyle(
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),

            Icon(
              showBooking
                  ? Icons.keyboard_arrow_up
                  : Icons.keyboard_arrow_down,

              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title:
        const Text(
          "Book Appointment",
        ),
      ),

      body: isLoadingLists
          ? const Center(
        child:
        CircularProgressIndicator(),
      )
          : Padding(

        padding:
        const EdgeInsets.all(20),

        child: Column(

          crossAxisAlignment:
          CrossAxisAlignment.start,

          children: [

            // 👨‍⚕️ DOCTOR DROPDOWN

            DropdownButtonFormField<int>(

              value: selectedDoctorId,

              decoration: const InputDecoration(
                labelText: "Select Doctor",
                border: OutlineInputBorder(),
              ),

              items: doctors.map((d) {

                return DropdownMenuItem(
                  value: d.id,
                  child: Text(d.fullName),
                );
              }).toList(),

              onChanged: onDoctorSelected,
            ),

            const SizedBox(height: 16),

            // 🧑 PATIENT DROPDOWN

            DropdownButtonFormField<int>(

              value: selectedPatientId,

              decoration: const InputDecoration(
                labelText: "Select Patient",
                border: OutlineInputBorder(),
              ),

              items: patients.map((p) {

                return DropdownMenuItem(
                  value: p.id,
                  child: Text(
                    "${p.firstName} ${p.lastName}",
                  ),
                );
              }).toList(),

              onChanged: (val) {

                setState(() {
                  selectedPatientId = val;
                });
              },
            ),

            const SizedBox(height: 16),

            // 👨‍⚕️ DOCTOR CARD

            if (selectedDoctorId != null) ...[

              isLoadingAvailability
                  ? const Center(
                child: CircularProgressIndicator(),
              )
                  : _doctorCard(),
            ],

            if (showBooking &&
                !isLoadingAvailability) ...[

              const SizedBox(height: 20),

              // 📅 DATE PICKER (auto-set to next available date)

              SizedBox(

                width: double.infinity,

                child:
                ElevatedButton.icon(

                  icon: const Icon(
                    Icons.calendar_today,
                  ),

                  onPressed: () async {

                    final picked =
                    await showDatePicker(

                      context: context,

                      firstDate:
                      DateTime.now(),

                      lastDate:
                      DateTime(2100),

                      initialDate:
                      selectedDate ??
                          DateTime.now(),
                    );

                    if (picked != null) {

                      selectedDate =
                          picked;

                      await generateSlots();
                    }
                  },

                  label: Text(

                    selectedDate == null
                        ? "Select Date"
                        : selectedDate!
                        .toString()
                        .split(" ")[0],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ⏰ AVAILABLE SLOTS

              const Text(

                "Available Slots",

                style: TextStyle(
                  fontSize: 16,
                  fontWeight:
                  FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              slots.isEmpty

                  ? const Text(
                "No slots available",
              )

                  : Wrap(

                spacing: 10,
                runSpacing: 10,

                children:
                slots.map((slot) {

                  final label =
                      "${slot.start} - ${slot.end}";

                  final isBooked =
                  bookedSlots
                      .contains(label);

                  return ChoiceChip(

                    label:
                    Text(label),

                    selected:
                    selectedSlot ==
                        label,

                    selectedColor:
                    Colors.green,

                    disabledColor:
                    Colors.grey
                        .shade300,

                    onSelected:
                    isBooked
                        ? null
                        : (_) {

                      setState(() {

                        selectedSlot =
                            label;
                      });
                    },
                  );
                }).toList(),
              ),

              const Spacer(),

              // 💾 SAVE BUTTON

              SizedBox(

                width: double.infinity,
                height: 50,

                child:
                ElevatedButton(

                  onPressed:
                  isLoadingAvailability
                      ? null
                      : save,

                  child: const Text(
                    "Confirm Appointment",
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}