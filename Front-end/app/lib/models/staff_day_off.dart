class StaffDayOff {
  final String? uuid;
  final DateTime? date;
  final String? name;
  final String? staffUuid;
  final String? facilityUuid;
  final String? reason;
  final bool approved;

  StaffDayOff({
    this.uuid,
    this.date,
    this.name,
    this.staffUuid,
    this.facilityUuid,
    this.reason,
    this.approved = false,
  });

  factory StaffDayOff.fromJson(Map<String, dynamic> json) {
    return StaffDayOff(
      uuid: json['uuid'],
      date: json['date'] != null ? DateTime.parse(json['date']) : null,
      name: json['name'] ?? '',
      staffUuid: json['staffUuid']?.toString(),
      facilityUuid: json['facilityUuid']?.toString(),
      reason: json['reason'],
      approved: json['approved'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (uuid != null) 'uuid': uuid,
      'date': date?.toIso8601String().split('T')[0],
      'staffUuid': staffUuid,
      'facilityUuid': facilityUuid,
      'reason': reason,
    };
  }

  static List<StaffDayOff> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((e) => StaffDayOff.fromJson(e)).toList();
  }
}