import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../auth/models/user_role.dart';
import '../../auth/providers/auth_provider.dart';

import '../models/doctor.dart';
import '../services/doctor_service.dart';
import 'add_edit_doctor_screen.dart';

class DoctorsScreen extends StatefulWidget {
  const DoctorsScreen({super.key});

  @override
  State<DoctorsScreen> createState() => _DoctorsScreenState();
}

class _DoctorsScreenState extends State<DoctorsScreen> {
  final DoctorService _service = DoctorService();

  List<Doctor> doctors = [];
  List<Doctor> filteredDoctors = [];

  int page = 0;
  bool isLast = false;
  bool isLoading = false;
  String? error;

  final searchController = TextEditingController();

  String selectedSpecialization = "ALL";

  final List<String> specializations = [
    "ALL",
    "Cardiology",
    "Neurology",
    "Orthopedic",
    "General"
  ];

  @override
  void initState() {
    super.initState();
    fetchDoctors();
  }

  Future<void> fetchDoctors() async {
    if (isLast || isLoading) return;

    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final response = await _service.getDoctors(page);

      setState(() {
        doctors.addAll(response["data"]);
        filteredDoctors = doctors;
        isLast = response["last"];
        page++;
      });
    } catch (e) {
      setState(() => error = e.toString());
    } finally {
      setState(() => isLoading = false);
    }
  }

  void filterDoctors() {
    final query = searchController.text.toLowerCase();

    setState(() {
      filteredDoctors = doctors.where((doc) {
        final matchesName =
        doc.fullName.toLowerCase().contains(query);

        final matchesSpecialization =
            selectedSpecialization == "ALL" ||
                doc.specialization == selectedSpecialization;

        return matchesName && matchesSpecialization;
      }).toList();
    });
  }

  Future<void> deleteDoctor(int id) async {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Doctor"),
        content: const Text("Are you sure you want to delete?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);

              try {
                await _service.deleteDoctor(id);

                setState(() {
                  doctors.removeWhere((d) => d.id == id);
                  filterDoctors();
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Doctor deleted"),
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(e.toString()),
                  ),
                );
              }
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  void openForm([Doctor? doctor]) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddEditDoctorScreen(
          doctor: doctor,
        ),
      ),
    ).then((_) {
      setState(() {
        doctors.clear();
        filteredDoctors.clear();
        page = 0;
        isLast = false;
      });

      fetchDoctors();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    // ✅ ONLY ADMIN CAN MANAGE DOCTORS
    final bool isAdmin = auth.role == UserRole.ADMIN;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Doctors"),
      ),

      // ✅ HIDE ADD BUTTON FOR NON-ADMIN
      floatingActionButton: isAdmin
          ? FloatingActionButton(
        onPressed: () => openForm(),
        child: const Icon(Icons.add),
      )
          : null,

      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [

            // SEARCH
            TextField(
              controller: searchController,
              decoration: const InputDecoration(
                labelText: "Search by name",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => filterDoctors(),
            ),

            const SizedBox(height: 10),

            // FILTER
            DropdownButtonFormField<String>(
              value: selectedSpecialization,
              decoration: const InputDecoration(
                labelText: "Filter by specialization",
                border: OutlineInputBorder(),
              ),
              items: specializations
                  .map(
                    (e) => DropdownMenuItem(
                  value: e,
                  child: Text(e),
                ),
              )
                  .toList(),
              onChanged: (val) {
                setState(() {
                  selectedSpecialization = val!;
                });

                filterDoctors();
              },
            ),

            const SizedBox(height: 10),

            if (error != null)
              Text(
                error!,
                style: const TextStyle(color: Colors.red),
              ),

            Expanded(
              child: NotificationListener<ScrollNotification>(
                onNotification: (scrollInfo) {
                  if (!isLoading &&
                      scrollInfo.metrics.pixels ==
                          scrollInfo.metrics.maxScrollExtent) {
                    fetchDoctors();
                  }

                  return true;
                },
                child: ListView.builder(
                  itemCount:
                  filteredDoctors.length + (isLoading ? 1 : 0),
                  itemBuilder: (context, index) {

                    // LOADING
                    if (index >= filteredDoctors.length) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(10),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    final doc = filteredDoctors[index];

                    return Card(
                      elevation: 3,
                      child: ListTile(
                        title: Text(doc.fullName),

                        subtitle: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Text(doc.specialization),
                            Text("₹ ${doc.consultationFee}"),
                          ],
                        ),

                        // ✅ ONLY ADMIN CAN EDIT/DELETE
                        trailing: isAdmin
                            ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [

                            // EDIT
                            IconButton(
                              icon: const Icon(
                                Icons.edit,
                                color: Colors.blue,
                              ),
                              onPressed: () => openForm(doc),
                            ),

                            // DELETE
                            IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.red,
                              ),
                              onPressed: () =>
                                  deleteDoctor(doc.id),
                            ),
                          ],
                        )
                            : null,
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}