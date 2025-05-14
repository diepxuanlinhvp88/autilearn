import 'package:equatable/equatable.dart';
import '../../../data/models/user_model.dart';

abstract class TeacherStudentState extends Equatable {
  const TeacherStudentState();

  @override
  List<Object?> get props => [];
}

class TeacherStudentInitial extends TeacherStudentState {}

class TeacherStudentLoading extends TeacherStudentState {}

class TeacherStudentsLoaded extends TeacherStudentState {
  final List<UserModel> students;

  const TeacherStudentsLoaded(this.students);

  @override
  List<Object?> get props => [students];
}

class StudentTeacherLoaded extends TeacherStudentState {
  final UserModel? teacher;

  const StudentTeacherLoaded(this.teacher);

  @override
  List<Object?> get props => [teacher];
}

class TeacherStudentLinked extends TeacherStudentState {}

class TeacherStudentUnlinked extends TeacherStudentState {}

class TeacherStudentError extends TeacherStudentState {
  final String message;

  const TeacherStudentError(this.message);

  @override
  List<Object?> get props => [message];
} 