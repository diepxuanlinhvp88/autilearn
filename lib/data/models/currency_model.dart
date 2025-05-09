import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CurrencyModel extends Equatable {
  final String userId;
  final int stars;
  final int coins;
  final int gems;
  final DateTime lastUpdated;

  const CurrencyModel({
    required this.userId,
    this.stars = 0,
    this.coins = 0,
    this.gems = 0,
    required this.lastUpdated,
  });

  factory CurrencyModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return CurrencyModel(
      userId: doc.id,
      stars: data['stars'] ?? 0,
      coins: data['coins'] ?? 0,
      gems: data['gems'] ?? 0,
      lastUpdated: data['lastUpdated'] != null 
          ? (data['lastUpdated'] as Timestamp).toDate() 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'stars': stars,
      'coins': coins,
      'gems': gems,
      'lastUpdated': Timestamp.fromDate(lastUpdated),
    };
  }

  CurrencyModel copyWith({
    String? userId,
    int? stars,
    int? coins,
    int? gems,
    DateTime? lastUpdated,
  }) {
    return CurrencyModel(
      userId: userId ?? this.userId,
      stars: stars ?? this.stars,
      coins: coins ?? this.coins,
      gems: gems ?? this.gems,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  @override
  List<Object?> get props => [
        userId,
        stars,
        coins,
        gems,
        lastUpdated,
      ];
}
