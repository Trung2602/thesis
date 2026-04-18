class AccountLite {
  final String uuid;
  final String name;
  final String mail;
  final String role;

  AccountLite({
    required this.uuid,
    required this.name,
    required this.mail,
    required this.role,
  });

  factory AccountLite.fromJson(Map<String, dynamic> json) {
    return AccountLite(
      uuid: json['uuid'],
      name: json['name'],
      mail: json['mail'],
      role: json['role'],
    );
  }
}