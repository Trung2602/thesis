class BodyLog {
  final String? uuid;
  final String customerUuid;
  final String? staffUuid;
  final double weight;
  final double height;
  final double? bodyFatPercent;
  final double? muscleMass;
  final String? note;
  final DateTime? loggedAt;

  BodyLog({
    this.uuid,
    required this.customerUuid,
    this.staffUuid,
    required this.weight,
    required this.height,
    this.bodyFatPercent,
    this.muscleMass,
    this.note,
    this.loggedAt,
  });

  factory BodyLog.fromJson(Map<String, dynamic> json) => BodyLog(
    uuid: json['uuid'],
    customerUuid: json['customerUuid'],
    staffUuid: json['staffUuid'],
    weight: (json['weight'] as num).toDouble(),
    height: (json['height'] as num).toDouble(),
    bodyFatPercent: json['bodyFatPercent'] != null
        ? (json['bodyFatPercent'] as num).toDouble()
        : null,
    muscleMass: json['muscleMass'] != null
        ? (json['muscleMass'] as num).toDouble()
        : null,
    note: json['note'],
    loggedAt: json['loggedAt'] != null
        ? DateTime.tryParse(json['loggedAt'])
        : null,
  );

  Map<String, dynamic> toJson() => {
    'customerUuid': customerUuid,
    'staffUuid': staffUuid,
    'weight': weight,
    'height': height,
    'bodyFatPercent': bodyFatPercent,
    'muscleMass': muscleMass,
    'note': note,
  };
}