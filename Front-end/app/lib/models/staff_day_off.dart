class StaffDayOff {
  final String uuid;
  final DateTime date;

  StaffDayOff({
    required this.uuid,
    required this.date,
  });

  factory StaffDayOff.fromJson(Map<String, dynamic> json) {
    return StaffDayOff(
      uuid: json['uuid'],
      date: DateTime.parse(json['date']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uuid': uuid,
      'date': date.toIso8601String().split('T')[0],
    };
  }

  static List<StaffDayOff> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((e) => StaffDayOff.fromJson(e)).toList();
  }
}