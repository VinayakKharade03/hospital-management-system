class Availability {
  final int id;

  // ✅ IMPORTANT
  final int doctorId;

  final String dayOfWeek;
  final String startTime;
  final String endTime;
  final int slotDurationMinutes;

  Availability({
    required this.id,
    required this.doctorId,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    required this.slotDurationMinutes,
  });

  factory Availability.fromJson(Map<String, dynamic> json) {
    return Availability(
      id: json['id'],

      // ✅ IMPORTANT
      doctorId: json['doctorId'],

      dayOfWeek: json['dayOfWeek'],
      startTime: json['startTime'],
      endTime: json['endTime'],
      slotDurationMinutes: json['slotDurationMinutes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'doctorId': doctorId,
      'dayOfWeek': dayOfWeek,
      'startTime': startTime,
      'endTime': endTime,
      'slotDurationMinutes': slotDurationMinutes,
    };
  }
}