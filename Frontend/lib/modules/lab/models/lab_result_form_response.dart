// lib/modules/lab/models/lab_result_form_response.dart

class LabResultParameter {
  final int parameterId; // Ensure this matches the ID from your backend
  final String parameterName;
  final String? value;
  final String? unit;
  final String? normalRange;

  LabResultParameter({
    required this.parameterId,
    required this.parameterName,
    this.value,
    this.unit,
    this.normalRange,
  });

  factory LabResultParameter.fromJson(Map<String, dynamic> json) {
    return LabResultParameter(
      parameterId: json['id'] ?? json['parameterId'], // Adjust key to match your API JSON
      parameterName: json['parameterName'] ?? '',
      value: json['value'],
      unit: json['unit'],
      normalRange: json['normalRange'],
    );
  }

  Map<String, dynamic> toJson() => {
    'parameterId': parameterId,
    'value': value,
  };
}

// ADDED: this class was used by lab_service.dart and lab_provider.dart
// (Future<LabResultFormResponse>, LabResultFormResponse.fromJson) but was
// never defined, which made the project fail to compile.
class LabResultFormResponse {
  final int orderId;
  final String testName;
  final List<LabResultParameter> parameters;

  LabResultFormResponse({
    required this.orderId,
    required this.testName,
    required this.parameters,
  });

  factory LabResultFormResponse.fromJson(Map<String, dynamic> json) {
    final rawParams = (json['parameters'] as List?) ?? const [];
    return LabResultFormResponse(
      orderId: json['orderId'] ?? json['id'] ?? 0,
      testName: json['testName'] ?? '',
      parameters: rawParams
          .map((p) => LabResultParameter.fromJson(p as Map<String, dynamic>))
          .toList(),
    );
  }
}