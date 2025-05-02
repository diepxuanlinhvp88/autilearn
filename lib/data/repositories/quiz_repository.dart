import 'package:dartz/dartz.dart';
import '../datasources/firebase_datasource.dart';
import '../models/quiz_model.dart';
import '../models/question_model.dart';
import '../models/user_progress_model.dart';

class QuizRepository {
  final FirebaseDataSource _firebaseDataSource;

  QuizRepository({required FirebaseDataSource firebaseDataSource})
      : _firebaseDataSource = firebaseDataSource;

  Future<Either<String, List<QuizModel>>> getQuizzes({
    String? type,
    String? difficulty,
    String? category,
    bool? isPublished,
    String? creatorId,
  }) async {
    return _firebaseDataSource.getQuizzes(
      type: type,
      difficulty: difficulty,
      category: category,
      isPublished: isPublished,
      creatorId: creatorId,
    );
  }

  Future<Either<String, QuizModel>> getQuizById(String quizId) async {
    return _firebaseDataSource.getQuizById(quizId);
  }

  Future<Either<String, String>> createQuiz(QuizModel quiz) async {
    return _firebaseDataSource.createQuiz(quiz);
  }

  Future<Either<String, bool>> updateQuiz(QuizModel quiz) async {
    return _firebaseDataSource.updateQuiz(quiz);
  }

  Future<Either<String, bool>> deleteQuiz(String quizId) async {
    return _firebaseDataSource.deleteQuiz(quizId);
  }

  Future<Either<String, List<QuestionModel>>> getQuestionsByQuizId(String quizId) async {
    return _firebaseDataSource.getQuestionsByQuizId(quizId);
  }

  Future<Either<String, QuestionModel>> getQuestionById(String questionId) async {
    return _firebaseDataSource.getQuestionById(questionId);
  }

  Future<Either<String, String>> createQuestion(QuestionModel question) async {
    return _firebaseDataSource.createQuestion(question);
  }

  Future<Either<String, bool>> updateQuestion(QuestionModel question) async {
    return _firebaseDataSource.updateQuestion(question);
  }

  Future<Either<String, bool>> deleteQuestion(String questionId) async {
    return _firebaseDataSource.deleteQuestion(questionId);
  }

  Future<Either<String, List<UserProgressModel>>> getUserProgressByUserId(String userId) async {
    return _firebaseDataSource.getUserProgressByUserId(userId);
  }

  Future<Either<String, UserProgressModel>> getUserProgressByQuizId(String userId, String quizId) async {
    return _firebaseDataSource.getUserProgressByQuizId(userId, quizId);
  }

  Future<Either<String, String>> saveUserProgress(UserProgressModel progress) async {
    return _firebaseDataSource.saveUserProgress(progress);
  }
}
