// lib/modules/pharmacy/screens/pharmacy_home_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../auth/providers/auth_provider.dart';
import '../models/medicine.dart';
import '../models/medicine_stock.dart';
import '../providers/pharmacy_provider.dart';
import 'add_medicine_screen.dart';
import 'add_stock_screen.dart';
import 'dispense_prescription_screen.dart';

class PharmacyHomeScreen extends StatelessWidget {
  const PharmacyHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _PharmacyView();
  }
}

class _PharmacyView extends StatefulWidget {
  const _PharmacyView();

  @override
  State<_PharmacyView> createState() => _PharmacyViewState();
}

class _PharmacyViewState extends State<_PharmacyView> {
  // Navigation tracking index: 0 = Medicines, 1 = Available Stock, 2 = Expiring Stock
  int _selectedMenuIndex = 0;
  final TextEditingController _searchController = TextEditingController();

  // Helper method to format current date matching admin dashboard style exactly
  String _formatAdminStyleDate() {
    final now = DateTime.now();
    final months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
    final monthStr = now.month >= 1 && now.month <= 12 ? months[now.month - 1] : "June";
    return "${now.day} $monthStr ${now.year}";
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final pharmacy = Provider.of<PharmacyProvider>(context);
    final token = auth.token ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ==========================================
          // 1. LEFT SIDEBAR NAVIGATION PANE
          // ==========================================
          Container(
            width: 260,
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // BRAND HEADER BLOCK WITH HOSPITAL LOGO
                Padding(
                  padding: const EdgeInsets.only(left: 8, bottom: 32, top: 8),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1976D2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.local_hospital_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "CareConnect",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1976D2),
                            ),
                          ),
                          Text(
                            "Pharmacy Module",
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Vertical Navigation Links
                _sidebarNavigationLink(
                  title: "Medicines",
                  icon: Icons.medication_outlined,
                  isSelected: _selectedMenuIndex == 0,
                  onTap: () => setState(() => _selectedMenuIndex = 0),
                ),
                const SizedBox(height: 8),
                _sidebarNavigationLink(
                  title: "Available Stock",
                  icon: Icons.inventory_2_outlined,
                  isSelected: _selectedMenuIndex == 1,
                  onTap: () => setState(() => _selectedMenuIndex = 1),
                ),
                const SizedBox(height: 8),
                _sidebarNavigationLink(
                  title: "Expiring Stock",
                  icon: Icons.warning_amber_rounded,
                  isSelected: _selectedMenuIndex == 2,
                  onTap: () => setState(() => _selectedMenuIndex = 2),
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
                  child: Divider(color: Color(0xFFE2E8F0)),
                ),

                // DISPENSE PRESCRIPTION INTEGRATED TO SIDEBAR
                _sidebarNavigationLink(
                  title: "Dispense Prescription",
                  icon: Icons.receipt_long_rounded,
                  isSelected: false,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const DispensePrescriptionScreen()),
                    );
                  },
                ),

                const Spacer(),

                // Pinned Universal Grey Logout Button Frame
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEEEEEE),
                      foregroundColor: const Color(0xFF616161),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () => _showLogoutDialog(context, auth),
                    icon: const Icon(Icons.logout, size: 18),
                    label: const Text("Logout", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),

          const VerticalDivider(width: 1, thickness: 1, color: Color(0xFFE2E8F0)),

          // ==========================================
          // 2. MAIN CANVAS CONTENT AREA
          // ==========================================
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Workspace Header Element
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _selectedMenuIndex == 0
                            ? "Pharmacy Management"
                            : _selectedMenuIndex == 1
                            ? "Current Active Stock"
                            : "Stock Alerts",
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF212121),
                        ),
                      ),

                      // Admin Dashboard Style Right Header Frame Block
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE2E8F0).withOpacity(0.5),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _formatAdminStyleDate(),
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF212121),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: const Color(0xFF1976D2),
                            child: Text(
                              auth.userId != null ? "U" : "P",
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  Expanded(
                    child: pharmacy.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : pharmacy.error != null
                        ? _errorView(pharmacy, token)
                        : _selectedMenuIndex == 0
                        ? _medicinesTab(context, pharmacy, token)
                        : _selectedMenuIndex == 1
                        ? _availableStockTab(pharmacy, token)
                        : _expiringTab(pharmacy, token),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===============================
  // REUSABLE SIDEBAR LINK WIDGET
  // ===============================
  Widget _sidebarNavigationLink({
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF1F5F9) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: isSelected ? Colors.black : Colors.grey.shade600),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? Colors.black : Colors.grey.shade700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===============================
  // ERROR VIEW
  // ===============================
  Widget _errorView(PharmacyProvider pharmacy, String token) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
        const SizedBox(height: 12),
        Text(pharmacy.error!, style: TextStyle(color: Colors.red.shade700, fontWeight: FontWeight.w500)),
        const SizedBox(height: 16),
        TextButton.icon(
          onPressed: () => pharmacy.refresh(token),
          icon: const Icon(Icons.refresh),
          label: const Text("Retry Connection"),
        ),
      ],
    );
  }

  // ===============================
  // MEDICINES TAB
  // ===============================
  Widget _medicinesTab(BuildContext context, PharmacyProvider pharmacy, String token) {
    final query = _searchController.text.trim().toLowerCase();
    final filtered = query.isEmpty
        ? pharmacy.medicines
        : pharmacy.medicines
        .where((m) => m.name.toLowerCase().contains(query))
        .toList();

    return RefreshIndicator(
      onRefresh: () => pharmacy.refresh(token),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Inline Search Field and Action Placement Area Block
          Row(
            children: [
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(right: 16),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: "Search medicines...",
                      prefixIcon: const Icon(Icons.search, size: 20),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.blue, width: 1.5),
                      ),
                    ),
                  ),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AddMedicineScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1976D2),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
                icon: const Icon(Icons.add, size: 20),
                label: const Text("Add Medicine", style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ],
          ),

          const SizedBox(height: 24),

          Expanded(
            child: filtered.isEmpty
                ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.medication_outlined, size: 56, color: Colors.grey),
                  SizedBox(height: 12),
                  Text("No medicines found", style: TextStyle(color: Colors.grey, fontSize: 15)),
                ],
              ),
            )
                : ListView.builder(
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final med = filtered[index];
                return _medicineCard(context, pharmacy, med);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _medicineCard(BuildContext context, PharmacyProvider pharmacy, Medicine med) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Icon(Icons.medication, color: Color(0xFF64748B)),
        ),
        title: Text(
            med.name,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            med.unitPrice != null ? "₹${med.unitPrice!.toStringAsFixed(2)} / unit" : "Price not set",
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          ),
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Color(0xFF64748B)),
          itemBuilder: (_) => const [
            PopupMenuItem(value: "stock", child: Text("Add Stock")),
            PopupMenuItem(value: "delete", child: Text("Delete")),
          ],
          onSelected: (value) async {
            if (value == "stock") {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AddStockScreen(medicine: med)),
              );
            } else if (value == "delete") {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text("Delete Medicine"),
                  content: Text("Delete \"${med.name}\"?"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text("Cancel"),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text("Delete"),
                    ),
                  ],
                ),
              );

              if (confirmed == true) {
                final success = await pharmacy.deleteMedicine(med.id);
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(success ? "Deleted" : "Failed to delete")),
                );
              }
            }
          },
        ),
      ),
    );
  }

  // ============================================
  // AVAILABLE STOCK VIEW
  // ============================================
  Widget _availableStockTab(PharmacyProvider pharmacy, String token) {
    final available = pharmacy.availableStock;

    if (available.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: 56, color: Colors.grey),
            SizedBox(height: 12),
            Text("No active inventory stock records found", style: TextStyle(color: Colors.grey, fontSize: 15)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => pharmacy.refresh(token),
      child: ListView.builder(
        itemCount: available.length,
        itemBuilder: (context, index) {
          final stock = available[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0F2FE),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(Icons.layers_outlined, color: Color(0xFF0369A1)),
              ),
              title: Text(
                  stock.medicineName,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  "Batch: ${stock.batchNumber}   •   Available Qty: ${stock.quantity}\n"
                      "Expires: ${stock.expiryDate != null ? '${stock.expiryDate!.day}/${stock.expiryDate!.month}/${stock.expiryDate!.year}' : '-'}",
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13, height: 1.4),
                ),
              ),
              isThreeLine: true,
            ),
          );
        },
      ),
    );
  }

  // ===============================
  // EXPIRING STOCK TAB
  // ===============================
  Widget _expiringTab(PharmacyProvider pharmacy, String token) {
    if (pharmacy.expiringStock.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.verified_outlined, size: 56, color: Colors.green),
            SizedBox(height: 12),
            Text("No medicines expiring soon", style: TextStyle(color: Colors.grey, fontSize: 15)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => pharmacy.refresh(token),
      child: ListView.builder(
        itemCount: pharmacy.expiringStock.length,
        itemBuilder: (context, index) {
          final stock = pharmacy.expiringStock[index];
          return _stockCard(stock);
        },
      ),
    );
  }

  Widget _stockCard(MedicineStock stock) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFFEF3C7),
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Icon(Icons.warning_amber_rounded, color: Color(0xFFD97706)),
        ),
        title: Text(
            stock.medicineName,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(
            "Batch: ${stock.batchNumber}   •   Qty: ${stock.quantity}\n"
                "Expires: ${stock.expiryDate != null ? '${stock.expiryDate!.day}/${stock.expiryDate!.month}/${stock.expiryDate!.year}' : '-'}",
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13, height: 1.4),
          ),
        ),
        isThreeLine: true,
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AuthProvider auth) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Logout"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF5350),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              Navigator.pop(context);
              await auth.logout();
            },
            child: const Text("Logout", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}