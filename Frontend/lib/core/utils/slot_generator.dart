class TimeSlot {
  final String start;
  final String end;

  TimeSlot(this.start, this.end);
}

class SlotGenerator {
  static List<TimeSlot> generateSlots({
    required String startTime,
    required String endTime,
    required int duration,
  }) {
    final List<TimeSlot> slots = [];

    DateTime start = _parseTime(startTime);
    final DateTime end = _parseTime(endTime);

    while (start.isBefore(end)) {
      final next = start.add(Duration(minutes: duration));

      if (next.isAfter(end)) break;

      slots.add(TimeSlot(
        _formatTime(start),
        _formatTime(next),
      ));

      start = next;
    }

    return slots;
  }

  static DateTime _parseTime(String time) {
    final parts = time.split(":");
    return DateTime(
      0,
      0,
      0,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );
  }

  static String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final min = time.minute.toString().padLeft(2, '0');
    return "$hour:$min";
  }
}