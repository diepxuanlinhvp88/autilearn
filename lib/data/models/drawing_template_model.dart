import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DrawingTemplateModel extends Equatable {
  final String id;
  final String title;
  final String description;
  final String imageUrl; // URL của hình ảnh mẫu
  final String outlineImageUrl; // URL của hình ảnh đường viền để tô màu
  final String creatorId;
  final String category; // Danh mục của mẫu vẽ (động vật, phong cảnh, v.v.)
  final int difficulty; // Độ khó (1-5)
  final bool isPublished;
  final DateTime createdAt;
  final DateTime updatedAt;

  const DrawingTemplateModel({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.outlineImageUrl,
    required this.creatorId,
    required this.category,
    required this.difficulty,
    required this.isPublished,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DrawingTemplateModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    print('Drawing template data: $data');

    final createdAt = data['createdAt'];
    final updatedAt = data['updatedAt'];

    return DrawingTemplateModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      outlineImageUrl: data['outlineImageUrl'] ?? '',
      creatorId: data['creatorId'] ?? '',
      category: data['category'] ?? '',
      difficulty: data['difficulty'] ?? 1,
      isPublished: data['isPublished'] ?? false,
      createdAt: createdAt is Timestamp ? createdAt.toDate() : DateTime.now(),
      updatedAt: updatedAt is Timestamp ? updatedAt.toDate() : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'outlineImageUrl': outlineImageUrl,
      'creatorId': creatorId,
      'category': category,
      'difficulty': difficulty,
      'isPublished': isPublished,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  DrawingTemplateModel copyWith({
    String? id,
    String? title,
    String? description,
    String? imageUrl,
    String? outlineImageUrl,
    String? creatorId,
    String? category,
    int? difficulty,
    bool? isPublished,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DrawingTemplateModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      outlineImageUrl: outlineImageUrl ?? this.outlineImageUrl,
      creatorId: creatorId ?? this.creatorId,
      category: category ?? this.category,
      difficulty: difficulty ?? this.difficulty,
      isPublished: isPublished ?? this.isPublished,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    imageUrl,
    outlineImageUrl,
    creatorId,
    category,
    difficulty,
    isPublished,
    createdAt,
    updatedAt,
  ];
}
