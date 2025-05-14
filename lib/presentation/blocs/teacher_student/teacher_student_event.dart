import 'package:equatable/equatable.dart';

abstract class TeacherStudentEvent extends Equatable {
  const TeacherStudentEvent();

  @override
  List<Object?> get props => [];
}

class LoadTeacherStudents extends TeacherStudentEvent {
  final String teacherId;

  const LoadTeacherStudents(this.teacherId);

  @override
  List<Object?> get props => [teacherId];
}

class LoadStudentTeacher extends TeacherStudentEvent {
  final String studentId;

  const LoadStudentTeacher(this.studentId);

  @override
  List<Object?> get props => [studentId];
}

class LinkTeacherStudent extends TeacherStudentEvent {
  final String teacherId;
  final String studentId;

  const LinkTeacherStudent({
    required this.teacherId,
    required this.studentId,
  });

  @override
  List<Object?> get props => [teacherId, studentId];
}

class UnlinkTeacherStudent extends TeacherStudentEvent {
  final String teacherId;
  final String studentId;

  const UnlinkTeacherStudent({
    required this.teacherId,
    required this.studentId,
  });

  @override
  List<Object?> get props => [teacherId, studentId];
} 