class CustomerRequest {
  String mail;
  String password;
  String name;
  DateTime birthday;
  String gender;
  DateTime expiryDate;

  CustomerRequest({
    required this.mail,
    required this.password,
    required this.name,
    required this.birthday,
    required this.gender,
    required this.expiryDate,
  });

  Map<String, dynamic> toJson() {
    return {
      "mail": mail,
      "password": password,
      "name": name,
      "birthday": birthday.toIso8601String().split('T')[0],
      "gender": gender,
      "expiryDate": expiryDate.toIso8601String().split('T')[0],
    };
  }
}