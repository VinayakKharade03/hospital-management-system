// lib/modules/lab/screens/add_lab_result_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/lab_test_order.dart';
import '../models/lab_result_form_response.dart';
import '../models/lab_result_value_update_request.dart';
import '../providers/lab_provider.dart';

class AddLabResultScreen extends StatefulWidget {
  final LabTestOrder order;

  const AddLabResultScreen({super.key, required this.order});

  @override
  State<AddLabResultScreen> createState() => _AddLabResultScreenState();
}

class _AddLabResultScreenState extends State<AddLabResultScreen> {
  final List<_ParamRow> _rows = [];
  bool _loadingForm = true;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _loadForm();
  }

  Future<void> _loadForm() async {
    setState(() {
      _loadingForm = true;
      _loadError = null;
    });

    final lab = Provider.of<LabProvider>(context, listen: false);
    final LabResultFormResponse? form = await lab.fetchResultForm(widget.order.id);

    if (!mounted) return;

    if (form == null || form.parameters.isEmpty) {
      setState(() {
        _loadingForm = false;
        _loadError = "Could not load parameters for this test.";
      });
      return;
    }

    setState(() {
      _rows
        ..clear()
        ..addAll(form.parameters.map((p) => _ParamRow(
          parameterId: p.parameterId,
          parameterName: p.parameterName,
          unit: p.unit ?? "",
          normalRange: p.normalRange ?? "",
          valueCtrl: TextEditingController(text: p.value ?? ""),
        )));
      _loadingForm = false;
    });
  }

  @override
  void dispose() {
    for (final r in _rows) {
      r.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    final parameters = _rows
        .where((r) => r.valueCtrl.text.trim().isNotEmpty)
        .map((r) => LabResultValueUpdateRequest(
      parameterId: r.parameterId,
      value: r.valueCtrl.text.trim(),
    ))
        .toList();

    if (parameters.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter at least one parameter value")),
      );
      return;
    }

    final lab = Provider.of<LabProvider>(context, listen: false);
    final success = await lab.submitResult(widget.order.id, parameters);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lab result submitted successfully")),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to submit result. Try again.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final lab = Provider.of<LabProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Add Lab Result")),
      body: _loadingForm
          ? const Center(child: CircularProgressIndicator())
          : _loadError != null
          ? _errorView()
          : ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _orderSummaryCard(),
          const SizedBox(height: 20),
          const Text(
            "Result Parameters",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ..._rows.map((row) => _paramRow(row)),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: lab.isSubmitting ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade600,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: lab.isSubmitting
                  ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
                  : const Text(
                "Submit Result",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _errorView() {
    return ListView(
      children: [
        const SizedBox(height: 120),
        Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
        const SizedBox(height: 12),
        Center(
          child: Text(_loadError!, style: TextStyle(color: Colors.red.shade700)),
        ),
        const SizedBox(height: 12),
        Center(child: TextButton(onPressed: _loadForm, child: const Text("Retry"))),
      ],
    );
  }

  Widget _orderSummaryCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.order.testName,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text("Patient: ${widget.order.patientName}"),
            Text("Doctor: ${widget.order.doctorName}"),
          ],
        ),
      ),
    );
  }

  Widget _paramRow(_ParamRow row) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            row.parameterName,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 4,
                child: TextField(
                  controller: row.valueCtrl,
                  decoration: const InputDecoration(
                    labelText: "Value",
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              if (row.unit.isNotEmpty)
                Text(
                  row.unit,
                  style: TextStyle(color: Colors.grey.shade600),
                ),
            ],
          ),
          if (row.normalRange.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              "Normal range: ${row.normalRange}",
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }
}

class _ParamRow {
  final int parameterId;
  final String parameterName;
  final String unit;
  final String normalRange;
  final TextEditingController valueCtrl;

  _ParamRow({
    required this.parameterId,
    required this.parameterName,
    required this.unit,
    required this.normalRange,
    required this.valueCtrl,
  });

  void dispose() => valueCtrl.dispose();
}