import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  // Khởi tạo Firebase
  final firestore = FirebaseFirestore.instance;

  // Test quizzes index
  await firestore.collection('quizzes')
      .where('type', isEqualTo: 'emotions_quiz')
      .where('isPublished', isEqualTo: true)
      .get();

  // Test questions index
  await firestore.collection('questions')
      .where('quizId', isEqualTo: 'test')
      .orderBy('order', descending: false)
      .get();

  // Test user_progress index
  await firestore.collection('user_progress')
      .where('userId', isEqualTo: 'test')
      .orderBy('completedAt', descending: true)
      .get();

  // Test teacher_student_links index
  await firestore.collection('teacher_student_links')
      .where('teacherId', isEqualTo: 'test')
      .where('status', isEqualTo: 'active')
      .get();
} 