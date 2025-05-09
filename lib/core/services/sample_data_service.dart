import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/models/quiz_model.dart';
import '../../data/models/question_model.dart';
import '../../data/models/user_progress_model.dart';
import '../../data/models/badge_model.dart';
import '../../data/models/reward_model.dart';
import '../../data/models/currency_model.dart';
import '../../data/models/analytics_model.dart';
import '../../data/models/skill_assessment_model.dart';
import '../../data/models/schedule_model.dart';
import '../constants/app_constants.dart';

class SampleDataService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> generateSampleData(String userId) async {
    await _generateSampleQuizzes(userId);
    await _generateSampleProgress(userId);
    await _generateSampleBadges(userId);
    await _generateSampleRewards();
    await _generateSampleCurrency(userId);
    await _generateSampleAnalytics(userId);
    await _generateSampleAssessments(userId);
    await _generateSampleSchedules(userId);
  }

  Future<void> _generateSampleQuizzes(String userId) async {
    // Sample quizzes
    final List<Map<String, dynamic>> sampleQuizzes = [
      {
        'title': 'Nhận diện cảm xúc cơ bản',
        'description': 'Học cách nhận biết các cảm xúc cơ bản của con người',
        'type': AppConstants.emotionsQuiz,
        'creatorId': userId,
        'difficulty': AppConstants.difficultyEasy,
        'tags': ['cảm xúc', 'nhận biết', 'kỹ năng xã hội'],
        'isPublished': true,
        'createdAt': DateTime.now(),
        'updatedAt': DateTime.now(),
        'questionCount': 4,
        'category': 'Kỹ năng xã hội',
        'ageRangeMin': 4,
        'ageRangeMax': 8,
        'questions': [
          {
            'text': 'Đâu là khuôn mặt vui vẻ?',
            'type': AppConstants.emotionsQuiz,
            'options': [
              {
                'id': 'A',
                'text': 'Vui vẻ',
                'imageUrl': 'https://cdn-icons-png.flaticon.com/512/4677/4677490.png',
              },
              {
                'id': 'B',
                'text': 'Buồn bã',
                'imageUrl': 'https://cdn-icons-png.flaticon.com/512/4677/4677496.png',
              },
              {
                'id': 'C',
                'text': 'Tức giận',
                'imageUrl': 'https://cdn-icons-png.flaticon.com/512/4677/4677500.png',
              },
              {
                'id': 'D',
                'text': 'Sợ hãi',
                'imageUrl': 'https://cdn-icons-png.flaticon.com/512/4677/4677505.png',
              },
            ],
            'correctOptionId': 'A',
            'order': 1,
            'hint': 'Khuôn mặt vui vẻ thường có nụ cười',
          },
          {
            'text': 'Đâu là khuôn mặt buồn bã?',
            'type': AppConstants.emotionsQuiz,
            'options': [
              {
                'id': 'A',
                'text': 'Vui vẻ',
                'imageUrl': 'https://cdn-icons-png.flaticon.com/512/4677/4677490.png',
              },
              {
                'id': 'B',
                'text': 'Buồn bã',
                'imageUrl': 'https://cdn-icons-png.flaticon.com/512/4677/4677496.png',
              },
              {
                'id': 'C',
                'text': 'Tức giận',
                'imageUrl': 'https://cdn-icons-png.flaticon.com/512/4677/4677500.png',
              },
              {
                'id': 'D',
                'text': 'Sợ hãi',
                'imageUrl': 'https://cdn-icons-png.flaticon.com/512/4677/4677505.png',
              },
            ],
            'correctOptionId': 'B',
            'order': 2,
            'hint': 'Khuôn mặt buồn bã thường có miệng có hình cong xuống',
          },
          {
            'text': 'Đâu là khuôn mặt tức giận?',
            'type': AppConstants.emotionsQuiz,
            'options': [
              {
                'id': 'A',
                'text': 'Vui vẻ',
                'imageUrl': 'https://cdn-icons-png.flaticon.com/512/4677/4677490.png',
              },
              {
                'id': 'B',
                'text': 'Buồn bã',
                'imageUrl': 'https://cdn-icons-png.flaticon.com/512/4677/4677496.png',
              },
              {
                'id': 'C',
                'text': 'Tức giận',
                'imageUrl': 'https://cdn-icons-png.flaticon.com/512/4677/4677500.png',
              },
              {
                'id': 'D',
                'text': 'Sợ hãi',
                'imageUrl': 'https://cdn-icons-png.flaticon.com/512/4677/4677505.png',
              },
            ],
            'correctOptionId': 'C',
            'order': 3,
            'hint': 'Khuôn mặt tức giận thường có lông mày nháu lại',
          },
          {
            'text': 'Đâu là khuôn mặt sợ hãi?',
            'type': AppConstants.emotionsQuiz,
            'options': [
              {
                'id': 'A',
                'text': 'Vui vẻ',
                'imageUrl': 'https://cdn-icons-png.flaticon.com/512/4677/4677490.png',
              },
              {
                'id': 'B',
                'text': 'Buồn bã',
                'imageUrl': 'https://cdn-icons-png.flaticon.com/512/4677/4677496.png',
              },
              {
                'id': 'C',
                'text': 'Tức giận',
                'imageUrl': 'https://cdn-icons-png.flaticon.com/512/4677/4677500.png',
              },
              {
                'id': 'D',
                'text': 'Sợ hãi',
                'imageUrl': 'https://cdn-icons-png.flaticon.com/512/4677/4677505.png',
              },
            ],
            'correctOptionId': 'D',
            'order': 4,
            'hint': 'Khuôn mặt sợ hãi thường có mắt mở to',
          },
        ],
      },
      {
        'title': 'Nhận biết động vật',
        'description': 'Học cách nhận biết các loài động vật khác nhau',
        'type': AppConstants.choicesQuiz,
        'creatorId': userId,
        'difficulty': AppConstants.difficultyEasy,
        'tags': ['động vật', 'nhận biết', 'trẻ em'],
        'isPublished': true,
        'createdAt': DateTime.now(),
        'updatedAt': DateTime.now(),
        'questionCount': 5,
        'category': 'Khoa học',
        'ageRangeMin': 3,
        'ageRangeMax': 6,
        'questions': [
          {
            'text': 'Đâu là con mèo?',
            'type': AppConstants.choicesQuiz,
            'options': [
              {
                'id': 'A',
                'text': 'Mèo',
                'imageUrl': 'https://picsum.photos/id/40/200/200',
              },
              {
                'id': 'B',
                'text': 'Chó',
                'imageUrl': 'https://picsum.photos/id/237/200/200',
              },
              {
                'id': 'C',
                'text': 'Gà',
                'imageUrl': 'https://picsum.photos/id/30/200/200',
              },
              {
                'id': 'D',
                'text': 'Vịt',
                'imageUrl': 'https://picsum.photos/id/20/200/200',
              },
            ],
            'correctOptionId': 'A',
            'order': 1,
            'hint': 'Con vật này kêu "meo meo"',
          },
          {
            'text': 'Đâu là con chó?',
            'type': AppConstants.choicesQuiz,
            'options': [
              {
                'id': 'A',
                'text': 'Mèo',
                'imageUrl': 'https://picsum.photos/id/40/200/200',
              },
              {
                'id': 'B',
                'text': 'Chó',
                'imageUrl': 'https://picsum.photos/id/237/200/200',
              },
              {
                'id': 'C',
                'text': 'Gà',
                'imageUrl': 'https://picsum.photos/id/30/200/200',
              },
              {
                'id': 'D',
                'text': 'Vịt',
                'imageUrl': 'https://picsum.photos/id/20/200/200',
              },
            ],
            'correctOptionId': 'B',
            'order': 2,
            'hint': 'Con vật này kêu "gâu gâu"',
          },
          {
            'text': 'Đâu là con gà?',
            'type': AppConstants.choicesQuiz,
            'options': [
              {
                'id': 'A',
                'text': 'Mèo',
                'imageUrl': 'https://picsum.photos/id/40/200/200',
              },
              {
                'id': 'B',
                'text': 'Chó',
                'imageUrl': 'https://picsum.photos/id/237/200/200',
              },
              {
                'id': 'C',
                'text': 'Gà',
                'imageUrl': 'https://picsum.photos/id/30/200/200',
              },
              {
                'id': 'D',
                'text': 'Vịt',
                'imageUrl': 'https://picsum.photos/id/20/200/200',
              },
            ],
            'correctOptionId': 'C',
            'order': 3,
            'hint': 'Con vật này kêu "ò ó o"',
          },
          {
            'text': 'Đâu là con vịt?',
            'type': AppConstants.choicesQuiz,
            'options': [
              {
                'id': 'A',
                'text': 'Mèo',
                'imageUrl': 'https://picsum.photos/id/40/200/200',
              },
              {
                'id': 'B',
                'text': 'Chó',
                'imageUrl': 'https://picsum.photos/id/237/200/200',
              },
              {
                'id': 'C',
                'text': 'Gà',
                'imageUrl': 'https://picsum.photos/id/30/200/200',
              },
              {
                'id': 'D',
                'text': 'Vịt',
                'imageUrl': 'https://picsum.photos/id/20/200/200',
              },
            ],
            'correctOptionId': 'D',
            'order': 4,
            'hint': 'Con vật này kêu "cạp cạp"',
          },
          {
            'text': 'Đâu là con thỏ?',
            'type': AppConstants.choicesQuiz,
            'options': [
              {
                'id': 'A',
                'text': 'Mèo',
                'imageUrl': 'https://picsum.photos/id/40/200/200',
              },
              {
                'id': 'B',
                'text': 'Chó',
                'imageUrl': 'https://picsum.photos/id/237/200/200',
              },
              {
                'id': 'C',
                'text': 'Gà',
                'imageUrl': 'https://picsum.photos/id/30/200/200',
              },
              {
                'id': 'D',
                'text': 'Vịt',
                'imageUrl': 'https://picsum.photos/id/20/200/200',
              },
            ],
            'correctOptionId': 'A',
            'order': 5,
            'hint': 'Con vật này có đôi tai dài',
          },
        ],
      },
      {
        'title': 'Nhận biết màu sắc',
        'description': 'Học cách nhận biết các màu sắc cơ bản',
        'type': AppConstants.choicesQuiz,
        'creatorId': userId,
        'difficulty': AppConstants.difficultyEasy,
        'tags': ['màu sắc', 'nhận biết', 'trẻ em'],
        'isPublished': true,
        'createdAt': DateTime.now(),
        'updatedAt': DateTime.now(),
        'questionCount': 4,
        'category': 'Nghệ thuật',
        'ageRangeMin': 3,
        'ageRangeMax': 5,
        'questions': [
          {
            'text': 'Đâu là màu đỏ?',
            'type': AppConstants.choicesQuiz,
            'options': [
              {
                'id': 'A',
                'text': 'Đỏ',
                'imageUrl': 'https://picsum.photos/id/1025/200/200',
              },
              {
                'id': 'B',
                'text': 'Xanh dương',
                'imageUrl': 'https://picsum.photos/id/1024/200/200',
              },
              {
                'id': 'C',
                'text': 'Xanh lá',
                'imageUrl': 'https://picsum.photos/id/1023/200/200',
              },
              {
                'id': 'D',
                'text': 'Vàng',
                'imageUrl': 'https://picsum.photos/id/1022/200/200',
              },
            ],
            'correctOptionId': 'A',
            'order': 1,
            'hint': 'Màu của quả táo chín',
          },
          {
            'text': 'Đâu là màu xanh dương?',
            'type': AppConstants.choicesQuiz,
            'options': [
              {
                'id': 'A',
                'text': 'Đỏ',
                'imageUrl': 'https://picsum.photos/id/1025/200/200',
              },
              {
                'id': 'B',
                'text': 'Xanh dương',
                'imageUrl': 'https://picsum.photos/id/1024/200/200',
              },
              {
                'id': 'C',
                'text': 'Xanh lá',
                'imageUrl': 'https://picsum.photos/id/1023/200/200',
              },
              {
                'id': 'D',
                'text': 'Vàng',
                'imageUrl': 'https://picsum.photos/id/1022/200/200',
              },
            ],
            'correctOptionId': 'B',
            'order': 2,
            'hint': 'Màu của bầu trời',
          },
          {
            'text': 'Đâu là màu xanh lá?',
            'type': AppConstants.choicesQuiz,
            'options': [
              {
                'id': 'A',
                'text': 'Đỏ',
                'imageUrl': 'https://picsum.photos/id/1025/200/200',
              },
              {
                'id': 'B',
                'text': 'Xanh dương',
                'imageUrl': 'https://picsum.photos/id/1024/200/200',
              },
              {
                'id': 'C',
                'text': 'Xanh lá',
                'imageUrl': 'https://picsum.photos/id/1023/200/200',
              },
              {
                'id': 'D',
                'text': 'Vàng',
                'imageUrl': 'https://picsum.photos/id/1022/200/200',
              },
            ],
            'correctOptionId': 'C',
            'order': 3,
            'hint': 'Màu của lá cây',
          },
          {
            'text': 'Đâu là màu vàng?',
            'type': AppConstants.choicesQuiz,
            'options': [
              {
                'id': 'A',
                'text': 'Đỏ',
                'imageUrl': 'https://picsum.photos/id/1025/200/200',
              },
              {
                'id': 'B',
                'text': 'Xanh dương',
                'imageUrl': 'https://picsum.photos/id/1024/200/200',
              },
              {
                'id': 'C',
                'text': 'Xanh lá',
                'imageUrl': 'https://picsum.photos/id/1023/200/200',
              },
              {
                'id': 'D',
                'text': 'Vàng',
                'imageUrl': 'https://picsum.photos/id/1022/200/200',
              },
            ],
            'correctOptionId': 'D',
            'order': 4,
            'hint': 'Màu của mặt trời',
          },
        ],
      },
      {
        'title': 'Ghép đôi động vật và tiếng kêu',
        'description': 'Học cách ghép đôi động vật với tiếng kêu của chúng',
        'type': AppConstants.pairingQuiz,
        'creatorId': userId,
        'difficulty': AppConstants.difficultyMedium,
        'tags': ['động vật', 'âm thanh', 'ghép đôi'],
        'isPublished': true,
        'createdAt': DateTime.now(),
        'updatedAt': DateTime.now(),
        'questionCount': 2,
        'category': 'Khoa học',
        'ageRangeMin': 4,
        'ageRangeMax': 7,
        'questions': [
          {
            'text': 'Hãy ghép đôi các con vật với tiếng kêu của chúng',
            'type': AppConstants.pairingQuiz,
            'options': [
              {
                'id': 'L1',
                'text': 'Mèo',
                'imageUrl': 'https://life.thanhcong.vn/wp-content/uploads/2023/01/con-vat-yeu-thich-con-meo-1024x576.jpg',
              },
              {
                'id': 'L2',
                'text': 'Chó',
                'imageUrl': 'https://placedog.net/200/200',
              },
              {
                'id': 'L3',
                'text': 'Gà',
                'imageUrl': 'data:image/jpeg;base64,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',
              },
              {
                'id': 'R1',
                'text': 'Meo meo',
              },
              {
                'id': 'R2',
                'text': 'Gâu gâu',
              },
              {
                'id': 'R3',
                'text': 'Ò ó o',
              },
            ],
            'correctPairs': {
              'L1': 'R1',
              'L2': 'R2',
              'L3': 'R3',
            },
            'order': 1,
            'hint': 'Hãy nghĩ về âm thanh mà mỗi con vật tạo ra',
          },
          {
            'text': 'Hãy ghép đôi các màu sắc với đồ vật tương ứng',
            'type': AppConstants.pairingQuiz,
            'options': [
              {
                'id': 'L1',
                'text': 'Đỏ',
                'imageUrl': 'https://via.placeholder.com/200x200/FF0000/FFFFFF?text=Red',
              },
              {
                'id': 'L2',
                'text': 'Vàng',
                'imageUrl': 'https://via.placeholder.com/200x200/FFFF00/000000?text=Yellow',
              },
              {
                'id': 'L3',
                'text': 'Xanh lá',
                'imageUrl': 'https://via.placeholder.com/200x200/00FF00/FFFFFF?text=Green',
              },
              {
                'id': 'R1',
                'text': 'Quả táo',
                'imageUrl': 'https://via.placeholder.com/200x200?text=Apple',
              },
              {
                'id': 'R2',
                'text': 'Quả chuối',
                'imageUrl': 'https://via.placeholder.com/200x200?text=Banana',
              },
              {
                'id': 'R3',
                'text': 'Cây cỏ',
                'imageUrl': 'https://via.placeholder.com/200x200?text=Grass',
              },
            ],
            'correctPairs': {
              'L1': 'R1',
              'L2': 'R2',
              'L3': 'R3',
            },
            'order': 2,
            'hint': 'Hãy nghĩ về màu sắc tự nhiên của mỗi đồ vật',
          },
        ],
      },
      {
        'title': 'Sắp xếp các bước đánh răng',
        'description': 'Học cách sắp xếp các bước đánh răng theo đúng thứ tự',
        'type': AppConstants.sequentialQuiz,
        'creatorId': userId,
        'difficulty': AppConstants.difficultyMedium,
        'tags': ['kỹ năng sống', 'sắp xếp', 'vệ sinh'],
        'isPublished': true,
        'createdAt': DateTime.now(),
        'updatedAt': DateTime.now(),
        'questionCount': 2,
        'category': 'Kỹ năng sống',
        'ageRangeMin': 4,
        'ageRangeMax': 8,
        'questions': [
          {
            'text': 'Hãy sắp xếp các bước đánh răng theo đúng thứ tự',
            'type': AppConstants.sequentialQuiz,
            'options': [
              {
                'id': 'S1',
                'text': 'Lấy bàn chải đánh răng',
                'imageUrl': 'https://via.placeholder.com/200x200?text=Toothbrush',
              },
              {
                'id': 'S2',
                'text': 'Bóp kem đánh răng lên bàn chải',
                'imageUrl': 'https://via.placeholder.com/200x200?text=Toothpaste',
              },
              {
                'id': 'S3',
                'text': 'Chải răng',
                'imageUrl': 'https://via.placeholder.com/200x200?text=Brushing',
              },
              {
                'id': 'S4',
                'text': 'Súc miệng với nước',
                'imageUrl': 'https://via.placeholder.com/200x200?text=Rinsing',
              },
            ],
            'correctSequence': ['S1', 'S2', 'S3', 'S4'],
            'order': 1,
            'hint': 'Hãy nghĩ về thứ tự các bước khi bạn đánh răng mỗi ngày',
          },
          {
            'text': 'Hãy sắp xếp các số theo thứ tự từ nhỏ đến lớn',
            'type': AppConstants.sequentialQuiz,
            'options': [
              {
                'id': 'S1',
                'text': '1',
                'imageUrl': 'https://via.placeholder.com/200x200?text=1',
              },
              {
                'id': 'S2',
                'text': '2',
                'imageUrl': 'https://via.placeholder.com/200x200?text=2',
              },
              {
                'id': 'S3',
                'text': '3',
                'imageUrl': 'https://via.placeholder.com/200x200?text=3',
              },
              {
                'id': 'S4',
                'text': '4',
                'imageUrl': 'https://via.placeholder.com/200x200?text=4',
              },
              {
                'id': 'S5',
                'text': '5',
                'imageUrl': 'https://via.placeholder.com/200x200?text=5',
              },
            ],
            'correctSequence': ['S1', 'S2', 'S3', 'S4', 'S5'],
            'order': 2,
            'hint': 'Hãy đếm từ 1 đến 5',
          },
        ],
      },
    ];

    // Add quizzes to Firestore
    for (final quizData in sampleQuizzes) {
      final questions = quizData.remove('questions') as List<Map<String, dynamic>>;

      // Add quiz
      final quizRef = await _firestore.collection('quizzes').add(quizData);

      // Add questions
      for (final questionData in questions) {
        questionData['quizId'] = quizRef.id;
        await _firestore.collection('questions').add(questionData);
      }

      // Update quiz with questionCount
      await quizRef.update({'questionCount': questions.length});
    }
  }

  Future<void> _generateSampleProgress(String userId) async {
    // Get quizzes
    final quizzesSnapshot = await _firestore.collection('quizzes').limit(3).get();

    if (quizzesSnapshot.docs.isEmpty) return;

    // Sample progress data
    final List<Map<String, dynamic>> sampleProgress = [];

    for (final quizDoc in quizzesSnapshot.docs) {
      final quizId = quizDoc.id;
      final quizData = quizDoc.data();

      // Get questions for this quiz
      final questionsSnapshot = await _firestore
          .collection('questions')
          .where('quizId', isEqualTo: quizId)
          .get();

      if (questionsSnapshot.docs.isEmpty) continue;

      // Create random progress
      final int totalQuestions = questionsSnapshot.docs.length;
      final int score = totalQuestions > 1
          ? 1 + (DateTime.now().millisecondsSinceEpoch % (totalQuestions - 1))
          : 1;

      // Create attempts
      final List<Map<String, dynamic>> attempts = [];

      for (int i = 0; i < totalQuestions; i++) {
        final questionDoc = questionsSnapshot.docs[i];
        final isCorrect = i < score;

        attempts.add({
          'questionId': questionDoc.id,
          'isCorrect': isCorrect,
          'userAnswer': 'Sample answer',
          'attemptCount': 1,
          'timeSpentSeconds': 30 + (i * 5),
        });
      }

      sampleProgress.add({
        'userId': userId,
        'quizId': quizId,
        'score': score,
        'totalQuestions': totalQuestions,
        'attempts': attempts,
        'completedAt': Timestamp.fromDate(
          DateTime.now().subtract(Duration(days: sampleProgress.length)),
        ),
        'timeSpentSeconds': 30 * totalQuestions,
        'starsEarned': score,
      });
    }

    // Add progress to Firestore
    for (final progressData in sampleProgress) {
      await _firestore.collection('user_progress').add(progressData);
    }
  }

  Future<void> _generateSampleBadges(String userId) async {
    // Sample badges
    final List<Map<String, dynamic>> sampleBadges = [
      {
        'name': 'Người mới bắt đầu',
        'description': 'Hoàn thành bài học đầu tiên',
        'imageUrl': 'https://cdn-icons-png.flaticon.com/512/2583/2583344.png',
        'category': BadgeCategories.completion,
        'requiredPoints': 10,
        'isUnlocked': true,
        'unlockedAt': Timestamp.now(),
      },
      {
        'name': 'Học sinh chăm chỉ',
        'description': 'Hoàn thành 5 bài học',
        'imageUrl': 'https://cdn-icons-png.flaticon.com/512/2583/2583319.png',
        'category': BadgeCategories.completion,
        'requiredPoints': 50,
        'isUnlocked': false,
      },
      {
        'name': 'Siêu sao',
        'description': 'Đạt điểm tuyệt đối trong một bài học',
        'imageUrl': 'https://cdn-icons-png.flaticon.com/512/2583/2583434.png',
        'category': BadgeCategories.mastery,
        'requiredPoints': 100,
        'isUnlocked': false,
      },
      {
        'name': 'Học liên tục 3 ngày',
        'description': 'Học tập 3 ngày liên tiếp',
        'imageUrl': 'https://cdn-icons-png.flaticon.com/512/2583/2583383.png',
        'category': BadgeCategories.streak,
        'requiredPoints': 30,
        'isUnlocked': false,
      },
      {
        'name': 'Chuyên gia cảm xúc',
        'description': 'Hoàn thành tất cả bài học về cảm xúc',
        'imageUrl': 'https://cdn-icons-png.flaticon.com/512/2583/2583350.png',
        'category': BadgeCategories.special,
        'requiredPoints': 200,
        'isUnlocked': false,
      },
    ];

    // Add sample badges to Firestore
    for (final badge in sampleBadges) {
      await _firestore.collection('users').doc(userId).collection('badges').add(badge);
    }
  }

  Future<void> _generateSampleRewards() async {
    // Sample rewards
    final List<Map<String, dynamic>> sampleRewards = [
      {
        'name': 'Hình nền Vũ trụ',
        'description': 'Hình nền vũ trụ đầy sao',
        'imageUrl': 'https://cdn.pixabay.com/photo/2016/10/20/18/35/earth-1756274_960_720.jpg',
        'type': RewardTypes.background,
        'cost': 100,
      },
      {
        'name': 'Nhân vật Robot',
        'description': 'Nhân vật robot thông minh',
        'imageUrl': 'https://cdn-icons-png.flaticon.com/512/4616/4616934.png',
        'type': RewardTypes.character,
        'cost': 150,
      },
      {
        'name': 'Huy hiệu Siêu nhân',
        'description': 'Huy hiệu siêu nhân cho avatar',
        'imageUrl': 'https://cdn-icons-png.flaticon.com/512/1674/1674291.png',
        'type': RewardTypes.accessory,
        'cost': 50,
      },
      {
        'name': 'Chủ đề Đại dương',
        'description': 'Chủ đề màu xanh đại dương',
        'imageUrl': 'https://cdn.pixabay.com/photo/2016/11/23/13/48/beach-1852945_960_720.jpg',
        'type': RewardTypes.theme,
        'cost': 200,
      },
      {
        'name': 'Avatar Khủng long',
        'description': 'Avatar khủng long dễ thương',
        'imageUrl': 'https://cdn-icons-png.flaticon.com/512/3196/3196017.png',
        'type': RewardTypes.avatar,
        'cost': 80,
      },
    ];

    // Add sample rewards to Firestore
    for (final reward in sampleRewards) {
      await _firestore.collection('rewards').add(reward);
    }
  }

  Future<void> _generateSampleCurrency(String userId) async {
    // Sample currency
    final Map<String, dynamic> sampleCurrency = {
      'stars': 15,
      'coins': 200,
      'gems': 5,
      'lastUpdated': Timestamp.now(),
    };

    // Add sample currency to Firestore
    await _firestore.collection('users').doc(userId).collection('currency').doc('main').set(sampleCurrency);
  }

  Future<void> _generateSampleAnalytics(String userId) async {
    // Sample analytics
    final Map<String, dynamic> sampleAnalytics = {
      'totalQuizzesTaken': 8,
      'totalCorrectAnswers': 32,
      'totalQuestions': 40,
      'totalTimeSpentSeconds': 1200,
      'totalStarsEarned': 15,
      'quizTypeDistribution': {
        'choices_quiz': 3,
        'pairing_quiz': 2,
        'sequential_quiz': 2,
        'emotions_quiz': 1,
      },
      'performanceByQuizType': {
        'choices_quiz': 0.85,
        'pairing_quiz': 0.7,
        'sequential_quiz': 0.8,
        'emotions_quiz': 0.9,
      },
      'recentPerformance': [
        {
          'quizId': 'sample_quiz_1',
          'quizTitle': 'Bài học lựa chọn cơ bản',
          'quizType': 'choices_quiz',
          'score': 8,
          'totalQuestions': 10,
          'timeSpentSeconds': 180,
          'starsEarned': 2,
          'completedAt': Timestamp.now(),
        },
        {
          'quizId': 'sample_quiz_2',
          'quizTitle': 'Bài học ghép đôi đơn giản',
          'quizType': 'pairing_quiz',
          'score': 5,
          'totalQuestions': 5,
          'timeSpentSeconds': 120,
          'starsEarned': 3,
          'completedAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 1))),
        },
        {
          'quizId': 'sample_quiz_3',
          'quizTitle': 'Bài học sắp xếp cơ bản',
          'quizType': 'sequential_quiz',
          'score': 4,
          'totalQuestions': 5,
          'timeSpentSeconds': 150,
          'starsEarned': 2,
          'completedAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 2))),
        },
        {
          'quizId': 'sample_quiz_4',
          'quizTitle': 'Nhận diện cảm xúc cơ bản',
          'quizType': 'emotions_quiz',
          'score': 4,
          'totalQuestions': 4,
          'timeSpentSeconds': 90,
          'starsEarned': 3,
          'completedAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 3))),
        },
      ],
      'lastUpdated': Timestamp.now(),
    };

    // Add sample analytics to Firestore
    await _firestore.collection('users').doc(userId).collection('analytics').doc('main').set(sampleAnalytics);

    // Tạo dữ liệu mẫu cho học sinh (nếu là giáo viên)
    final userDoc = await _firestore.collection('users').doc(userId).get();
    if (userDoc.exists) {
      final userData = userDoc.data();
      final role = userData?['role'];

      if (role == 'teacher') {
        // Tạo học sinh mẫu
        final sampleStudentIds = [
          'student1',
          'student2',
          'student3',
        ];

        for (final studentId in sampleStudentIds) {
          // Tạo thông tin học sinh
          await _firestore.collection('users').doc(studentId).set({
            'name': 'Học sinh ${studentId.substring(7)}',
            'email': '$studentId@example.com',
            'role': 'student',
            'createdAt': Timestamp.now(),
            'updatedAt': Timestamp.now(),
          });

          // Tạo phân tích dữ liệu cho học sinh
          final studentAnalytics = Map<String, dynamic>.from(sampleAnalytics);
          studentAnalytics['totalQuizzesTaken'] = 5 + int.parse(studentId.substring(7));
          studentAnalytics['totalCorrectAnswers'] = 20 + int.parse(studentId.substring(7)) * 2;
          studentAnalytics['totalQuestions'] = 25 + int.parse(studentId.substring(7)) * 2;

          await _firestore.collection('users').doc(studentId).collection('analytics').doc('main').set(studentAnalytics);
        }
      }
    }
  }

  Future<void> _generateSampleAssessments(String userId) async {
    // Kiểm tra vai trò người dùng
    final userDoc = await _firestore.collection('users').doc(userId).get();
    if (!userDoc.exists) return;

    final userData = userDoc.data();
    final role = userData?['role'];

    if (role == 'teacher') {
      // Lấy danh sách học sinh mẫu
      final sampleStudentIds = [
        'student1',
        'student2',
        'student3',
      ];

      for (final studentId in sampleStudentIds) {
        // Tạo đánh giá mẫu
        final skillCategories = DefaultSkillCategories.getDefaultCategories();

        // Cập nhật một số kỹ năng để tạo dữ liệu đa dạng
        final updatedSkillCategories = Map<String, SkillCategory>.from(skillCategories);

        // Cập nhật kỹ năng giao tiếp
        final communicationSkills = Map<String, Skill>.from(updatedSkillCategories['communication']!.skills);
        communicationSkills['verbal'] = communicationSkills['verbal']!.copyWith(level: 3);
        communicationSkills['nonverbal'] = communicationSkills['nonverbal']!.copyWith(level: 2);
        updatedSkillCategories['communication'] = updatedSkillCategories['communication']!.copyWith(
          skills: communicationSkills,
        );

        // Cập nhật kỹ năng xã hội
        final socialSkills = Map<String, Skill>.from(updatedSkillCategories['social']!.skills);
        socialSkills['turntaking'] = socialSkills['turntaking']!.copyWith(level: 2);
        socialSkills['sharing'] = socialSkills['sharing']!.copyWith(level: 3);
        updatedSkillCategories['social'] = updatedSkillCategories['social']!.copyWith(
          skills: socialSkills,
        );

        // Tạo đánh giá
        final assessment = {
          'studentId': studentId,
          'teacherId': userId,
          'skillCategories': updatedSkillCategories.map((key, category) {
            return MapEntry(key, {
              'name': category.name,
              'skills': category.skills.map((skillKey, skill) {
                return MapEntry(skillKey, {
                  'name': skill.name,
                  'description': skill.description,
                  'level': skill.level,
                  'notes': skill.notes,
                });
              }),
            });
          }),
          'notes': 'Học sinh có tiến bộ trong giao tiếp và kỹ năng xã hội.',
          'assessmentDate': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 7))),
          'createdAt': Timestamp.now(),
          'updatedAt': Timestamp.now(),
        };

        await _firestore.collection('skill_assessments').add(assessment);
      }
    } else if (role == 'student') {
      // Tạo đánh giá mẫu cho học sinh
      final skillCategories = DefaultSkillCategories.getDefaultCategories();

      // Cập nhật một số kỹ năng để tạo dữ liệu đa dạng
      final updatedSkillCategories = Map<String, SkillCategory>.from(skillCategories);

      // Cập nhật kỹ năng giao tiếp
      final communicationSkills = Map<String, Skill>.from(updatedSkillCategories['communication']!.skills);
      communicationSkills['verbal'] = communicationSkills['verbal']!.copyWith(level: 2);
      updatedSkillCategories['communication'] = updatedSkillCategories['communication']!.copyWith(
        skills: communicationSkills,
      );

      // Tạo đánh giá
      final assessment = {
        'studentId': userId,
        'teacherId': 'teacher1',
        'skillCategories': updatedSkillCategories.map((key, category) {
          return MapEntry(key, {
            'name': category.name,
            'skills': category.skills.map((skillKey, skill) {
              return MapEntry(skillKey, {
                'name': skill.name,
                'description': skill.description,
                'level': skill.level,
                'notes': skill.notes,
              });
            }),
          });
        }),
        'notes': 'Học sinh cần cải thiện kỹ năng giao tiếp.',
        'assessmentDate': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 14))),
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      };

      await _firestore.collection('skill_assessments').add(assessment);
    }
  }

  Future<void> _generateSampleSchedules(String userId) async {
    // Kiểm tra vai trò người dùng
    final userDoc = await _firestore.collection('users').doc(userId).get();
    if (!userDoc.exists) return;

    final userData = userDoc.data();
    final role = userData?['role'];

    // Tạo lịch học mẫu
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final sampleSchedules = [
      // Lịch học hôm nay
      {
        'userId': userId,
        'title': 'Bài học giao tiếp cơ bản',
        'description': 'Tập trung vào kỹ năng giao tiếp bằng lời',
        'startTime': Timestamp.fromDate(today.add(const Duration(hours: 9))),
        'endTime': Timestamp.fromDate(today.add(const Duration(hours: 10))),
        'isRecurring': true,
        'recurrenceType': 'weekly',
        'recurrenceDays': [1, 3, 5], // Thứ 2, 4, 6
        'hasReminder': true,
        'reminderMinutesBefore': 30,
        'type': 'lesson',
        'relatedId': '',
        'isCompleted': false,
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      },
      // Lịch học ngày mai
      {
        'userId': userId,
        'title': 'Trị liệu ngôn ngữ',
        'description': 'Phát triển kỹ năng ngôn ngữ và giao tiếp',
        'startTime': Timestamp.fromDate(today.add(const Duration(days: 1, hours: 14))),
        'endTime': Timestamp.fromDate(today.add(const Duration(days: 1, hours: 15))),
        'isRecurring': false,
        'recurrenceType': 'daily',
        'recurrenceDays': [],
        'hasReminder': true,
        'reminderMinutesBefore': 60,
        'type': 'therapy',
        'relatedId': '',
        'isCompleted': false,
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      },
      // Đánh giá tuần sau
      {
        'userId': userId,
        'title': 'Đánh giá kỹ năng định kỳ',
        'description': 'Đánh giá tiến bộ và phát triển kỹ năng',
        'startTime': Timestamp.fromDate(today.add(const Duration(days: 7, hours: 10))),
        'endTime': Timestamp.fromDate(today.add(const Duration(days: 7, hours: 11))),
        'isRecurring': false,
        'recurrenceType': 'daily',
        'recurrenceDays': [],
        'hasReminder': true,
        'reminderMinutesBefore': 120,
        'type': 'assessment',
        'relatedId': '',
        'isCompleted': false,
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      },
    ];

    // Thêm lịch học đã hoàn thành
    final completedSchedule = {
      'userId': userId,
      'title': 'Bài học về cảm xúc',
      'description': 'Nhận biết và biểu đạt cảm xúc',
      'startTime': Timestamp.fromDate(today.subtract(const Duration(days: 1, hours: 9))),
      'endTime': Timestamp.fromDate(today.subtract(const Duration(days: 1, hours: 8))),
      'isRecurring': false,
      'recurrenceType': 'daily',
      'recurrenceDays': [],
      'hasReminder': false,
      'reminderMinutesBefore': 30,
      'type': 'lesson',
      'relatedId': '',
      'isCompleted': true,
      'createdAt': Timestamp.now(),
      'updatedAt': Timestamp.now(),
    };

    sampleSchedules.add(completedSchedule);

    // Nếu là giáo viên, thêm lịch học cho học sinh
    if (role == 'teacher') {
      final sampleStudentIds = [
        'student1',
        'student2',
        'student3',
      ];

      for (final studentId in sampleStudentIds) {
        final studentSchedule = {
          'userId': studentId,
          'title': 'Buổi học cá nhân',
          'description': 'Buổi học riêng với giáo viên',
          'startTime': Timestamp.fromDate(today.add(const Duration(days: 2, hours: 10))),
          'endTime': Timestamp.fromDate(today.add(const Duration(days: 2, hours: 11))),
          'isRecurring': false,
          'recurrenceType': 'daily',
          'recurrenceDays': [],
          'hasReminder': true,
          'reminderMinutesBefore': 30,
          'type': 'lesson',
          'relatedId': '',
          'isCompleted': false,
          'createdAt': Timestamp.now(),
          'updatedAt': Timestamp.now(),
        };

        await _firestore.collection('schedules').add(studentSchedule);
      }
    }

    // Thêm lịch học mẫu vào Firestore
    for (final schedule in sampleSchedules) {
      await _firestore.collection('schedules').add(schedule);
    }
  }
}
