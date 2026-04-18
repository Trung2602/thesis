class StaffDayOff {
  final String uuid;
  final DateTime date;
  final String? name;

  StaffDayOff({
    required this.uuid,
    required this.date,
    this.name,
  });

  factory StaffDayOff.fromJson(Map<String, dynamic> json) {
    return StaffDayOff(
      uuid: json['uuid'],
      date: DateTime.parse(json['date']),
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uuid': uuid,
      'date': date.toIso8601String().split('T')[0],
      'name': name,
    };
  }

  static List<StaffDayOff> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((e) => StaffDayOff.fromJson(e)).toList();
  }
}