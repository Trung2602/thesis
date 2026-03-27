class Plan {
  final String? uuid;
  final String name;
  final int? price;
  final int? durationDays;
  final String? description;

  Plan({
    this.uuid,
    required this.name,
    this.price,
    this.durationDays,
    this.description,
  });

  factory Plan.fromJson(Map<String, dynamic> json) {
    return Plan(
      uuid: json['uuid'],
      name: json['name'] ?? '',
      price: json['price'] != null ? int.parse(json['price'].toString()) : null,
      durationDays: json['durationDays'] != null
          ? int.parse(json['durationDays'].toString())
          : null,
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uuid': uuid,
      'name': name,
      'price': price,
      'durationDays': durationDays,
      'description': description,
    };
  }
}