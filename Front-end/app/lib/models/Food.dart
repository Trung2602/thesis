class Food {
  final String? uuid;
  final int? code;
  final String? name;
  final String? category;
  final double? calories100g;

  Food({
    this.uuid,
    this.code,
    this.name,
    this.category,
    this.calories100g,
  });

  factory Food.fromJson(Map<String, dynamic> json) => Food(
    uuid: json['uuid'],
    code: json['code'],
    name: json['name'],
    category: json['category'],
    calories100g: (json['calories100g'] as num?)?.toDouble(),
  );
}