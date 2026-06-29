import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/models/user_role.dart';
import '../models/patient.dart';
import '../services/patient_service.dart';
import 'add_edit_patient_screen.dart';

class PatientsScreen extends StatefulWidget {
  const PatientsScreen({super.key});

  @override
  State<PatientsScreen> createState() => _PatientsScreenState();
}

class _PatientsScreenState extends State<PatientsScreen> {
  final PatientService _service = PatientService();

  List<Patient> patients = [];
  List<Patient> filtered = [];

  bool isLoading = true;

  final searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchPatients();
  }

  Future<void> fetchPatients() async {
    try {
      final data = await _service.getPatients();

      setState(() {
        patients = data;
        filtered = data;
        isLoading = false;
      });
    } catch (e) {
      print("ERROR: $e");
      setState(() => isLoading = false);
    }
  }

  void filterPatients() {
    final query = searchController.text.toLowerCase();

    setState(() {
      filtered = patients
          .where((p) => p.fullName.toLowerCase().contains(query))
          .toList();
    });
  }

  Future<void> deletePatient(int id) async {
    await _service.deletePatient(id);

    setState(() {
      patients.removeWhere((p) => p.id == id);
      filterPatients();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Patient deleted")),
    );
  }

  void openForm([Patient? patient]) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddEditPatientScreen(patient: patient),
      ),
    ).then((_) => fetchPatients());
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    // ✅ FIXED ROLE CHECK
    final canEdit = auth.role == UserRole.ADMIN ||
        auth.role == UserRole.RECEPTIONIST;

    final isAdmin = auth.role == UserRole.ADMIN;

    return Scaffold(
      appBar: AppBar(title: const Text("Patients")),

      floatingActionButton: canEdit
          ? FloatingActionButton(
        onPressed: () => openForm(),
        child: const Icon(Icons.add),
      )
          : null,

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            // 🔍 SEARCH
            TextField(
              controller: searchController,
              decoration: const InputDecoration(
                labelText: "Search patient",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => filterPatients(),
            ),

            const SizedBox(height: 10),

            // 📋 LIST
            Expanded(
              child: filtered.isEmpty
                  ? const Center(child: Text("No patients found"))
                  : ListView.builder(
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final p = filtered[index];

                  return Card(
                    child: ListTile(
                      title: Text(p.fullName),
                      subtitle:
                      Text("${p.gender} • ${p.phone}"),

                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (canEdit)
                            IconButton(
                              icon: const Icon(Icons.edit,
                                  color: Colors.blue),
                              onPressed: () => openForm(p),
                            ),

                          if (isAdmin)
                            IconButton(
                              icon: const Icon(Icons.delete,
                                  color: Colors.red),
                              onPressed: () =>
                                  deletePatient(p.id),
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
      ),
    );
  }
}