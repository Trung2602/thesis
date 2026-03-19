import 'dart:convert';
import 'package:http/http.dart' as http;

class Plan {
  final String? uuid;
  final String? name;
  final int? price;
  final int? durationDays;
  final String? description;

  Plan({
    this.uuid,
    this.name,
    this.price,
    this.durationDays,
    this.description,
  });

  factory Plan.fromJson(Map<String, dynamic> json) {
    return Plan(
      uuid: json['uuid'],
      name: json['name'],
      price: json['price'],
      durationDays: json['durationDays'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uuid': uuid,
      'name': name,
      'price': price,
      'durationDays': durationDays,
      'description': description,
    };
  }
}
