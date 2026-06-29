import 'package:flutter/material.dart';
import '../../billing/services/billing_service.dart';
import '../../billing/models/invoice.dart';

class BillingOverviewScreen extends StatefulWidget {
  const BillingOverviewScreen({super.key});

  @override
  State<BillingOverviewScreen> createState() => _BillingOverviewScreenState();
}

class _BillingOverviewScreenState extends State<BillingOverviewScreen> {
  final BillingService _service = BillingService();

  bool _isLoading = true;
  String? _error;

  double _todayRevenue = 0;
  double _totalRevenue = 0;
  int _totalInvoices = 0;
  int _paidInvoices = 0;
  List<Invoice> _invoices = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _isLoading = true; _error = null; });

    try {
      final results = await Future.wait([
        _service.dio.get('/billing/revenue/today'),
        _service.dio.get('/billing/all'),
      ]);

      final todayRev = (results[0].data as num?)?.toDouble() ?? 0.0;
      final allInvoices = (results[1].data as List)
          .map((e) => Invoice.fromJson(e as Map<String, dynamic>))
          .toList();

      setState(() {
        _todayRevenue = todayRev;
        _totalRevenue = allInvoices.fold(0, (s, inv) => s + inv.paidAmount);
        _totalInvoices = allInvoices.length;
        _paidInvoices = allInvoices.where((i) => i.paymentStatus == 'PAID').length;
        _invoices = allInvoices;
        _isLoading = false;
      });
    } catch (e) {
      setState(() { _error = 'Failed to load billing data'; _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Billing Overview'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0.5,
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _load)],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? _buildError()
          : RefreshIndicator(
        onRefresh: _load,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSummaryCards(),
              const SizedBox(height: 24),
              _buildInvoiceList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.wifi_off, size: 48, color: Colors.red.shade300),
          const SizedBox(height: 12),
          Text(_error!, style: TextStyle(color: Colors.red.shade700)),
          const SizedBox(height: 12),
          ElevatedButton.icon(onPressed: _load, icon: const Icon(Icons.refresh), label: const Text('Retry')),
        ],
      ),
    );
  }

  Widget _buildSummaryCards() {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final cards = [
      _Card("Today's Revenue",  "₹${_todayRevenue.toStringAsFixed(0)}",  Icons.today,                Colors.orange),
      _Card("Total Revenue",    "₹${_totalRevenue.toStringAsFixed(0)}",  Icons.currency_rupee,       Colors.green),
      _Card("Total Invoices",   "$_totalInvoices",                        Icons.receipt_long,         Colors.blue),
      _Card("Paid Invoices",    "$_paidInvoices",                         Icons.check_circle_outline, Colors.purple),
    ];

    return GridView.count(
      crossAxisCount: isMobile ? 2 : 4,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: isMobile ? 1.4 : 1.6,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: cards.map(_buildTile).toList(),
    );
  }

  Widget _buildTile(_Card c) {
    return Container(
      padding: const EdgeInsets.all(18),
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
              Expanded(child: Text(c.label, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500))),
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(color: c.color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: Icon(c.icon, color: c.color, size: 22),
              ),
            ],
          ),
          Text(c.value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildInvoiceList() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('All Invoices', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text('${_invoices.length} total', style: const TextStyle(fontSize: 13, color: Colors.grey)),
              ],
            ),
          ),
          const Divider(height: 1),
          if (_invoices.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: Text('No invoices found', style: TextStyle(color: Colors.grey))),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _invoices.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (_, i) => _buildInvoiceTile(_invoices[i]),
            ),
        ],
      ),
    );
  }

  Widget _buildInvoiceTile(Invoice inv) {
    final isPaid = inv.paymentStatus == 'PAID';
    final statusColor = isPaid ? Colors.green : Colors.orange;

    return ExpansionTile(
      tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      leading: CircleAvatar(
        backgroundColor: statusColor.withOpacity(0.1),
        child: Text('#${inv.id}', style: TextStyle(fontSize: 11, color: statusColor, fontWeight: FontWeight.bold)),
      ),
      title: Text(inv.patientName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
      subtitle: Text(
        'Total: ₹${inv.totalAmount.toStringAsFixed(0)}  •  Paid: ₹${inv.paidAmount.toStringAsFixed(0)}',
        style: const TextStyle(fontSize: 12),
      ),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
        child: Text(inv.paymentStatus, style: TextStyle(fontSize: 11, color: statusColor, fontWeight: FontWeight.w600)),
      ),
      children: [
        if (inv.items.isNotEmpty) ...[
          const Align(
            alignment: Alignment.centerLeft,
            child: Text('Items', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          ),
          const SizedBox(height: 8),
          ...inv.items.map((item) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text('${item.itemName} × ${item.quantity}', style: const TextStyle(fontSize: 13))),
                Text('₹${item.total.toStringAsFixed(0)}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
              ],
            ),
          )),
          const Divider(height: 16),
        ],
        if (inv.dueAmount > 0)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Due', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600)),
              Text('₹${inv.dueAmount.toStringAsFixed(0)}', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            ],
          ),
      ],
    );
  }
}

class _Card {
  final String label, value;
  final IconData icon;
  final Color color;
  _Card(this.label, this.value, this.icon, this.color);
}