import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../auth/providers/auth_provider.dart';
import '../../auth/models/user_role.dart';
import '../../billing/screen/BillingOverviewScreen.dart';
import '../../pharamcy/screens/pharmacy_screen.dart';
import '../users/screens/create_user_screen.dart';
import '../../doctor/screens/doctors_screen.dart';
import '../../patient/screens/patients_screen.dart';
import '../../appointment/screen/appointments_screen.dart';
import '../providers/dashboard_provider.dart';

enum _NavItem { dashboard, doctors, patients, appointments, billing, pharmacy, users }

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DashboardProvider(),
      child: const _DashboardView(),
    );
  }
}

class _DashboardView extends StatefulWidget {
  const _DashboardView();

  @override
  State<_DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<_DashboardView> {
  _NavItem _active = _NavItem.dashboard;

  void _navigate(BuildContext context, _NavItem item, Widget? screen) {
    setState(() => _active = item);
    if (screen != null) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => screen)).then((_) {
        setState(() => _active = _NavItem.dashboard);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      drawer: isMobile ? _buildDrawer(context, auth) : null,
      body: isMobile
          ? _buildMobileLayout(context, auth)
          : _buildDesktopLayout(context, auth),
    );
  }

  // ── MOBILE ────────────────────────────────────────────────────────────────

  Widget _buildMobileLayout(BuildContext context, AuthProvider auth) {
    final dashboard = Provider.of<DashboardProvider>(context);
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: dashboard.refresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              _buildTopBar(context, auth, isMobile: true),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildWelcomeHeader(auth),
                    const SizedBox(height: 24),
                    _buildStatisticsCards(context),
                    const SizedBox(height: 24),
                    _buildQuickActions(context),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context, AuthProvider auth) {
    return Drawer(child: _buildSidebarContent(context, auth));
  }

  // ── DESKTOP ───────────────────────────────────────────────────────────────

