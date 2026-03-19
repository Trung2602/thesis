import 'package:flutter/material.dart';

class StaffDayOff {
  final String? uuid;
  final DateTime? date;

  final String? staffUuid;
  final String? staffName;

  StaffDayOff({
    this.uuid,
    this.date,
    this.staffUuid,
    this.staffName,
  });

  factory StaffDayOff.fromJson(Map<String, dynamic> json) {
    return StaffDayOff(
      uuid: json['uuid'],
      date: json['date'] != null ? DateTime.parse(json['date']) : null,
      staffUuid: json['staffUuid'],
      staffName: json['staffName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uuid': uuid,
      'date': date?.toIso8601String().split('T')[0], // yyyy-MM-dd
      'staffUuid': staffUuid,
      'staffName': staffName,
    };
  }

  static List<StaffDayOff> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((e) => StaffDayOff.fromJson(e)).toList();
  }
}
