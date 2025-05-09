import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import '../models/user_model.dart';
import '../models/quiz_model.dart';
import '../models/question_model.dart';
import '../models/user_progress_model.dart';
import '../models/badge_model.dart';
import '../models/reward_model.dart';
import '../models/currency_model.dart';
import '../models/analytics_model.dart';
import '../models/skill_assessment_model.dart';
import '../models/schedule_model.dart';

class FirebaseDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // User methods
  Future<Either<String, UserModel>> getUserById(String userId) async {
    try {
      print('Fetching user from Firestore with ID: $userId');
      final doc = await _firestore.collection('users').doc(userId).get();
      if (!doc.exists) {
        print('User document does not exist in Firestore');
        return Left('User not found');
      }
      final userData = doc.data() as Map<String, dynamic>?;
      print('User data from Firestore: $userData');
      return Right(UserModel.fromFirestore(doc));
    } catch (e) {
      print('Error fetching user from Firestore: $e');
      return Left(e.toString());
    }
  }

  Future<Either<String, bool>> createUser(UserModel user) async {
    try {
      print('Creating user in Firestore with ID: ${user.id}, role: ${user.role}');
      final userData = user.toMap();
      print('User data to be saved: $userData');
      await _firestore.collection('users').doc(user.id).set(userData);
      print('User created successfully in Firestore');
      return const Right(true);
    } catch (e) {
      print('Error creating user in Firestore: $e');
      return Left(e.toString());
    }
  }

  Future<Either<String, bool>> updateUser(UserModel user) async {
    try {
      await _firestore.collection('users').doc(user.id).update(user.toMap());
      return const Right(true);
    } catch (e) {
      return Left(e.toString());
    }
  }

  // Quiz methods
  Future<Either<String, List<QuizModel>>> getQuizzes({
    String? type,
    String? difficulty,
    String? category,
    bool? isPublished,
    String? creatorId,
  }) async {
    try {
      print('Fetching quizzes with filters: type=$type, difficulty=$difficulty, category=$category, isPublished=$isPublished, creatorId=$creatorId');
      Query query = _firestore.collection('quizzes');

      if (type != null) {
        query = query.where('type', isEqualTo: type);
      }

      if (difficulty != null) {
        query = query.where('difficulty', isEqualTo: difficulty);
      }

      if (category != null) {
        query = query.where('category', isEqualTo: category);
      }

      if (isPublished != null) {
        query = query.where('isPublished', isEqualTo: isPublished);
      }

      if (creatorId != null) {
        query = query.where('creatorId', isEqualTo: creatorId);
      }

      final querySnapshot = await query.get();
      print('Found ${querySnapshot.docs.length} quizzes in Firestore');

      final quizzes = querySnapshot.docs
          .map((doc) => QuizModel.fromFirestore(doc))
          .toList();

      print('Parsed ${quizzes.length} quiz models');
      if (quizzes.isNotEmpty) {
        print('First quiz: id=${quizzes.first.id}, title=${quizzes.first.title}, type=${quizzes.first.type}');
      }

      return Right(quizzes);
    } catch (e) {
      print('Error fetching quizzes from Firestore: $e');
      return Left(e.toString());
    }
  }

  Future<Either<String, QuizModel>> getQuizById(String quizId) async {
    try {
      final doc = await _firestore.collection('quizzes').doc(quizId).get();
      if (!doc.exists) {
        return Left('Quiz not found');
      }
      return Right(QuizModel.fromFirestore(doc));
    } catch (e) {
      return Left(e.toString());
    }
  }

  Future<Either<String, String>> createQuiz(QuizModel quiz) async {
    try {
      final docRef = await _firestore.collection('quizzes').add(quiz.toMap());
      return Right(docRef.id);
    } catch (e) {
      return Left(e.toString());
    }
  }

  Future<Either<String, bool>> updateQuiz(QuizModel quiz) async {
    try {
      await _firestore.collection('quizzes').doc(quiz.id).update(quiz.toMap());
      return const Right(true);
    } catch (e) {
      return Left(e.toString());
    }
  }

  Future<Either<String, bool>> deleteQuiz(String quizId) async {
    try {
      await _firestore.collection('quizzes').doc(quizId).delete();
      return const Right(true);
    } catch (e) {
      return Left(e.toString());
    }
  }

  // Question methods
  Future<Either<String, List<QuestionModel>>> getQuestionsByQuizId(String quizId) async {
    try {
      print('Fetching questions for quiz ID: $quizId');
      final querySnapshot = await _firestore
          .collection('questions')
          .where('quizId', isEqualTo: quizId)
          .orderBy('order')
          .get();

      print('Found ${querySnapshot.docs.length} questions for quiz ID: $quizId');

      final questions = querySnapshot.docs
          .map((doc) => QuestionModel.fromFirestore(doc))
          .toList();

      if (questions.isNotEmpty) {
        print('First question: id=${questions.first.id}, text=${questions.first.text}');
      } else {
        print('No questions found for quiz ID: $quizId');
      }

      return Right(questions);
    } catch (e) {
      print('Error fetching questions from Firestore: $e');
      return Left(e.toString());
    }
  }

  Future<Either<String, QuestionModel>> getQuestionById(String questionId) async {
    try {
      print('Fetching question with ID: $questionId');
      final doc = await _firestore.collection('questions').doc(questionId).get();

      if (!doc.exists) {
        print('Question document does not exist in Firestore');
        return Left('Question not found');
      }

      final question = QuestionModel.fromFirestore(doc);
      print('Found question: id=${question.id}, text=${question.text}');

      return Right(question);
    } catch (e) {
      print('Error fetching question from Firestore: $e');
      return Left(e.toString());
    }
  }

  Future<Either<String, String>> createQuestion(QuestionModel question) async {
    try {
      final docRef = await _firestore.collection('questions').add(question.toMap());
      return Right(docRef.id);
    } catch (e) {
      return Left(e.toString());
    }
  }

  Future<Either<String, bool>> updateQuestion(QuestionModel question) async {
    try {
      print('Updating question with ID: ${question.id}');
      final questionData = question.toMap();
      print('Question data to update: $questionData');

      await _firestore.collection('questions').doc(question.id).update(questionData);
      print('Question updated successfully');

      return const Right(true);
    } catch (e) {
      print('Error updating question: $e');
      return Left(e.toString());
    }
  }

  Future<Either<String, bool>> deleteQuestion(String questionId) async {
    try {
      await _firestore.collection('questions').doc(questionId).delete();
      return const Right(true);
    } catch (e) {
      return Left(e.toString());
    }
  }

  // User Progress methods
  Future<Either<String, List<UserProgressModel>>> getUserProgressByUserId(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('user_progress')
          .where('userId', isEqualTo: userId)
          .orderBy('completedAt', descending: true)
          .get();
      final progress = querySnapshot.docs
          .map((doc) => UserProgressModel.fromFirestore(doc))
          .toList();
      return Right(progress);
    } catch (e) {
      return Left(e.toString());
    }
  }

  Future<Either<String, UserProgressModel>> getUserProgressByQuizId(String userId, String quizId) async {
    try {
      final querySnapshot = await _firestore
          .collection('user_progress')
          .where('userId', isEqualTo: userId)
          .where('quizId', isEqualTo: quizId)
          .orderBy('completedAt', descending: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return Left('No progress found');
      }

      return Right(UserProgressModel.fromFirestore(querySnapshot.docs.first));
    } catch (e) {
      return Left(e.toString());
    }
  }

  Future<Either<String, String>> saveUserProgress(UserProgressModel progress) async {
    try {
      final docRef = await _firestore.collection('user_progress').add(progress.toMap());
      return Right(docRef.id);
    } catch (e) {
      return Left(e.toString());
    }
  }

  // Phương thức cho hệ thống huy hiệu
  Future<Either<String, List<BadgeModel>>> getUserBadges(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('badges')
          .get();

      final badges = querySnapshot.docs
          .map((doc) => BadgeModel.fromFirestore(doc))
          .toList();

      return Right(badges);
    } catch (e) {
      return Left(e.toString());
    }
  }

  Future<Either<String, String>> unlockBadge(String userId, BadgeModel badge) async {
    try {
      final updatedBadge = badge.copyWith(
        isUnlocked: true,
        unlockedAt: DateTime.now(),
      );

      final docRef = await _firestore
          .collection('users')
          .doc(userId)
          .collection('badges')
          .doc(badge.id)
          .set(updatedBadge.toMap());

      return Right(badge.id);
    } catch (e) {
      return Left(e.toString());
    }
  }

  // Phương thức cho hệ thống phần thưởng
  Future<Either<String, List<RewardModel>>> getAvailableRewards() async {
    try {
      final querySnapshot = await _firestore
          .collection('rewards')
          .get();

      final rewards = querySnapshot.docs
          .map((doc) => RewardModel.fromFirestore(doc))
          .toList();

      return Right(rewards);
    } catch (e) {
      return Left(e.toString());
    }
  }

  Future<Either<String, List<RewardModel>>> getUserRewards(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('rewards')
          .get();

      final rewards = querySnapshot.docs
          .map((doc) => RewardModel.fromFirestore(doc))
          .toList();

      return Right(rewards);
    } catch (e) {
      return Left(e.toString());
    }
  }

  Future<Either<String, String>> purchaseReward(String userId, RewardModel reward) async {
    try {
      final updatedReward = reward.copyWith(
        isPurchased: true,
        purchasedAt: DateTime.now(),
      );

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('rewards')
          .doc(reward.id)
          .set(updatedReward.toMap());

      return Right(reward.id);
    } catch (e) {
      return Left(e.toString());
    }
  }

  // Phương thức cho hệ thống tiền tệ
  Future<Either<String, CurrencyModel>> getUserCurrency(String userId) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('currency')
          .doc('main')
          .get();

      if (!doc.exists) {
        // Tạo mới nếu chưa tồn tại
        final newCurrency = CurrencyModel(
          userId: userId,
          stars: 0,
          coins: 0,
          gems: 0,
          lastUpdated: DateTime.now(),
        );

        await _firestore
            .collection('users')
            .doc(userId)
            .collection('currency')
            .doc('main')
            .set(newCurrency.toMap());

        return Right(newCurrency);
      }

      return Right(CurrencyModel.fromFirestore(doc));
    } catch (e) {
      return Left(e.toString());
    }
  }

  Future<Either<String, bool>> updateUserCurrency(CurrencyModel currency) async {
    try {
      await _firestore
          .collection('users')
          .doc(currency.userId)
          .collection('currency')
          .doc('main')
          .set(currency.toMap());

      return const Right(true);
    } catch (e) {
      return Left(e.toString());
    }
  }

  // Phương thức cho phân tích dữ liệu
  Future<Either<String, AnalyticsModel>> getUserAnalytics(String userId) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('analytics')
          .doc('main')
          .get();

      if (!doc.exists) {
        // Tạo mới nếu chưa tồn tại
        final newAnalytics = AnalyticsModel(
          userId: userId,
          lastUpdated: DateTime.now(),
        );

        await _firestore
            .collection('users')
            .doc(userId)
            .collection('analytics')
            .doc('main')
            .set(newAnalytics.toMap());

        return Right(newAnalytics);
      }

      return Right(AnalyticsModel.fromFirestore(doc));
    } catch (e) {
      return Left(e.toString());
    }
  }

  Future<Either<String, bool>> updateUserAnalytics(AnalyticsModel analytics) async {
    try {
      await _firestore
          .collection('users')
          .doc(analytics.userId)
          .collection('analytics')
          .doc('main')
          .set(analytics.toMap());

      return const Right(true);
    } catch (e) {
      return Left(e.toString());
    }
  }

  Future<Either<String, List<StudentAnalytics>>> getStudentAnalytics(String teacherId) async {
    try {
      // Lấy danh sách học sinh của giáo viên
      final studentsQuery = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'student')
          .get();

      final List<StudentAnalytics> studentAnalyticsList = [];

      for (final studentDoc in studentsQuery.docs) {
        final studentId = studentDoc.id;
        final studentData = studentDoc.data();
        final studentName = studentData['name'] ?? 'Học sinh';

        // Lấy phân tích dữ liệu của học sinh
        final analyticsDoc = await _firestore
            .collection('users')
            .doc(studentId)
            .collection('analytics')
            .doc('main')
            .get();

        if (analyticsDoc.exists) {
          final analytics = AnalyticsModel.fromFirestore(analyticsDoc);
          studentAnalyticsList.add(StudentAnalytics(
            studentId: studentId,
            studentName: studentName,
            analytics: analytics,
          ));
        }
      }

      return Right(studentAnalyticsList);
    } catch (e) {
      return Left(e.toString());
    }
  }

  Future<Either<String, bool>> updateAnalyticsFromProgress(String userId) async {
    try {
      // Lấy tất cả tiến trình của người dùng
      final progressQuery = await _firestore
          .collection('user_progress')
          .where('userId', isEqualTo: userId)
          .get();

      if (progressQuery.docs.isEmpty) {
        return const Right(true); // Không có dữ liệu tiến trình
      }

      // Lấy phân tích dữ liệu hiện tại hoặc tạo mới
      final analyticsResult = await getUserAnalytics(userId);

      return analyticsResult.fold(
        (error) => Left(error),
        (analytics) async {
          // Tổng hợp dữ liệu
          int totalQuizzesTaken = 0;
          int totalCorrectAnswers = 0;
          int totalQuestions = 0;
          int totalTimeSpentSeconds = 0;
          int totalStarsEarned = 0;
          Map<String, int> quizTypeDistribution = {};
          Map<String, List<double>> performanceByQuizType = {};
          List<QuizPerformance> recentPerformance = [];

          // Lấy thông tin chi tiết về các bài kiểm tra
          for (final progressDoc in progressQuery.docs) {
            final progressData = progressDoc.data();
            final quizId = progressData['quizId'] as String;

            // Lấy thông tin bài kiểm tra
            final quizDoc = await _firestore.collection('quizzes').doc(quizId).get();

            if (quizDoc.exists) {
              final quizData = quizDoc.data()!;
              final quizTitle = quizData['title'] as String? ?? 'Bài kiểm tra';
              final quizType = quizData['type'] as String? ?? 'unknown';

              // Cập nhật thống kê
              totalQuizzesTaken++;
              final score = progressData['score'] as int? ?? 0;
              final totalQuestionsInQuiz = progressData['totalQuestions'] as int? ?? 0;
              totalCorrectAnswers += score;
              totalQuestions += totalQuestionsInQuiz;
              totalTimeSpentSeconds += progressData['timeSpentSeconds'] as int? ?? 0;
              totalStarsEarned += progressData['starsEarned'] as int? ?? 0;

              // Cập nhật phân phối loại bài kiểm tra
              quizTypeDistribution[quizType] = (quizTypeDistribution[quizType] ?? 0) + 1;

              // Cập nhật hiệu suất theo loại bài kiểm tra
              if (!performanceByQuizType.containsKey(quizType)) {
                performanceByQuizType[quizType] = [];
              }

              if (totalQuestionsInQuiz > 0) {
                performanceByQuizType[quizType]!.add(score / totalQuestionsInQuiz);
              }

              // Thêm vào danh sách hiệu suất gần đây
              final completedAt = (progressData['completedAt'] as Timestamp).toDate();

              recentPerformance.add(QuizPerformance(
                quizId: quizId,
                quizTitle: quizTitle,
                quizType: quizType,
                score: score,
                totalQuestions: totalQuestionsInQuiz,
                timeSpentSeconds: progressData['timeSpentSeconds'] as int? ?? 0,
                starsEarned: progressData['starsEarned'] as int? ?? 0,
                completedAt: completedAt,
              ));
            }
          }

          // Sắp xếp hiệu suất gần đây theo thời gian
          recentPerformance.sort((a, b) => b.completedAt.compareTo(a.completedAt));

          // Giới hạn số lượng hiệu suất gần đây
          if (recentPerformance.length > 10) {
            recentPerformance = recentPerformance.sublist(0, 10);
          }

          // Tính toán hiệu suất trung bình theo loại bài kiểm tra
          final Map<String, double> avgPerformanceByQuizType = {};
          performanceByQuizType.forEach((type, performances) {
            if (performances.isNotEmpty) {
              final sum = performances.reduce((a, b) => a + b);
              avgPerformanceByQuizType[type] = sum / performances.length;
            } else {
              avgPerformanceByQuizType[type] = 0.0;
            }
          });

          // Cập nhật phân tích dữ liệu
          final updatedAnalytics = analytics.copyWith(
            totalQuizzesTaken: totalQuizzesTaken,
            totalCorrectAnswers: totalCorrectAnswers,
            totalQuestions: totalQuestions,
            totalTimeSpentSeconds: totalTimeSpentSeconds,
            totalStarsEarned: totalStarsEarned,
            quizTypeDistribution: quizTypeDistribution,
            performanceByQuizType: avgPerformanceByQuizType,
            recentPerformance: recentPerformance,
            lastUpdated: DateTime.now(),
          );

          // Lưu phân tích dữ liệu
          final updateResult = await updateUserAnalytics(updatedAnalytics);

          return updateResult.fold(
            (error) => Left(error),
            (_) => const Right(true),
          );
        },
      );
    } catch (e) {
      return Left(e.toString());
    }
  }

  // Phương thức cho đánh giá kỹ năng
  Future<Either<String, List<SkillAssessmentModel>>> getStudentAssessments(String studentId) async {
    try {
      final querySnapshot = await _firestore
          .collection('skill_assessments')
          .where('studentId', isEqualTo: studentId)
          .orderBy('assessmentDate', descending: true)
          .get();

      final assessments = querySnapshot.docs
          .map((doc) => SkillAssessmentModel.fromFirestore(doc))
          .toList();

      return Right(assessments);
    } catch (e) {
      return Left(e.toString());
    }
  }

  Future<Either<String, List<SkillAssessmentModel>>> getTeacherAssessments(String teacherId) async {
    try {
      final querySnapshot = await _firestore
          .collection('skill_assessments')
          .where('teacherId', isEqualTo: teacherId)
          .orderBy('assessmentDate', descending: true)
          .get();

      final assessments = querySnapshot.docs
          .map((doc) => SkillAssessmentModel.fromFirestore(doc))
          .toList();

      return Right(assessments);
    } catch (e) {
      return Left(e.toString());
    }
  }

  Future<Either<String, SkillAssessmentModel>> getAssessment(String assessmentId) async {
    try {
      final doc = await _firestore
          .collection('skill_assessments')
          .doc(assessmentId)
          .get();

      if (!doc.exists) {
        return Left('Không tìm thấy đánh giá');
      }

      return Right(SkillAssessmentModel.fromFirestore(doc));
    } catch (e) {
      return Left(e.toString());
    }
  }

  Future<Either<String, String>> createAssessment(SkillAssessmentModel assessment) async {
    try {
      final docRef = await _firestore
          .collection('skill_assessments')
          .add(assessment.toMap());

      return Right(docRef.id);
    } catch (e) {
      return Left(e.toString());
    }
  }

  Future<Either<String, bool>> updateAssessment(SkillAssessmentModel assessment) async {
    try {
      await _firestore
          .collection('skill_assessments')
          .doc(assessment.id)
          .update(assessment.toMap());

      return const Right(true);
    } catch (e) {
      return Left(e.toString());
    }
  }

  Future<Either<String, bool>> deleteAssessment(String assessmentId) async {
    try {
      await _firestore
          .collection('skill_assessments')
          .doc(assessmentId)
          .delete();

      return const Right(true);
    } catch (e) {
      return Left(e.toString());
    }
  }

  // Phương thức cho lịch học và nhắc nhở
  Future<Either<String, List<ScheduleModel>>> getUserSchedules(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('schedules')
          .where('userId', isEqualTo: userId)
          .orderBy('startTime', descending: false)
          .get();

      final schedules = querySnapshot.docs
          .map((doc) => ScheduleModel.fromFirestore(doc))
          .toList();

      return Right(schedules);
    } catch (e) {
      return Left(e.toString());
    }
  }

  Future<Either<String, List<ScheduleModel>>> getUpcomingSchedules(String userId) async {
    try {
      final now = DateTime.now();
      final querySnapshot = await _firestore
          .collection('schedules')
          .where('userId', isEqualTo: userId)
          .where('startTime', isGreaterThanOrEqualTo: Timestamp.fromDate(now))
          .orderBy('startTime', descending: false)
          .limit(10)
          .get();

      final schedules = querySnapshot.docs
          .map((doc) => ScheduleModel.fromFirestore(doc))
          .toList();

      return Right(schedules);
    } catch (e) {
      return Left(e.toString());
    }
  }

  Future<Either<String, ScheduleModel>> getSchedule(String scheduleId) async {
    try {
      final doc = await _firestore
          .collection('schedules')
          .doc(scheduleId)
          .get();

      if (!doc.exists) {
        return Left('Không tìm thấy lịch học');
      }

      return Right(ScheduleModel.fromFirestore(doc));
    } catch (e) {
      return Left(e.toString());
    }
  }

  Future<Either<String, String>> createSchedule(ScheduleModel schedule) async {
    try {
      final docRef = await _firestore
          .collection('schedules')
          .add(schedule.toMap());

      return Right(docRef.id);
    } catch (e) {
      return Left(e.toString());
    }
  }

  Future<Either<String, bool>> updateSchedule(ScheduleModel schedule) async {
    try {
      await _firestore
          .collection('schedules')
          .doc(schedule.id)
          .update(schedule.toMap());

      return const Right(true);
    } catch (e) {
      return Left(e.toString());
    }
  }

  Future<Either<String, bool>> deleteSchedule(String scheduleId) async {
    try {
      await _firestore
          .collection('schedules')
          .doc(scheduleId)
          .delete();

      return const Right(true);
    } catch (e) {
      return Left(e.toString());
    }
  }

  Future<Either<String, bool>> markScheduleAsCompleted(String scheduleId) async {
    try {
      await _firestore
          .collection('schedules')
          .doc(scheduleId)
          .update({'isCompleted': true});

      return const Right(true);
    } catch (e) {
      return Left(e.toString());
    }
  }
}
