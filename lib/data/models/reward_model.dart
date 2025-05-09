import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RewardModel extends Equatable {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final String type;
  final int cost;
  final bool isPurchased;
  final DateTime? purchasedAt;

  const RewardModel({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.type,
    required this.cost,
    this.isPurchased = false,
    this.purchasedAt,
  });

  factory RewardModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return RewardModel(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      type: data['type'] ?? '',
      cost: data['cost'] ?? 0,
      isPurchased: data['isPurchased'] ?? false,
      purchasedAt: data['purchasedAt'] != null ? (data['purchasedAt'] as Timestamp).toDate() : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'type': type,
      'cost': cost,
      'isPurchased': isPurchased,
      'purchasedAt': purchasedAt != null ? Timestamp.fromDate(purchasedAt!) : null,
    };
  }

  RewardModel copyWith({
    String? id,
    String? name,
    String? description,
    String? imageUrl,
    String? type,
    int? cost,
    bool? isPurchased,
    DateTime? purchasedAt,
  }) {
    return RewardModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      type: type ?? this.type,
      cost: cost ?? this.cost,
      isPurchased: isPurchased ?? this.isPurchased,
      purchasedAt: purchasedAt ?? this.purchasedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        imageUrl,
        type,
        cost,
        isPurchased,
        purchasedAt,
      ];
}

// Các loại phần thưởng
class RewardTypes {
  static const String avatar = 'avatar';
  static const String background = 'background';
  static const String character = 'character';
  static const String accessory = 'accessory';
  static const String theme = 'theme';
}
