import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserProgressModel extends Equatable {
  final String id;
  final String userId;
  final String quizId;
  final int score;
  final bool isCompleted;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final Map<String, dynamic>? answers;
  final int totalQuestions;
  final List<QuestionAttempt>? attempts;
  final int timeSpentSeconds;
  final int starsEarned;

  int get points => score;

  const UserProgressModel({
    required this.id,
    required this.userId,
    required this.quizId,
    required this.score,
    required this.isCompleted,
    this.startedAt,
    this.completedAt,
    this.answers,
    this.totalQuestions = 0,
    this.attempts,
    this.timeSpentSeconds = 0,
    this.starsEarned = 0,
  });

  factory UserProgressModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    // Parse attempts if available
    List<QuestionAttempt>? attempts;
    if (data['attempts'] != null) {
      attempts = (data['attempts'] as List)
          .map((item) => QuestionAttempt.fromMap(item as Map<String, dynamic>))
          .toList();
    }
    
    return UserProgressModel(
      id: doc.id,
      userId: data['userId'] as String,
      quizId: data['quizId'] as String,
      score: data['score'] as int? ?? 0,
      isCompleted: data['isCompleted'] as bool? ?? false,
      startedAt: (data['startedAt'] as Timestamp?)?.toDate(),
      completedAt: (data['completedAt'] as Timestamp?)?.toDate(),
      answers: data['answers'] as Map<String, dynamic>?,
      totalQuestions: data['totalQuestions'] as int? ?? 0,
      attempts: attempts,
      timeSpentSeconds: data['timeSpentSeconds'] as int? ?? 0,
      starsEarned: data['starsEarned'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'quizId': quizId,
      'score': score,
      'isCompleted': isCompleted,
      'startedAt': startedAt != null ? Timestamp.fromDate(startedAt!) : null,
      'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      'answers': answers,
      'totalQuestions': totalQuestions,
      'attempts': attempts?.map((a) => a.toMap()).toList(),
      'timeSpentSeconds': timeSpentSeconds,
      'starsEarned': starsEarned,
    };
  }

  UserProgressModel copyWith({
    String? id,
    String? userId,
    String? quizId,
    int? score,
    bool? isCompleted,
    DateTime? startedAt,
    DateTime? completedAt,
    Map<String, dynamic>? answers,
    int? totalQuestions,
    List<QuestionAttempt>? attempts,
    int? timeSpentSeconds,
    int? starsEarned,
  }) {
    return UserProgressModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      quizId: quizId ?? this.quizId,
      score: score ?? this.score,
      isCompleted: isCompleted ?? this.isCompleted,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      answers: answers ?? this.answers,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      attempts: attempts ?? this.attempts,
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
        isCompleted,
        startedAt,
        completedAt,
        answers,
        totalQuestions,
        attempts,
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
