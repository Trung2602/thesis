class Salary {
  final String? uuid;
  final DateTime? date;
  final double? duration;
  final int? dayOff;
  final double? price;

  final String? staffUuid;
  final String staffName;

  Salary({
    this.uuid,
    this.date,
    this.duration,
    this.dayOff,
    this.price,
    this.staffUuid,
    required this.staffName,
  });

  factory Salary.fromJson(Map<String, dynamic> json) {
    return Salary(
      uuid: json['uuid'],
      date: json['date'] != null ? DateTime.parse(json['date']) : null,
      duration: json['duration'] != null
          ? double.parse(json['duration'].toString())
          : null,
      dayOff: json['dayOff'] != null
          ? int.parse(json['dayOff'].toString())
          : null,
      price: json['price'] != null
          ? double.parse(json['price'].toString())
          : null,
      staffUuid: json['staffUuid'],
      staffName: json['staffName'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uuid': uuid,
      'date': date?.toIso8601String().split('T')[0],
      'duration': duration,
      'dayOff': dayOff,
      'price': price,
      'staffUuid': staffUuid,
      'staffName': staffName,
    };
  }
}