import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import '../models/user_model.dart';
import '../models/quiz_model.dart';
import '../models/question_model.dart';
import '../models/user_progress_model.dart';

class FirebaseDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // User methods
  Future<Either<String, UserModel>> getUserById(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (!doc.exists) {
        return Left('User not found');
      }
      return Right(UserModel.fromFirestore(doc));
    } catch (e) {
      return Left(e.toString());
    }
  }

  Future<Either<String, bool>> createUser(UserModel user) async {
    try {
      await _firestore.collection('users').doc(user.id).set(user.toMap());
      return const Right(true);
    } catch (e) {
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
      final quizzes = querySnapshot.docs
          .map((doc) => QuizModel.fromFirestore(doc))
          .toList();
      return Right(quizzes);
    } catch (e) {
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
      final querySnapshot = await _firestore
          .collection('questions')
          .where('quizId', isEqualTo: quizId)
          .orderBy('order')
          .get();
      final questions = querySnapshot.docs
          .map((doc) => QuestionModel.fromFirestore(doc))
          .toList();
      return Right(questions);
    } catch (e) {
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
      await _firestore.collection('questions').doc(question.id).update(question.toMap());
      return const Right(true);
    } catch (e) {
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
}
