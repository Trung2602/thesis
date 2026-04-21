import 'dart:convert';

class Account {
  final String uuid;
  final String name;
  final DateTime? birthday;
  final String gender;
  final String role;
  final String mail;
  final String avatar;
  final bool isActive;

  // STAFF
  final String? type;
  final double? baseSalary;
  final String? facilityUuid;
  final String? facilityName;

  // CUSTOMER
  final double? weight;
  final double? height;
  final DateTime? expiryDate;

  Account({
    required this.uuid,
    required this.name,
    this.birthday,
    required this.gender,
    required this.role,
    required this.mail,
    required this.avatar,
    required this.isActive,
    this.type,
    this.baseSalary,
    this.facilityUuid,
    this.facilityName,
    this.weight,
    this.height,
    this.expiryDate,
  });

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      uuid: json['uuid'],
      name: json['name'] ?? '',
      birthday: json['birthday'] != null
          ? DateTime.parse(json['birthday'])
          : null,
      gender: json['gender'] ?? 'MALE',
      role: json['role'] ?? '',
      mail: json['mail'] ?? '',
      avatar: json['avatar'] ?? '',
      isActive: json['isActive'] ?? false,

      // STAFF
      type: json['type'],
      facilityUuid: json['facilityUuid'],
      facilityName: json['facilityName'],
      baseSalary: json['baseSalary'] != null
          ? double.parse(json['baseSalary'].toString())
          : null,

      // CUSTOMER
      weight: json['weight'] != null
          ? double.parse(json['weight'].toString())
          : null,
      height: json['height'] != null
          ? double.parse(json['height'].toString())
          : null,
      expiryDate: json['expiryDate'] != null
          ? DateTime.parse(json['expiryDate'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uuid': uuid,
      'name': name,
      'birthday': birthday?.toIso8601String(),
      'gender': gender,
      'role': role,
      'mail': mail,
      'avatar': avatar,
      'isActive': isActive,

      // STAFF
      'type': type,
      'baseSalary': baseSalary,
      'facilityUuid': facilityUuid,
      'facilityName': facilityName,

      // CUSTOMER
      'weight': weight,
      'height': height,
      'expiryDate': expiryDate?.toIso8601String(),
    };
  }
}