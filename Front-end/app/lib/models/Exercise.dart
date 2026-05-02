class Exercise {
  final String? uuid;
  final String? name;
  final String? force;
  final String? difficulty;
  final String? mechanic;
  final String? equipment;
  final List<String>? primaryMuscles;
  final List<String>? secondaryMuscles;
  final List<String>? instructions;
  final List<String>? images;
  final String? category;

  Exercise({
    this.uuid,
    this.name,
    this.force,
    this.difficulty,
    this.mechanic,
    this.equipment,
    this.primaryMuscles,
    this.secondaryMuscles,
    this.instructions,
    this.images,
    this.category,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) => Exercise(
    uuid: json['uuid'],
    name: json['name'],
    force: json['force'],
    difficulty: json['difficulty'],
    mechanic: json['mechanic'],
    equipment: json['equipment'],
    primaryMuscles: (json['primaryMuscles'] as List?)?.map((e) => e.toString()).toList(),
    secondaryMuscles: (json['secondaryMuscles'] as List?)?.map((e) => e.toString()).toList(),
    instructions: (json['instructions'] as List?)?.map((e) => e.toString()).toList(),
    images: (json['images'] as List?)?.map((e) => e.toString()).toList(),
    category: json['category'],
  );
}