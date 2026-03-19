class Account {
  final String uuid;
  final String name;
  final DateTime? birthday;
  final String gender;
  final String role;
  final String mail;
  final String avatar;
  final bool isActive;

  final String? type;
  final DateTime? expiryDate;
  final String? facilityName;
  final double? baseSalary;

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
    this.expiryDate,
    this.facilityName,
    this.baseSalary,
  });

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      uuid: json['uuid'],
      name: json['name'] ?? '',
      birthday: json['birthday'] != null
          ? DateTime.parse(json['birthday'])
          : null,
      gender: json['gender'] ?? '',
      role: json['role'] ?? '',
      mail: json['mail'] ?? '',
      avatar: json['avatar'] ?? '',
      isActive: json['isActive'] ?? false,
      type: json['type'],
      expiryDate: json['expiryDate'] != null
          ? DateTime.parse(json['expiryDate']): null,
      facilityName: json['facilityName'],
      baseSalary: json['baseSalary'] != null
          ? double.parse(json['baseSalary'].toString()): null,
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
      'type': type,
      'expiryDate': expiryDate?.toIso8601String(),
      'facilityName': facilityName,
      'baseSalary': baseSalary,
    };
  }
}