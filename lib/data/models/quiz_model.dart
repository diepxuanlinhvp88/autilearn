import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class QuizModel extends Equatable {
  final String id;
  final String title;
  final String description;
  final String type; // 'choices', 'pairing', 'sequential'
  final String creatorId;
  final String? imageUrl;
  final String difficulty; // 'easy', 'medium', 'hard'
  final List<String> tags;
  final bool isPublished;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int questionCount;
  final String? category;
  final int ageRangeMin;
  final int ageRangeMax;

  const QuizModel({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.creatorId,
    this.imageUrl,
    required this.difficulty,
    required this.tags,
    required this.isPublished,
    required this.createdAt,
    required this.updatedAt,
    required this.questionCount,
    this.category,
    required this.ageRangeMin,
    required this.ageRangeMax,
  });

  factory QuizModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return QuizModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      type: data['type'] ?? '',
      creatorId: data['creatorId'] ?? '',
      imageUrl: data['imageUrl'],
      difficulty: data['difficulty'] ?? '',
      tags: List<String>.from(data['tags'] ?? []),
      isPublished: data['isPublished'] ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      questionCount: data['questionCount'] ?? 0,
      category: data['category'],
      ageRangeMin: data['ageRangeMin'] ?? 3,
      ageRangeMax: data['ageRangeMax'] ?? 12,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'type': type,
      'creatorId': creatorId,
      'imageUrl': imageUrl,
      'difficulty': difficulty,
      'tags': tags,
      'isPublished': isPublished,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'questionCount': questionCount,
      'category': category,
      'ageRangeMin': ageRangeMin,
      'ageRangeMax': ageRangeMax,
    };
  }

  QuizModel copyWith({
    String? id,
    String? title,
    String? description,
    String? type,
    String? creatorId,
    String? imageUrl,
    String? difficulty,
    List<String>? tags,
    bool? isPublished,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? questionCount,
    String? category,
    int? ageRangeMin,
    int? ageRangeMax,
  }) {
    return QuizModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      creatorId: creatorId ?? this.creatorId,
      imageUrl: imageUrl ?? this.imageUrl,
      difficulty: difficulty ?? this.difficulty,
      tags: tags ?? this.tags,
      isPublished: isPublished ?? this.isPublished,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      questionCount: questionCount ?? this.questionCount,
      category: category ?? this.category,
      ageRangeMin: ageRangeMin ?? this.ageRangeMin,
      ageRangeMax: ageRangeMax ?? this.ageRangeMax,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        type,
        creatorId,
        imageUrl,
        difficulty,
        tags,
        isPublished,
        createdAt,
        updatedAt,
        questionCount,
        category,
        ageRangeMin,
        ageRangeMax,
      ];
}
