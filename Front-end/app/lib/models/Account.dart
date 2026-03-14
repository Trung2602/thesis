class Account {
  final int id;
  final String username;
  final String password;
  final String name;
  final DateTime? birthday;
  final bool gender;
  final String role;
  final String mail;
  final String avatar;
  final bool isActive;
  final String? type;
  final DateTime? expiryDate;

  Account({
    required this.id,
    required this.username,
    required this.password,
    required this.name,
    required this.birthday,
    required this.gender,
    required this.role,
    required this.mail,
    required this.avatar,
    required this.isActive,
    this.type,
    this.expiryDate,
  });

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
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
      type: json['type'],
      expiryDate: json['expiryDate'] != null ? DateTime.parse(json['expiryDate']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'password': password,
      'name': name,
      'birthday': birthday?.toIso8601String(),
      'gender': gender,
      'role': role,
      'mail': mail,
      'avatar': avatar,
      'isActive': isActive,
      'type': type,
      'expiryDate': expiryDate?.toIso8601String(),
    };
  }
}
