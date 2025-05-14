import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel extends Equatable {
  final String id;
  final String name;
  final String email;
  final String role; // 'parent', 'teacher', 'student'
  final String? avatarUrl;
  final String? currentBadgeId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.avatarUrl,
    this.currentBadgeId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    print('Creating UserModel from Firestore data: $data');

    // Ensure role is not null or empty
    final role = data['role'] ?? '';
    print('User role from Firestore: $role');

    return UserModel(
      id: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      role: role,
      avatarUrl: data['avatarUrl'],
      currentBadgeId: data['currentBadgeId'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    final map = {
      'name': name,
      'email': email,
      'role': role,
      'avatarUrl': avatarUrl,
      'currentBadgeId': currentBadgeId,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
    print('UserModel.toMap(): $map');
    return map;
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? role,
    String? avatarUrl,
    String? currentBadgeId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      currentBadgeId: currentBadgeId ?? this.currentBadgeId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory UserModel.fromMap(String id, Map<String, dynamic> map) {
    return UserModel(
      id: id,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? '',
      avatarUrl: map['avatarUrl'],
      currentBadgeId: map['currentBadgeId'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    email,
    role,
    avatarUrl,
    currentBadgeId,
    createdAt,
    updatedAt,
  ];
}
