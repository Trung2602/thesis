class Facility {
  final String? uuid;
  final String? name;
  final String? address;

  Facility({
    this.uuid,
    this.name,
    this.address,
  });

  factory Facility.fromJson(Map<String, dynamic> json) {
    return Facility(
      uuid: json['uuid'],
      name: json['name'],
      address: json['address'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uuid': uuid,
      'name': name,
      'address': address,
    };
  }
}
