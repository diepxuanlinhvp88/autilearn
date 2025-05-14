import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DrawingModel extends Equatable {
  final String id;
  final String title;
  final String description;
  final String type; // 'free_drawing' hoặc 'template_drawing'
  final String creatorId;
  final String? imageUrl; // URL của hình ảnh đã vẽ
  final String? templateId; // ID của mẫu vẽ (nếu là template_drawing)
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  const DrawingModel({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.creatorId,
    this.imageUrl,
    this.templateId,
    this.isCompleted = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DrawingModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return DrawingModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      type: data['type'] ?? '',
      creatorId: data['creatorId'] ?? '',
      imageUrl: data['imageUrl'],
      templateId: data['templateId'],
      isCompleted: data['isCompleted'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'type': type,
      'creatorId': creatorId,
      'imageUrl': imageUrl,
      'templateId': templateId,
      'isCompleted': isCompleted,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  DrawingModel copyWith({
    String? id,
    String? title,
    String? description,
    String? type,
    String? creatorId,
    String? imageUrl,
    String? templateId,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DrawingModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      creatorId: creatorId ?? this.creatorId,
      imageUrl: imageUrl ?? this.imageUrl,
      templateId: templateId ?? this.templateId,
      isCompleted: isCompleted ?? this.isCompleted,
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
    creatorId,
    imageUrl,
    templateId,
    isCompleted,
    createdAt,
    updatedAt,
  ];
}
