import 'package:dartz/dartz.dart';
import '../datasources/firebase_datasource.dart';
import '../models/quiz_model.dart';
import '../models/question_model.dart';
import '../models/user_progress_model.dart';
import '../../core/error/failures.dart';

class QuizRepository {
  final FirebaseDataSource _firebaseDataSource;

  QuizRepository({required FirebaseDataSource firebaseDataSource})
      : _firebaseDataSource = firebaseDataSource;

  Future<Either<Failure, List<QuizModel>>> getQuizzes({
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

  Future<Either<Failure, QuizModel>> getQuizById(String quizId) async {
    return _firebaseDataSource.getQuizById(quizId);
  }

  Future<Either<Failure, String>> createQuiz(QuizModel quiz) async {
    return _firebaseDataSource.createQuiz(quiz);
  }

  Future<Either<Failure, bool>> updateQuiz(QuizModel quiz) async {
    return _firebaseDataSource.updateQuiz(quiz);
  }

  Future<Either<Failure, bool>> deleteQuiz(String quizId) async {
    return _firebaseDataSource.deleteQuiz(quizId);
  }

  Future<Either<Failure, List<QuestionModel>>> getQuestionsByQuizId(String quizId) async {
    return _firebaseDataSource.getQuestionsByQuizId(quizId);
  }

  Future<Either<Failure, QuestionModel>> getQuestionById(String questionId) async {
    return _firebaseDataSource.getQuestionById(questionId);
  }

  Future<Either<Failure, String>> createQuestion(QuestionModel question) async {
    return _firebaseDataSource.createQuestion(question);
  }

  Future<Either<Failure, bool>> updateQuestion(QuestionModel question) async {
    return _firebaseDataSource.updateQuestion(question);
  }

  Future<Either<Failure, bool>> deleteQuestion(String questionId) async {
    return _firebaseDataSource.deleteQuestion(questionId);
  }

  Future<Either<Failure, List<UserProgressModel>>> getUserProgressByUserId(String userId) async {
    return _firebaseDataSource.getUserProgressByUserId(userId);
  }

  Future<Either<Failure, UserProgressModel>> getUserProgressByQuizId(String userId, String quizId) async {
    return _firebaseDataSource.getUserProgressByQuizId(userId, quizId);
  }

  Future<Either<Failure, String>> saveUserProgress(UserProgressModel progress) async {
    return _firebaseDataSource.saveUserProgress(progress);
  }
}
