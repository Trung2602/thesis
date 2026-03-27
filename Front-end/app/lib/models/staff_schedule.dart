class StaffSchedule {
  final String? uuid;
  final DateTime? date;

  final String? staffUuid;
  final String? staffName;

  final String? shiftUuid;
  final String? shiftName;

  StaffSchedule({
    this.uuid,
    this.date,
    this.staffUuid,
    this.staffName,
    this.shiftUuid,
    this.shiftName,
  });

  factory StaffSchedule.fromJson(Map<String, dynamic> json) {
    return StaffSchedule(
      uuid: json['uuid'],
      date: json['date'] != null ? DateTime.parse(json['date']) : null,
      staffUuid: json['staffUuid']?.toString(),
      staffName: json['staffName'] ?? '',
      shiftUuid: json['shiftUuid']?.toString(),
      shiftName: json['shiftName'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uuid': uuid,
      'date': date?.toIso8601String().split('T')[0],
      'staffUuid': staffUuid,
      'shiftUuid': shiftUuid,
    };
  }
}