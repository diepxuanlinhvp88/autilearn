import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_constants.dart';

class QuestionModel extends Equatable {
  final String id;
  final String quizId;
  final String text;
  final String? audioUrl;
  final String type; // 'choices', 'pairing', 'sequential'
  final List<AnswerOption> options;
  final List<String>? correctSequence; // For sequential quiz
  final Map<String, String>? correctPairs; // For pairing quiz
  final String? correctOptionId; // For choices quiz
  final String? imageUrl;
  final int order;
  final String? hint;

  const QuestionModel({
    required this.id,
    required this.quizId,
    required this.text,
    this.audioUrl,
    required this.type,
    required this.options,
    this.correctSequence,
    this.correctPairs,
    this.correctOptionId,
    this.imageUrl,
    required this.order,
    this.hint,
  });

  factory QuestionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    List<AnswerOption> options = [];
    if (data['options'] != null) {
      options = List<AnswerOption>.from(
        (data['options'] as List).map(
          (option) => AnswerOption.fromMap(option),
        ),
      );
    }

    List<String>? correctSequence;
    if (data['correctSequence'] != null) {
      correctSequence = List<String>.from(data['correctSequence']);
    }

    Map<String, String>? correctPairs;
    if (data['correctPairs'] != null) {
      correctPairs = Map<String, String>.from(data['correctPairs']);
    }

    return QuestionModel(
      id: doc.id,
      quizId: data['quizId'] ?? '',
      text: data['text'] ?? '',
      audioUrl: data['audioUrl'],
      type: data['type'] ?? '',
      options: options,
      correctSequence: correctSequence,
      correctPairs: correctPairs,
      correctOptionId: data['correctOptionId'],
      imageUrl: data['imageUrl'],
      order: data['order'] ?? 0,
      hint: data['hint'],
    );
  }

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> map = {
      'quizId': quizId,
      'text': text,
      'audioUrl': audioUrl,
      'type': type,
      'options': options.map((option) => option.toMap()).toList(),
      'imageUrl': imageUrl,
      'order': order,
      'hint': hint,
    };

    if (type == AppConstants.choicesQuiz) {
      map['correctOptionId'] = correctOptionId;
    } else if (type == AppConstants.sequentialQuiz) {
      map['correctSequence'] = correctSequence;
    } else if (type == AppConstants.pairingQuiz) {
      map['correctPairs'] = correctPairs;
    }

    return map;
  }

  QuestionModel copyWith({
    String? id,
    String? quizId,
    String? text,
    String? audioUrl,
    String? type,
    List<AnswerOption>? options,
    List<String>? correctSequence,
    Map<String, String>? correctPairs,
    String? correctOptionId,
    String? imageUrl,
    int? order,
    String? hint,
  }) {
    return QuestionModel(
      id: id ?? this.id,
      quizId: quizId ?? this.quizId,
      text: text ?? this.text,
      audioUrl: audioUrl ?? this.audioUrl,
      type: type ?? this.type,
      options: options ?? this.options,
      correctSequence: correctSequence ?? this.correctSequence,
      correctPairs: correctPairs ?? this.correctPairs,
      correctOptionId: correctOptionId ?? this.correctOptionId,
      imageUrl: imageUrl ?? this.imageUrl,
      order: order ?? this.order,
      hint: hint ?? this.hint,
    );
  }

  @override
  List<Object?> get props => [
        id,
        quizId,
        text,
        audioUrl,
        type,
        options,
        correctSequence,
        correctPairs,
        correctOptionId,
        imageUrl,
        order,
        hint,
      ];
}

class AnswerOption extends Equatable {
  final String id;
  final String text;
  final String? imageUrl;

  const AnswerOption({
    required this.id,
    required this.text,
    this.imageUrl,
  });

  factory AnswerOption.fromMap(Map<String, dynamic> map) {
    return AnswerOption(
      id: map['id'] ?? '',
      text: map['text'] ?? '',
      imageUrl: map['imageUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'imageUrl': imageUrl,
    };
  }

  @override
  List<Object?> get props => [id, text, imageUrl];
}
