import 'account.dart';

class Customer extends Account {
  final DateTime? expiryDate;

  Customer({
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
    required this.expiryDate,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
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
      expiryDate: json['expiryDate'] != null ? DateTime.parse(json['expiryDate']) : null,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final data = super.toJson();
    data['expiryDate'] = expiryDate?.toIso8601String();
    return data;
  }
}
