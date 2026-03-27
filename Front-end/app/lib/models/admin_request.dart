class AdminRequest {
  String mail;
  String password;
  String name;
  DateTime birthday;
  String gender;
  String permissions;

  AdminRequest({
    required this.mail,
    required this.password,
    required this.name,
    required this.birthday,
    required this.gender,
    required this.permissions,
  });

  Map<String, dynamic> toJson() {
    return {
      "mail": mail,
      "password": password,
      "name": name,
      "birthday": birthday.toIso8601String().split('T')[0],
      "gender": gender,
      "permissions": permissions,
    };
  }
}