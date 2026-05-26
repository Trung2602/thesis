class StaffSchedule {
  final String? uuid;
  final DateTime? date;
  final String? staffUuid;
  final String? staffName;
  final String? facilityUuid;
  final String? shiftUuid;
  final String? shiftName;
  final bool approved;

  StaffSchedule({
    this.uuid,
    this.date,
    this.staffUuid,
    this.staffName,
    this.facilityUuid,
    this.shiftUuid,
    this.shiftName,
    this.approved = false,
  });

  factory StaffSchedule.fromJson(Map<String, dynamic> json) {
    return StaffSchedule(
      uuid: json['uuid'],
      date: json['date'] != null ? DateTime.parse(json['date']) : null,
      staffUuid: json['staffUuid']?.toString(),
      staffName: json['staffName'] ?? '',
      facilityUuid: json['facilityUuid']?.toString(),
      shiftUuid: json['shiftUuid']?.toString(),
      shiftName: json['shiftName'] ?? '',
      approved: json['approved'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uuid': uuid,
      'date': date?.toIso8601String().split('T')[0],
      'staffUuid': staffUuid,
      'facilityUuid': facilityUuid,
      'shiftUuid': shiftUuid,
    };
  }
}