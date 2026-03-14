import 'dart:convert';

class Shift {
  final int id;
  final String name;
  final DateTime? checkin;
  final DateTime? checkout;
  final double? duration;

  Shift({
    required this.id,
    required this.name,
    this.checkin,
    this.checkout,
    this.duration,
  });

  /// Parse từ JSON (API trả về)
  factory Shift.fromJson(Map<String, dynamic> json) {
    return Shift(
      id: json['id'] as int,
      name: json['name'] as String,
      checkin: json['checkin'] != null ? DateTime.parse("1970-01-01T${json['checkin']}") : null,
      checkout: json['checkout'] != null ? DateTime.parse("1970-01-01T${json['checkout']}") : null,
      duration: (json['duration'] as num?)?.toDouble(),
    );
  }

  /// Convert ngược lại thành JSON để gửi lên API
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'checkin': checkin != null ? checkin!.toIso8601String().substring(11, 16) : null, // "HH:mm"
      'checkout': checkout != null ? checkout!.toIso8601String().substring(11, 16) : null,
      'duration': duration,
    };
  }
}
