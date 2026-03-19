class StaffRequest {
  String mail;
  String password;
  String name;
  DateTime birthday;
  String gender;
  double baseSalary;
  String type;
  String facilityUuid;

  StaffRequest({
    required this.mail,
    required this.password,
    required this.name,
    required this.birthday,
    required this.gender,
    required this.baseSalary,
    required this.type,
    required this.facilityUuid,
  });

  Map<String, dynamic> toJson() {
    return {
      "mail": mail,
      "password": password,
      "name": name,
      "birthday": birthday.toIso8601String().split('T')[0],
      "gender": gender,
      "baseSalary": baseSalary,
      "type": type,
      "facilityUuid": facilityUuid,
    };
  }
}