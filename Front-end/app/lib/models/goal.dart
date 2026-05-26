class Goal {
  final String? uuid;
  final String? customerUuid;
  final String goalType;
  final double? targetWeight;
  final double? targetBodyFat;
  final DateTime? deadline;
  final bool? isAchieved;
  final DateTime? createdAt;

  Goal({
    this.uuid,
    this.customerUuid,
    required this.goalType,
    this.targetWeight,
    this.targetBodyFat,
    this.deadline,
    this.isAchieved,
    this.createdAt,
  });

  factory Goal.fromJson(Map<String, dynamic> json) => Goal(
    uuid: json['uuid'],
    customerUuid: json['customerUuid'],
    goalType: json['goalType'],
    targetWeight: json['targetWeight'] != null
        ? (json['targetWeight'] as num).toDouble()
        : null,
    targetBodyFat: json['targetBodyFat'] != null
        ? (json['targetBodyFat'] as num).toDouble()
        : null,
    deadline:
    json['deadline'] != null ? DateTime.tryParse(json['deadline']) : null,
    isAchieved: json['isAchieved'],
    createdAt: json['createdAt'] != null
        ? DateTime.tryParse(json['createdAt'])
        : null,
  );

  Map<String, dynamic> toJson() => {
    'goalType': goalType,
    'targetWeight': targetWeight,
    'targetBodyFat': targetBodyFat,
    'deadline': deadline?.toIso8601String().split('T').first,
  };
}