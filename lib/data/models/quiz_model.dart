import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class QuizModel extends Equatable {
  final String id;
  final String title;
  final String description;
  final String type; // 'choices', 'pairing', 'sequential'
  final String category;
  final String difficulty; // 'easy', 'medium', 'hard'
  final String creatorId;
  final bool isPublished;
  final bool isCompleted;
  final int questionCount;
  final double? score;
  final int ageRangeMin;
  final int ageRangeMax;
  final String? imageUrl;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime updatedAt;

  const QuizModel({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.category,
    required this.difficulty,
    required this.creatorId,
    required this.isPublished,
    this.isCompleted = false,
    required this.questionCount,
    this.score,
    required this.ageRangeMin,
    required this.ageRangeMax,
    this.imageUrl,
    this.tags = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  factory QuizModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return QuizModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      type: data['type'] ?? '',
      category: data['category'] ?? '',
      difficulty: data['difficulty'] ?? '',
      creatorId: data['creatorId'] ?? '',
      isPublished: data['isPublished'] ?? false,
      isCompleted: data['isCompleted'] ?? false,
      questionCount: data['questionCount'] ?? 0,
      score: data['score']?.toDouble(),
      ageRangeMin: data['ageRangeMin'] ?? 0,
      ageRangeMax: data['ageRangeMax'] ?? 0,
      imageUrl: data['imageUrl'],
      tags: List<String>.from(data['tags'] ?? []),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'type': type,
      'category': category,
      'difficulty': difficulty,
      'creatorId': creatorId,
      'isPublished': isPublished,
      'isCompleted': isCompleted,
      'questionCount': questionCount,
      'score': score,
      'ageRangeMin': ageRangeMin,
      'ageRangeMax': ageRangeMax,
      'imageUrl': imageUrl,
      'tags': tags,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  QuizModel copyWith({
    String? id,
    String? title,
    String? description,
    String? type,
    String? category,
    String? difficulty,
    String? creatorId,
    bool? isPublished,
    bool? isCompleted,
    int? questionCount,
    double? score,
    int? ageRangeMin,
    int? ageRangeMax,
    String? imageUrl,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return QuizModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      category: category ?? this.category,
      difficulty: difficulty ?? this.difficulty,
      creatorId: creatorId ?? this.creatorId,
      isPublished: isPublished ?? this.isPublished,
      isCompleted: isCompleted ?? this.isCompleted,
      questionCount: questionCount ?? this.questionCount,
      score: score ?? this.score,
      ageRangeMin: ageRangeMin ?? this.ageRangeMin,
      ageRangeMax: ageRangeMax ?? this.ageRangeMax,
      imageUrl: imageUrl ?? this.imageUrl,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        type,
        category,
        difficulty,
        creatorId,
        isPublished,
        isCompleted,
        questionCount,
        score,
        ageRangeMin,
        ageRangeMax,
        imageUrl,
        tags,
        createdAt,
        updatedAt,
      ];
}
