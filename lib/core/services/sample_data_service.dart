import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/models/quiz_model.dart';
import '../../data/models/question_model.dart';
import '../../data/models/user_progress_model.dart';
import '../constants/app_constants.dart';

class SampleDataService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  Future<void> generateSampleData(String userId) async {
    await _generateSampleQuizzes(userId);
    await _generateSampleProgress(userId);
  }
  
  Future<void> _generateSampleQuizzes(String userId) async {
    // Sample quizzes
    final List<Map<String, dynamic>> sampleQuizzes = [
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
                'imageUrl': 'https://placekitten.com/200/200',
              },
              {
                'id': 'B',
                'text': 'Chó',
                'imageUrl': 'https://placedog.net/200/200',
              },
              {
                'id': 'C',
                'text': 'Gà',
                'imageUrl': 'https://via.placeholder.com/200x200?text=Chicken',
              },
              {
                'id': 'D',
                'text': 'Vịt',
                'imageUrl': 'https://via.placeholder.com/200x200?text=Duck',
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
                'imageUrl': 'https://placekitten.com/200/200',
              },
              {
                'id': 'B',
                'text': 'Chó',
                'imageUrl': 'https://placedog.net/200/200',
              },
              {
                'id': 'C',
                'text': 'Gà',
                'imageUrl': 'https://via.placeholder.com/200x200?text=Chicken',
              },
              {
                'id': 'D',
                'text': 'Vịt',
                'imageUrl': 'https://via.placeholder.com/200x200?text=Duck',
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
                'imageUrl': 'https://placekitten.com/200/200',
              },
              {
                'id': 'B',
                'text': 'Chó',
                'imageUrl': 'https://placedog.net/200/200',
              },
              {
                'id': 'C',
                'text': 'Gà',
                'imageUrl': 'https://via.placeholder.com/200x200?text=Chicken',
              },
              {
                'id': 'D',
                'text': 'Vịt',
                'imageUrl': 'https://via.placeholder.com/200x200?text=Duck',
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
                'imageUrl': 'https://placekitten.com/200/200',
              },
              {
                'id': 'B',
                'text': 'Chó',
                'imageUrl': 'https://placedog.net/200/200',
              },
              {
                'id': 'C',
                'text': 'Gà',
                'imageUrl': 'https://via.placeholder.com/200x200?text=Chicken',
              },
              {
                'id': 'D',
                'text': 'Vịt',
                'imageUrl': 'https://via.placeholder.com/200x200?text=Duck',
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
                'text': 'Thỏ',
                'imageUrl': 'https://via.placeholder.com/200x200?text=Rabbit',
              },
              {
                'id': 'B',
                'text': 'Chuột',
                'imageUrl': 'https://via.placeholder.com/200x200?text=Mouse',
              },
              {
                'id': 'C',
                'text': 'Sóc',
                'imageUrl': 'https://via.placeholder.com/200x200?text=Squirrel',
              },
              {
                'id': 'D',
                'text': 'Cáo',
                'imageUrl': 'https://via.placeholder.com/200x200?text=Fox',
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
                'imageUrl': 'https://via.placeholder.com/200x200/FF0000/FFFFFF?text=Red',
              },
              {
                'id': 'B',
                'text': 'Xanh dương',
                'imageUrl': 'https://via.placeholder.com/200x200/0000FF/FFFFFF?text=Blue',
              },
              {
                'id': 'C',
                'text': 'Xanh lá',
                'imageUrl': 'https://via.placeholder.com/200x200/00FF00/FFFFFF?text=Green',
              },
              {
                'id': 'D',
                'text': 'Vàng',
                'imageUrl': 'https://via.placeholder.com/200x200/FFFF00/000000?text=Yellow',
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
                'imageUrl': 'https://via.placeholder.com/200x200/FF0000/FFFFFF?text=Red',
              },
              {
                'id': 'B',
                'text': 'Xanh dương',
                'imageUrl': 'https://via.placeholder.com/200x200/0000FF/FFFFFF?text=Blue',
              },
              {
                'id': 'C',
                'text': 'Xanh lá',
                'imageUrl': 'https://via.placeholder.com/200x200/00FF00/FFFFFF?text=Green',
              },
              {
                'id': 'D',
                'text': 'Vàng',
                'imageUrl': 'https://via.placeholder.com/200x200/FFFF00/000000?text=Yellow',
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
                'imageUrl': 'https://via.placeholder.com/200x200/FF0000/FFFFFF?text=Red',
              },
              {
                'id': 'B',
                'text': 'Xanh dương',
                'imageUrl': 'https://via.placeholder.com/200x200/0000FF/FFFFFF?text=Blue',
              },
              {
                'id': 'C',
                'text': 'Xanh lá',
                'imageUrl': 'https://via.placeholder.com/200x200/00FF00/FFFFFF?text=Green',
              },
              {
                'id': 'D',
                'text': 'Vàng',
                'imageUrl': 'https://via.placeholder.com/200x200/FFFF00/000000?text=Yellow',
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
                'imageUrl': 'https://via.placeholder.com/200x200/FF0000/FFFFFF?text=Red',
              },
              {
                'id': 'B',
                'text': 'Xanh dương',
                'imageUrl': 'https://via.placeholder.com/200x200/0000FF/FFFFFF?text=Blue',
              },
              {
                'id': 'C',
                'text': 'Xanh lá',
                'imageUrl': 'https://via.placeholder.com/200x200/00FF00/FFFFFF?text=Green',
              },
              {
                'id': 'D',
                'text': 'Vàng',
                'imageUrl': 'https://via.placeholder.com/200x200/FFFF00/000000?text=Yellow',
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
                'imageUrl': 'https://placekitten.com/200/200',
              },
              {
                'id': 'L2',
                'text': 'Chó',
                'imageUrl': 'https://placedog.net/200/200',
              },
              {
                'id': 'L3',
                'text': 'Gà',
                'imageUrl': 'https://via.placeholder.com/200x200?text=Chicken',
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
}
