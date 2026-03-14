import 'package:gym/models/Facility.dart';

import 'account.dart';

class Staff extends Account {
  final DateTime? createdDate;
  final String staffType;
  final String facility;

  Staff({
    required super.id,
    required super.username,
    required String super.password,
    required super.name,
    required super.birthday,
    required bool super.gender,
    required super.role,
    required super.mail,
    required super.avatar,
    required bool super.isActive,
    this.createdDate,
    required this.staffType,
    required this.facility,
  });

  factory Staff.fromJson(Map<String, dynamic> json) {
    return Staff(
      id: json['id'],
      username: json['username'],
      password: json['password'],
      name: json['name'] ?? '',
      birthday: json['birthday'] != null ? DateTime.parse(json['birthday']) : null,
      gender: json['gender'],
      role: json['role'] ?? '',
      mail: json['mail'] ?? '',
      avatar: json['avatar'] ?? '',
      isActive: json['isActive'],
      createdDate: json['createdDate'] != null ? DateTime.parse(json['createdDate']) : null,
      staffType: json['staffTypeName'],
      facility: json['facilityName'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final data = super.toJson();
    data['createdDate'] = createdDate?.toIso8601String();
    return data;
  }
}
