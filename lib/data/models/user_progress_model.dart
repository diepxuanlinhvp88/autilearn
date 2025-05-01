import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserProgressModel extends Equatable {
  final String id;
  final String userId;
  final String quizId;
  final int score;
  final int totalQuestions;
  final List<QuestionAttempt> attempts;
  final DateTime completedAt;
  final int timeSpentSeconds;
  final int starsEarned;

  const UserProgressModel({
    required this.id,
    required this.userId,
    required this.quizId,
    required this.score,
    required this.totalQuestions,
    required this.attempts,
    required this.completedAt,
    required this.timeSpentSeconds,
    required this.starsEarned,
  });

  factory UserProgressModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    List<QuestionAttempt> attempts = [];
    if (data['attempts'] != null) {
      attempts = List<QuestionAttempt>.from(
        (data['attempts'] as List).map(
          (attempt) => QuestionAttempt.fromMap(attempt),
        ),
      );
    }

    return UserProgressModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      quizId: data['quizId'] ?? '',
      score: data['score'] ?? 0,
      totalQuestions: data['totalQuestions'] ?? 0,
      attempts: attempts,
      completedAt: (data['completedAt'] as Timestamp).toDate(),
      timeSpentSeconds: data['timeSpentSeconds'] ?? 0,
      starsEarned: data['starsEarned'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'quizId': quizId,
      'score': score,
      'totalQuestions': totalQuestions,
      'attempts': attempts.map((attempt) => attempt.toMap()).toList(),
      'completedAt': Timestamp.fromDate(completedAt),
      'timeSpentSeconds': timeSpentSeconds,
      'starsEarned': starsEarned,
    };
  }

  double get percentageScore => (score / totalQuestions) * 100;

  UserProgressModel copyWith({
    String? id,
    String? userId,
    String? quizId,
    int? score,
    int? totalQuestions,
    List<QuestionAttempt>? attempts,
    DateTime? completedAt,
    int? timeSpentSeconds,
    int? starsEarned,
  }) {
    return UserProgressModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      quizId: quizId ?? this.quizId,
      score: score ?? this.score,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      attempts: attempts ?? this.attempts,
      completedAt: completedAt ?? this.completedAt,
      timeSpentSeconds: timeSpentSeconds ?? this.timeSpentSeconds,
      starsEarned: starsEarned ?? this.starsEarned,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        quizId,
        score,
        totalQuestions,
        attempts,
        completedAt,
        timeSpentSeconds,
        starsEarned,
      ];
}

class QuestionAttempt extends Equatable {
  final String questionId;
  final bool isCorrect;
  final String userAnswer;
  final int attemptCount;
  final int timeSpentSeconds;

  const QuestionAttempt({
    required this.questionId,
    required this.isCorrect,
    required this.userAnswer,
    required this.attemptCount,
    required this.timeSpentSeconds,
  });

  factory QuestionAttempt.fromMap(Map<String, dynamic> map) {
    return QuestionAttempt(
      questionId: map['questionId'] ?? '',
      isCorrect: map['isCorrect'] ?? false,
      userAnswer: map['userAnswer'] ?? '',
      attemptCount: map['attemptCount'] ?? 0,
      timeSpentSeconds: map['timeSpentSeconds'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'questionId': questionId,
      'isCorrect': isCorrect,
      'userAnswer': userAnswer,
      'attemptCount': attemptCount,
      'timeSpentSeconds': timeSpentSeconds,
    };
  }

  @override
  List<Object?> get props => [
        questionId,
        isCorrect,
        userAnswer,
        attemptCount,
        timeSpentSeconds,
      ];
}
