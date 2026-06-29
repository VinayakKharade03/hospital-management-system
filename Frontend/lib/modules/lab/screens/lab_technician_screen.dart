// lib/modules/lab/screens/lab_technician_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../auth/providers/auth_provider.dart';
import '../models/lab_test_order.dart';
import '../providers/lab_provider.dart';
import 'add_lab_result_screen.dart';

class LabTechnicianScreen extends StatelessWidget {
  const LabTechnicianScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _LabTechnicianView();
  }
}

class _LabTechnicianView extends StatelessWidget {
  const _LabTechnicianView();

  // Consistent color mapping based on existing application statuses
  Color _statusColor(String status) {
    switch (status.toUpperCase()) {
      case "COMPLETED": return const Color(0xFF2E7D32); // Green
      case "PENDING":   return const Color(0xFFE65100); // Orange/Amber
      case "ORDERED":   return const Color(0xFF1976D2); // CareConnect Blue
      default:          return Colors.grey;
    }
  }

  // Helper method to format current date matching admin dashboard style exactly
  String _formatAdminStyleDate() {
    final now = DateTime.now();
    final months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
    final monthStr = now.month >= 1 && now.month <= 12 ? months[now.month - 1] : "June";
    return "${now.day} $monthStr ${now.year}";
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final lab = Provider.of<LabProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Canvas background matching HMS
      body: Row(
        children: [
          // 1. Unified System Sidebar Navigation Drawer Wrapper
          _buildSidebar(context, auth),

          // Vertical layout divider line
          Container(width: 1, color: Colors.grey.shade200),

          // 2. Main Module View Workspace
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Custom Workspace Top Bar Header Frame (Admin Style Placement)
                _buildHeader(auth),

                // Content Canvas matching spacing in image_8c4903.png
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: lab.refresh,
                    child: _buildBody(context, lab),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar(BuildContext context, AuthProvider auth) {
    return Container(
      width: 260,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Unified Brand Header Block with Lab Subtitle
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
                  child: const Icon(Icons.add_box, color: Colors.white, size: 20),
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
                      "Lab Module",
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

          // Sidebar Items Frame (Active Module State)
          _sidebarItem(Icons.science, "Lab Orders", isActive: true),

          const Spacer(),

          // Help & Support pushed to the bottom right above the logout panel
          _sidebarItem(Icons.settings, "Help & Support"),
          const SizedBox(height: 12),

          // Pinned Universal Grey Logout Button Frame
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEEEEEE), // Light grey background
                foregroundColor: const Color(0xFF616161), // Dark grey icon/text color
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
    );
  }

  Widget _sidebarItem(IconData icon, String title, {bool isActive = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF1976D2).withOpacity(0.08) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        dense: true,
        leading: Icon(icon, color: isActive ? const Color(0xFF1976D2) : Colors.grey.shade600),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            color: isActive ? const Color(0xFF1976D2) : Colors.grey.shade800,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(AuthProvider auth) {
    final displayUserName = auth.userId != null ? "User #${auth.userId}" : "Lab Technician";
    final avatarInitial = displayUserName.contains("#") ? "U" : displayUserName[0].toUpperCase();

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left Frame: Clean screen title structure matching Admin layout
          const Text(
            "Lab Orders",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF212121)),
          ),

          // Right Frame: Date Badge and User Avatar Block placed cleanly together
          Row(
            children: [
              // Admin Styled Elegant Pill Container for Date Display
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F3F4),
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

              // User profile logo circle element frame matching top right admin dashboard location
              CircleAvatar(
                radius: 20,
                backgroundColor: const Color(0xFF1976D2),
                child: Text(
                  avatarInitial,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, LabProvider lab) {
    if (lab.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (lab.error != null) {
      return ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 100),
          Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
          const SizedBox(height: 12),
          Center(child: Text(lab.error!, style: TextStyle(color: Colors.red.shade700))),
          const SizedBox(height: 16),
          Center(
            child: ElevatedButton(onPressed: lab.refresh, child: const Text("Retry")),
          ),
        ],
      );
    }

    if (lab.orders.isEmpty) {
      return ListView(
        padding: const EdgeInsets.all(24),
        children: const [
          SizedBox(height: 120),
          Icon(Icons.science_outlined, size: 56, color: Colors.grey),
          SizedBox(height: 12),
          Center(child: Text("No lab orders yet", style: TextStyle(color: Colors.grey))),
        ],
      );
    }

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        if (lab.pendingOrders.isNotEmpty) ...[
          _sectionTitle("Pending (${lab.pendingOrders.length})"),
          const SizedBox(height: 12),
          ...([ ...lab.pendingOrders]
            ..sort((a, b) {
              if (a.orderedAt == null && b.orderedAt == null) return 0;
              if (a.orderedAt == null) return 1;
              if (b.orderedAt == null) return -1;
              return b.orderedAt!.compareTo(a.orderedAt!);
            }))
              .map((o) => _orderCard(context, o)),
          const SizedBox(height: 24),
        ],
        if (lab.completedOrders.isNotEmpty) ...[
          _sectionTitle("Completed (${lab.completedOrders.length})"),
          const SizedBox(height: 12),
          ...([ ...lab.completedOrders]
            ..sort((a, b) {
              if (a.orderedAt == null && b.orderedAt == null) return 0;
              if (a.orderedAt == null) return 1;
              if (b.orderedAt == null) return -1;
              return b.orderedAt!.compareTo(a.orderedAt!);
            }))
              .map((o) => _orderCard(context, o)),
        ],
      ],
    );
  }

  Widget _sectionTitle(String text) => Text(
    text,
    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF37474F)),
  );

  Widget _orderCard(BuildContext context, LabTestOrder order) {
    final isPending = order.status.toUpperCase() != "COMPLETED";

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16), // Match dashboard metric-card border radius
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        leading: CircleAvatar(
          radius: 22,
          backgroundColor: _statusColor(order.status).withOpacity(0.10),
          child: Icon(
            isPending ? Icons.hourglass_top : Icons.check_circle,
            color: _statusColor(order.status),
            size: 20,
          ),
        ),
        title: Text(
          order.testName,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF212121)),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Patient: ${order.patientName}", style: TextStyle(color: Colors.grey.shade800)),
              const SizedBox(height: 2),
              Text("Doctor: ${order.doctorName}", style: TextStyle(color: Colors.grey.shade800)),
              if (order.orderedAt != null) ...[
                const SizedBox(height: 4),
                Text(
                  order.orderedAt!.toLocal().toString().substring(0, 16),
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                ),
              ],
              const SizedBox(height: 8),
              // Pill Status Badge Styling
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: _statusColor(order.status).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  order.status,
                  style: TextStyle(
                    color: _statusColor(order.status),
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        ),
        trailing: isPending
            ? OutlinedButton(
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Color(0xFF1976D2)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => AddLabResultScreen(order: order)),
            );
          },
          child: const Text(
            "Add Result",
            style: TextStyle(color: Color(0xFF1976D2), fontWeight: FontWeight.bold),
          ),
        )
            : null,
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