import 'package:flutter/material.dart';
import '../models/medicine_stock.dart';
import '../service/medicine_stock_service.dart';

class PharmacyScreen extends StatefulWidget {
  const PharmacyScreen({super.key});

  @override
  State<PharmacyScreen> createState() => _PharmacyScreenState();
}

class _PharmacyScreenState extends State<PharmacyScreen> {
  final MedicineStockService _service = MedicineStockService();

  bool _isLoading = true;
  String? _error;

  List<MedicineStock> _available = [];
  List<MedicineStock> _expiring = [];

  String _search = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final results = await Future.wait([
        _service.getAvailableStock(),
        _service.getExpiring(30), // expiring within 30 days
      ]);

      setState(() {
        _available = results[0] as List<MedicineStock>;
        _expiring = results[1] as List<MedicineStock>;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load pharmacy data';
        _isLoading = false;
      });
    }
  }

  List<MedicineStock> get _filtered {
    if (_search.isEmpty) return _available;
    return _available
        .where((m) => m.medicineName.toLowerCase().contains(_search.toLowerCase()) ||
        m.batchNumber.toLowerCase().contains(_search.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Pharmacy'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0.5,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
        ],
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
              if (_expiring.isNotEmpty) ...[
                _buildExpiringBanner(),
                const SizedBox(height: 24),
              ],
              _buildStockTable(),
            ],
          ),
        ),
      ),
    );
  }

  // ── ERROR ─────────────────────────────────────────────────────────────────

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.wifi_off, size: 48, color: Colors.red.shade300),
          const SizedBox(height: 12),
          Text(_error!, style: TextStyle(color: Colors.red.shade700)),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: _load,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  // ── SUMMARY CARDS ─────────────────────────────────────────────────────────

  Widget _buildSummaryCards() {
    final totalQty = _available.fold<int>(0, (s, m) => s + m.quantity);
    final lowStock = _available.where((m) => m.quantity < 10).length;

    final isMobile = MediaQuery.of(context).size.width < 600;

    final cards = [
      _Card('Available Medicines', '${_available.length}', Icons.local_pharmacy, Colors.blue),
      _Card('Total Units', '$totalQty', Icons.inventory_2, Colors.green),
      _Card('Expiring Soon', '${_expiring.length}', Icons.warning_amber, Colors.orange),
      _Card('Low Stock', '$lowStock', Icons.trending_down, Colors.red),
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
                width: 40,
                height: 40,
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

  // ── EXPIRING BANNER ───────────────────────────────────────────────────────

  Widget _buildExpiringBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber, color: Colors.orange.shade700, size: 20),
              const SizedBox(width: 8),
              Text(
                '${_expiring.length} medicine${_expiring.length > 1 ? 's' : ''} expiring within 30 days',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange.shade800),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ..._expiring.map((m) {
            final daysLeft = m.expiryDate != null
                ? m.expiryDate!.difference(DateTime.now()).inDays
                : null;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      m.medicineName,
                      style: TextStyle(fontSize: 13, color: Colors.orange.shade900, fontWeight: FontWeight.w500),
                    ),
                  ),
                  Text(
                    daysLeft != null ? 'Expires in $daysLeft days' : 'Check expiry',
                    style: TextStyle(fontSize: 12, color: Colors.orange.shade700),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ── STOCK TABLE ───────────────────────────────────────────────────────────

  Widget _buildStockTable() {
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
                const Text('Available Stock', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text('${_filtered.length} items', style: const TextStyle(fontSize: 13, color: Colors.grey)),
              ],
            ),
          ),
          // Search
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              onChanged: (v) => setState(() => _search = v),
              decoration: InputDecoration(
                hintText: 'Search medicine or batch...',
                prefixIcon: const Icon(Icons.search, size: 20),
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade200)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade200)),
              ),
            ),
          ),
          const Divider(height: 1),
          if (_filtered.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: Text('No medicines found', style: TextStyle(color: Colors.grey))),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _filtered.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (_, i) => _buildStockTile(_filtered[i]),
            ),
        ],
      ),
    );
  }

  Widget _buildStockTile(MedicineStock m) {
    final isLow = m.quantity < 10;
    final isExpiringSoon = m.expiryDate != null &&
        m.expiryDate!.difference(DateTime.now()).inDays <= 30;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: isLow ? Colors.red.shade50 : Colors.blue.shade50,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          Icons.medication,
          color: isLow ? Colors.red.shade400 : Colors.blue.shade400,
          size: 22,
        ),
      ),
      title: Row(
        children: [
          Expanded(child: Text(m.medicineName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14))),
          if (isLow)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(20)),
              child: Text('Low Stock', style: TextStyle(fontSize: 10, color: Colors.red.shade600, fontWeight: FontWeight.w600)),
            ),
          if (isExpiringSoon && !isLow) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(20)),
              child: Text('Expiring', style: TextStyle(fontSize: 10, color: Colors.orange.shade700, fontWeight: FontWeight.w600)),
            ),
          ],
        ],
      ),
      subtitle: Text(
        'Batch: ${m.batchNumber}  •  Qty: ${m.quantity}'
            '${m.expiryDate != null ? '  •  Exp: ${_fmt(m.expiryDate!)}' : ''}',
        style: const TextStyle(fontSize: 12),
      ),
    );
  }

  String _fmt(DateTime d) => '${d.day.toString().padLeft(2, '0')}/'
      '${d.month.toString().padLeft(2, '0')}/${d.year}';
}

class _Card {
  final String label, value;
  final IconData icon;
  final Color color;
  _Card(this.label, this.value, this.icon, this.color);
}