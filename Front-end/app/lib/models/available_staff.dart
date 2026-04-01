class AvailableStaff {
  final String uuid;
  final String name;
  final String facilityUuid;

  AvailableStaff({
    required this.uuid,
    required this.name,
    required this.facilityUuid,
  });

  factory AvailableStaff.fromJson(Map<String, dynamic> json) {
    return AvailableStaff(
      uuid: json['uuid'] ?? '',
      name: json['name'] ?? '',
      facilityUuid: json['facilityUuid'] ?? '',
    );
  }

  // optional: toJson
  Map<String, dynamic> toJson() => {
    'uuid': uuid,
    'name': name,
    'facilityUuid': facilityUuid,
  };
}