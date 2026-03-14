import 'dart:convert';
import 'package:http/http.dart' as http;

class Plan {
  final int id;
  final String name;
  final double price;
  final int durationDays;
  final String description;

  Plan({
    required this.id,
    required this.name,
    required this.price,
    required this.durationDays,
    required this.description,
  });

  factory Plan.fromJson(Map<String, dynamic> json) {
    return Plan(
      id: json['id'],
      name: json['name'],
      price: (json['price'] as num).toDouble(),
      durationDays: json['durationDays'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'durationDays': durationDays,
      'description': description,
    };
  }
}
