import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AnalyticsModel extends Equatable {
  final String userId;
  final int totalQuizzesTaken;
  final int totalCorrectAnswers;
  final int totalQuestions;
  final int totalTimeSpentSeconds;
  final int totalStarsEarned;
  final Map<String, int> quizTypeDistribution;
  final Map<String, double> performanceByQuizType;
  final List<QuizPerformance> recentPerformance;
  final DateTime lastUpdated;

  const AnalyticsModel({
    required this.userId,
    this.totalQuizzesTaken = 0,
    this.totalCorrectAnswers = 0,
    this.totalQuestions = 0,
    this.totalTimeSpentSeconds = 0,
    this.totalStarsEarned = 0,
    this.quizTypeDistribution = const {},
    this.performanceByQuizType = const {},
    this.recentPerformance = const [],
    required this.lastUpdated,
  });

  double get overallPerformance => 
      totalQuestions > 0 ? totalCorrectAnswers / totalQuestions : 0;

  int get averageTimePerQuizSeconds => 
      totalQuizzesTaken > 0 ? totalTimeSpentSeconds ~/ totalQuizzesTaken : 0;

  factory AnalyticsModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    // Parse quizTypeDistribution
    final Map<String, int> quizTypeDistribution = {};
    if (data['quizTypeDistribution'] != null) {
      (data['quizTypeDistribution'] as Map<String, dynamic>).forEach((key, value) {
        quizTypeDistribution[key] = value as int;
      });
    }
    
    // Parse performanceByQuizType
    final Map<String, double> performanceByQuizType = {};
    if (data['performanceByQuizType'] != null) {
      (data['performanceByQuizType'] as Map<String, dynamic>).forEach((key, value) {
        performanceByQuizType[key] = (value as num).toDouble();
      });
    }
    
    // Parse recentPerformance
    final List<QuizPerformance> recentPerformance = [];
    if (data['recentPerformance'] != null) {
      for (final item in data['recentPerformance']) {
        recentPerformance.add(QuizPerformance.fromMap(item));
      }
    }
    
    return AnalyticsModel(
      userId: doc.id,
      totalQuizzesTaken: data['totalQuizzesTaken'] ?? 0,
      totalCorrectAnswers: data['totalCorrectAnswers'] ?? 0,
      totalQuestions: data['totalQuestions'] ?? 0,
      totalTimeSpentSeconds: data['totalTimeSpentSeconds'] ?? 0,
      totalStarsEarned: data['totalStarsEarned'] ?? 0,
      quizTypeDistribution: quizTypeDistribution,
      performanceByQuizType: performanceByQuizType,
      recentPerformance: recentPerformance,
      lastUpdated: data['lastUpdated'] != null 
          ? (data['lastUpdated'] as Timestamp).toDate() 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    // Convert recentPerformance to List<Map>
    final List<Map<String, dynamic>> recentPerformanceMap = 
        recentPerformance.map((item) => item.toMap()).toList();
    
    return {
      'totalQuizzesTaken': totalQuizzesTaken,
      'totalCorrectAnswers': totalCorrectAnswers,
      'totalQuestions': totalQuestions,
      'totalTimeSpentSeconds': totalTimeSpentSeconds,
      'totalStarsEarned': totalStarsEarned,
      'quizTypeDistribution': quizTypeDistribution,
      'performanceByQuizType': performanceByQuizType,
      'recentPerformance': recentPerformanceMap,
      'lastUpdated': Timestamp.fromDate(lastUpdated),
    };
  }

  AnalyticsModel copyWith({
    String? userId,
    int? totalQuizzesTaken,
    int? totalCorrectAnswers,
    int? totalQuestions,
    int? totalTimeSpentSeconds,
    int? totalStarsEarned,
    Map<String, int>? quizTypeDistribution,
    Map<String, double>? performanceByQuizType,
    List<QuizPerformance>? recentPerformance,
    DateTime? lastUpdated,
  }) {
    return AnalyticsModel(
      userId: userId ?? this.userId,
      totalQuizzesTaken: totalQuizzesTaken ?? this.totalQuizzesTaken,
      totalCorrectAnswers: totalCorrectAnswers ?? this.totalCorrectAnswers,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      totalTimeSpentSeconds: totalTimeSpentSeconds ?? this.totalTimeSpentSeconds,
      totalStarsEarned: totalStarsEarned ?? this.totalStarsEarned,
      quizTypeDistribution: quizTypeDistribution ?? this.quizTypeDistribution,
      performanceByQuizType: performanceByQuizType ?? this.performanceByQuizType,
      recentPerformance: recentPerformance ?? this.recentPerformance,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  @override
  List<Object?> get props => [
        userId,
        totalQuizzesTaken,
        totalCorrectAnswers,
        totalQuestions,
        totalTimeSpentSeconds,
        totalStarsEarned,
        quizTypeDistribution,
        performanceByQuizType,
        recentPerformance,
        lastUpdated,
      ];
}

class QuizPerformance extends Equatable {
  final String quizId;
  final String quizTitle;
  final String quizType;
  final int score;
  final int totalQuestions;
  final int timeSpentSeconds;
  final int starsEarned;
  final DateTime completedAt;

  const QuizPerformance({
    required this.quizId,
    required this.quizTitle,
    required this.quizType,
    required this.score,
    required this.totalQuestions,
    required this.timeSpentSeconds,
    required this.starsEarned,
    required this.completedAt,
  });

  double get performancePercentage => 
      totalQuestions > 0 ? score / totalQuestions : 0;

  factory QuizPerformance.fromMap(Map<String, dynamic> map) {
    return QuizPerformance(
      quizId: map['quizId'] ?? '',
      quizTitle: map['quizTitle'] ?? '',
      quizType: map['quizType'] ?? '',
      score: map['score'] ?? 0,
      totalQuestions: map['totalQuestions'] ?? 0,
      timeSpentSeconds: map['timeSpentSeconds'] ?? 0,
      starsEarned: map['starsEarned'] ?? 0,
      completedAt: map['completedAt'] != null 
          ? (map['completedAt'] as Timestamp).toDate() 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'quizId': quizId,
      'quizTitle': quizTitle,
      'quizType': quizType,
      'score': score,
      'totalQuestions': totalQuestions,
      'timeSpentSeconds': timeSpentSeconds,
      'starsEarned': starsEarned,
      'completedAt': Timestamp.fromDate(completedAt),
    };
  }

  @override
  List<Object?> get props => [
        quizId,
        quizTitle,
        quizType,
        score,
        totalQuestions,
        timeSpentSeconds,
        starsEarned,
        completedAt,
      ];
}

class StudentAnalytics extends Equatable {
  final String studentId;
  final String studentName;
  final AnalyticsModel analytics;

  const StudentAnalytics({
    required this.studentId,
    required this.studentName,
    required this.analytics,
  });

  @override
  List<Object?> get props => [studentId, studentName, analytics];
}
