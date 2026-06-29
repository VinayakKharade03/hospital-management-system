class LabResultValueUpdateRequest {
  final int parameterId;
  final String value;

  LabResultValueUpdateRequest({required this.parameterId, required this.value});

  Map<String, dynamic> toJson() => {
    'parameterId': parameterId,
    'value': value,
  };
}