import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BadgeModel extends Equatable {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final String category;
  final int requiredPoints;
  final bool isDefault;
  final bool isUnlocked;
  final DateTime? unlockedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const BadgeModel({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.category,
    required this.requiredPoints,
    required this.isDefault,
    this.isUnlocked = false,
    this.unlockedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BadgeModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return BadgeModel(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      category: data['category'] ?? '',
      requiredPoints: data['requiredPoints'] ?? 0,
      isDefault: data['isDefault'] ?? false,
      isUnlocked: data['isUnlocked'] ?? false,
      unlockedAt: data['unlockedAt'] != null ? (data['unlockedAt'] as Timestamp).toDate() : null,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'category': category,
      'requiredPoints': requiredPoints,
      'isDefault': isDefault,
      'isUnlocked': isUnlocked,
      'unlockedAt': unlockedAt != null ? Timestamp.fromDate(unlockedAt!) : null,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  BadgeModel copyWith({
    String? id,
    String? name,
    String? description,
    String? imageUrl,
    String? category,
    int? requiredPoints,
    bool? isDefault,
    bool? isUnlocked,
    DateTime? unlockedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BadgeModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      requiredPoints: requiredPoints ?? this.requiredPoints,
      isDefault: isDefault ?? this.isDefault,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    imageUrl,
    category,
    requiredPoints,
    isDefault,
    isUnlocked,
    unlockedAt,
    createdAt,
    updatedAt,
  ];
}

// Các loại huy hiệu
class BadgeCategories {
  static const String completion = 'completion';
  static const String streak = 'streak';
  static const String mastery = 'mastery';
  static const String special = 'special';
}
