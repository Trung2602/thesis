class UuidName {
  final String uuid;
  final String name;

  UuidName({
    required this.uuid,
    required this.name,
  });

  factory UuidName.fromJson(Map<String, dynamic> json) {
    return UuidName(
      uuid: json['uuid'],
      name: json['name'],
    );
  }
}