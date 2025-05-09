import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ScheduleModel extends Equatable {
  final String id;
  final String userId;
  final String title;
  final String description;
  final DateTime startTime;
  final DateTime endTime;
  final bool isRecurring;
  final RecurrenceType recurrenceType;
  final List<int> recurrenceDays; // 1-7: Thứ 2 - Chủ nhật
  final DateTime? recurrenceEndDate;
  final bool hasReminder;
  final int reminderMinutesBefore;
  final ScheduleType type;
  final String relatedId; // ID của bài học, đánh giá, v.v.
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ScheduleModel({
    required this.id,
    required this.userId,
    required this.title,
    this.description = '',
    required this.startTime,
    required this.endTime,
    this.isRecurring = false,
    this.recurrenceType = RecurrenceType.daily,
    this.recurrenceDays = const [],
    this.recurrenceEndDate,
    this.hasReminder = false,
    this.reminderMinutesBefore = 30,
    this.type = ScheduleType.lesson,
    this.relatedId = '',
    this.isCompleted = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ScheduleModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return ScheduleModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      startTime: data['startTime'] != null 
          ? (data['startTime'] as Timestamp).toDate() 
          : DateTime.now(),
      endTime: data['endTime'] != null 
          ? (data['endTime'] as Timestamp).toDate() 
          : DateTime.now().add(const Duration(hours: 1)),
      isRecurring: data['isRecurring'] ?? false,
      recurrenceType: _parseRecurrenceType(data['recurrenceType']),
      recurrenceDays: data['recurrenceDays'] != null 
          ? List<int>.from(data['recurrenceDays']) 
          : [],
      recurrenceEndDate: data['recurrenceEndDate'] != null 
          ? (data['recurrenceEndDate'] as Timestamp).toDate() 
          : null,
      hasReminder: data['hasReminder'] ?? false,
      reminderMinutesBefore: data['reminderMinutesBefore'] ?? 30,
      type: _parseScheduleType(data['type']),
      relatedId: data['relatedId'] ?? '',
      isCompleted: data['isCompleted'] ?? false,
      createdAt: data['createdAt'] != null 
          ? (data['createdAt'] as Timestamp).toDate() 
          : DateTime.now(),
      updatedAt: data['updatedAt'] != null 
          ? (data['updatedAt'] as Timestamp).toDate() 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'description': description,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': Timestamp.fromDate(endTime),
      'isRecurring': isRecurring,
      'recurrenceType': recurrenceType.toString().split('.').last,
      'recurrenceDays': recurrenceDays,
      'recurrenceEndDate': recurrenceEndDate != null 
          ? Timestamp.fromDate(recurrenceEndDate!) 
          : null,
      'hasReminder': hasReminder,
      'reminderMinutesBefore': reminderMinutesBefore,
      'type': type.toString().split('.').last,
      'relatedId': relatedId,
      'isCompleted': isCompleted,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  ScheduleModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    DateTime? startTime,
    DateTime? endTime,
    bool? isRecurring,
    RecurrenceType? recurrenceType,
    List<int>? recurrenceDays,
    DateTime? recurrenceEndDate,
    bool? hasReminder,
    int? reminderMinutesBefore,
    ScheduleType? type,
    String? relatedId,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ScheduleModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      isRecurring: isRecurring ?? this.isRecurring,
      recurrenceType: recurrenceType ?? this.recurrenceType,
      recurrenceDays: recurrenceDays ?? this.recurrenceDays,
      recurrenceEndDate: recurrenceEndDate ?? this.recurrenceEndDate,
      hasReminder: hasReminder ?? this.hasReminder,
      reminderMinutesBefore: reminderMinutesBefore ?? this.reminderMinutesBefore,
      type: type ?? this.type,
      relatedId: relatedId ?? this.relatedId,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static RecurrenceType _parseRecurrenceType(String? value) {
    if (value == null) return RecurrenceType.daily;
    
    switch (value) {
      case 'daily':
        return RecurrenceType.daily;
      case 'weekly':
        return RecurrenceType.weekly;
      case 'monthly':
        return RecurrenceType.monthly;
      default:
        return RecurrenceType.daily;
    }
  }

  static ScheduleType _parseScheduleType(String? value) {
    if (value == null) return ScheduleType.lesson;
    
    switch (value) {
      case 'lesson':
        return ScheduleType.lesson;
      case 'assessment':
        return ScheduleType.assessment;
      case 'therapy':
        return ScheduleType.therapy;
      case 'reminder':
        return ScheduleType.reminder;
      default:
        return ScheduleType.lesson;
    }
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        title,
        description,
        startTime,
        endTime,
        isRecurring,
        recurrenceType,
        recurrenceDays,
        recurrenceEndDate,
        hasReminder,
        reminderMinutesBefore,
        type,
        relatedId,
        isCompleted,
        createdAt,
        updatedAt,
      ];
}

enum RecurrenceType {
  daily,
  weekly,
  monthly,
}

enum ScheduleType {
  lesson,
  assessment,
  therapy,
  reminder,
}
