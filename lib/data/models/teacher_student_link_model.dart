import 'package:cloud_firestore/cloud_firestore.dart';

class TeacherStudentLink {
  final String id;
  final String teacherId;
  final String studentId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;

  TeacherStudentLink({
    required this.id,
    required this.teacherId,
    required this.studentId,
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'teacherId': teacherId,
      'studentId': studentId,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isActive': isActive,
    };
  }

  factory TeacherStudentLink.fromMap(String id, Map<String, dynamic> map) {
    return TeacherStudentLink(
      id: id,
      teacherId: map['teacherId'] ?? '',
      studentId: map['studentId'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
      isActive: map['isActive'] ?? true,
    );
  }
} 