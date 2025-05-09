import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BadgeModel extends Equatable {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final String category;
  final int requiredPoints;
  final bool isUnlocked;
  final DateTime? unlockedAt;

  const BadgeModel({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.category,
    required this.requiredPoints,
    this.isUnlocked = false,
    this.unlockedAt,
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
      isUnlocked: data['isUnlocked'] ?? false,
      unlockedAt: data['unlockedAt'] != null ? (data['unlockedAt'] as Timestamp).toDate() : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'category': category,
      'requiredPoints': requiredPoints,
      'isUnlocked': isUnlocked,
      'unlockedAt': unlockedAt != null ? Timestamp.fromDate(unlockedAt!) : null,
    };
  }

  BadgeModel copyWith({
    String? id,
    String? name,
    String? description,
    String? imageUrl,
    String? category,
    int? requiredPoints,
    bool? isUnlocked,
    DateTime? unlockedAt,
  }) {
    return BadgeModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      requiredPoints: requiredPoints ?? this.requiredPoints,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
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
        isUnlocked,
        unlockedAt,
      ];
}

// Các loại huy hiệu
class BadgeCategories {
  static const String completion = 'completion';
  static const String streak = 'streak';
  static const String mastery = 'mastery';
  static const String special = 'special';
}