  Widget _buildDesktopLayout(BuildContext context, AuthProvider auth) {
    return Row(
      children: [
        SizedBox(
          width: 250,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(2, 0))],
            ),
            child: SafeArea(child: _buildSidebarContent(context, auth)),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildTopBar(context, auth, isMobile: false),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      _buildWelcomeHeader(auth),
                      const SizedBox(height: 24),
                      _buildStatisticsCards(context),
                      const SizedBox(height: 24),
                      _buildQuickActions(context),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── SIDEBAR ───────────────────────────────────────────────────────────────

  Widget _buildSidebarContent(BuildContext context, AuthProvider auth) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade400, Colors.blue.shade600],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.add, color: Colors.white),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("CareConnect", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text("Admin Module", style: TextStyle(fontSize: 10, color: Colors.grey)),
                ],
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 8),
                _sidebarItem(context, _NavItem.dashboard,    Icons.dashboard,      "Dashboard",    null),
                _sidebarItem(context, _NavItem.doctors,      Icons.people,          "Doctors",      const DoctorsScreen()),
                _sidebarItem(context, _NavItem.patients,     Icons.people_outline,  "Patients",     const PatientsScreen()),
                _sidebarItem(context, _NavItem.appointments, Icons.calendar_today,  "Appointments", const AppointmentsScreen()),
                _sidebarItem(context, _NavItem.billing,      Icons.receipt_long,    "Billing",      const BillingOverviewScreen()),
                _sidebarItem(context, _NavItem.pharmacy,     Icons.local_pharmacy,  "Pharmacy",     const PharmacyScreen()),
                _sidebarItem(context, _NavItem.users,        Icons.person,          "Users",        const CreateUserScreen()),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
        const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: GestureDetector(
            onTap: () => _showLogoutDialog(context, auth),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
              child: Row(
                children: [
                  Icon(Icons.logout, color: Colors.grey.shade600, size: 20),
                  const SizedBox(width: 12),
                  Text("Logout", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.grey.shade700)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _sidebarItem(BuildContext context, _NavItem item, IconData icon, String label, Widget? screen) {
    final isActive = _active == item;
    return GestureDetector(
      onTap: () => _navigate(context, item, screen),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? Colors.blue.shade50 : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: isActive ? Border(left: BorderSide(color: Colors.blue.shade600, width: 3)) : null,
        ),
        child: Row(
          children: [
            Icon(icon, color: isActive ? Colors.blue.shade600 : Colors.grey.shade600, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                  color: isActive ? Colors.blue.shade600 : Colors.grey.shade700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── TOP BAR ───────────────────────────────────────────────────────────────

  Widget _buildTopBar(BuildContext context, AuthProvider auth, {required bool isMobile}) {
    final initial = auth.role.displayName.isNotEmpty
        ? auth.role.displayName[0].toUpperCase()
        : (auth.userId?.toString() ?? 'A')[0];

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (isMobile)
            Builder(
              builder: (ctx) => IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () => Scaffold.of(ctx).openDrawer(),
              ),
            )
          else
            const Text("Admin", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black)),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
                child: Text(_formattedDate(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
              ),
              const SizedBox(width: 16),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'logout') _showLogoutDialog(context, auth);
                },
                itemBuilder: (_) => [
                  PopupMenuItem(
                    enabled: false,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(auth.role.displayName, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
                        if (auth.userId != null)
                          Text('ID: ${auth.userId}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
                  const PopupMenuItem(value: 'logout', child: Text('Logout')),
                ],
                child: Tooltip(
                  message: auth.role.displayName,
                  child: CircleAvatar(
                    backgroundColor: Colors.blue.shade100,
                    child: Text(initial, style: TextStyle(color: Colors.blue.shade700, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── WELCOME HEADER ────────────────────────────────────────────────────────

  Widget _buildWelcomeHeader(AuthProvider auth) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text("Welcome back, ", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500)),
            Text("${auth.role.displayName} 👋", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 8),
        const Text("Here's what's happening in your hospital today.", style: TextStyle(fontSize: 14, color: Colors.grey)),
      ],
    );
  }

  // ── STATISTICS CARDS ──────────────────────────────────────────────────────

  Widget _buildStatisticsCards(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    final dashboard = Provider.of<DashboardProvider>(context);

    if (dashboard.error != null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(12)),
        child: Column(
          children: [
            Icon(Icons.wifi_off, color: Colors.red.shade300, size: 36),
            const SizedBox(height: 8),
            Text(dashboard.error!, style: TextStyle(color: Colors.red.shade700), textAlign: TextAlign.center),
            const SizedBox(height: 8),
            TextButton.icon(onPressed: dashboard.refresh, icon: const Icon(Icons.refresh), label: const Text("Retry")),
          ],
        ),
      );
    }

    return GridView.count(
      crossAxisCount: isMobile ? 2 : 4,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: isMobile ? 1.3 : 1.7,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _statCard(
          title: "Total Doctors",
          value: dashboard.isLoading ? null : "${dashboard.totalDoctors}",
          icon: Icons.people,
          color: Colors.blue,
          actionText: "View all doctors",
          onTap: () => _navigate(context, _NavItem.doctors, const DoctorsScreen()),
        ),
        _statCard(
          title: "Total Patients",
          value: dashboard.isLoading ? null : "${dashboard.totalPatients}",
          icon: Icons.people_outline,
          color: Colors.green,
          actionText: "View all patients",
          onTap: () => _navigate(context, _NavItem.patients, const PatientsScreen()),
        ),
        _statCard(
          title: "Today's Appointments",
          value: dashboard.isLoading ? null : "${dashboard.todaysAppointments}",
          icon: Icons.calendar_today,
          color: Colors.purple,
          actionText: "View appointments",
          onTap: () => _navigate(context, _NavItem.appointments, const AppointmentsScreen()),
        ),
        _statCard(
          title: "Today's Revenue",
          value: dashboard.isLoading ? null : "₹${dashboard.totalRevenue.toStringAsFixed(0)}",
          icon: Icons.currency_rupee,
          color: Colors.orange,
          actionText: "View billing",
          onTap: () => _navigate(context, _NavItem.billing, const BillingOverviewScreen()),
        ),
      ],
    );
  }

  Widget _statCard({
    required String title,
    required String? value,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    required String actionText,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 8),
                      value == null
                          ? _shimmerBox(width: 50, height: 28)
                          : Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                Container(
                  width: 50, height: 50,
                  decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                  child: Icon(icon, color: color, size: 28),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(actionText, style: TextStyle(fontSize: 12, color: Colors.blue.shade600, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _shimmerBox({required double width, required double height}) {
    return Container(
      width: width, height: height,
      decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(4)),
    );
  }

  // ── QUICK ACTIONS — Generate Bill removed, Billing + Pharmacy added ────────

  Widget _buildQuickActions(BuildContext context) {
    final actions = [
      _QuickAction("Add Doctor",      Icons.person_add,      () => _navigate(context, _NavItem.doctors,      const DoctorsScreen())),
      _QuickAction("Add Patient",     Icons.person_add_alt,  () => _navigate(context, _NavItem.patients,     const PatientsScreen())),
      _QuickAction("New Appointment", Icons.calendar_today,  () => _navigate(context, _NavItem.appointments, const AppointmentsScreen())),
      _QuickAction("Create User",     Icons.manage_accounts, () => _navigate(context, _NavItem.users,        const CreateUserScreen())),
      _QuickAction("Billing",         Icons.receipt_long,    () => _navigate(context, _NavItem.billing,      const BillingOverviewScreen())),
      _QuickAction("Pharmacy Stock",  Icons.local_pharmacy,  () => _navigate(context, _NavItem.pharmacy,     const PharmacyScreen())),
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Quick Actions", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ...actions.map((a) => _quickActionItem(a.label, a.icon, a.onTap)),
        ],
      ),
    );
  }

  Widget _quickActionItem(String title, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
                  child: Icon(icon, color: Colors.blue.shade600),
                ),
                const SizedBox(width: 12),
                Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              ],
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }

  // ── LOGOUT ────────────────────────────────────────────────────────────────

  void _showLogoutDialog(BuildContext context, AuthProvider auth) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
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

  String _formattedDate() {
    final now = DateTime.now();
    const months = ['January','February','March','April','May','June',
      'July','August','September','October','November','December'];
    return '${now.day} ${months[now.month - 1]} ${now.year}';
  }
}

class _QuickAction {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  _QuickAction(this.label, this.icon, this.onTap);
}