import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/teacher_student_repository.dart';
import '../../../data/models/user_model.dart';
import 'teacher_student_event.dart';
import 'teacher_student_state.dart';

class TeacherStudentBloc extends Bloc<TeacherStudentEvent, TeacherStudentState> {
  final TeacherStudentRepository _repository;

  TeacherStudentBloc({required TeacherStudentRepository repository})
      : _repository = repository,
        super(TeacherStudentInitial()) {
    on<LoadTeacherStudents>(_onLoadTeacherStudents);
    on<LoadStudentTeacher>(_onLoadStudentTeacher);
    on<LinkTeacherStudent>(_onLinkTeacherStudent);
    on<UnlinkTeacherStudent>(_onUnlinkTeacherStudent);
  }

  Future<void> _onLoadTeacherStudents(
    LoadTeacherStudents event,
    Emitter<TeacherStudentState> emit,
  ) async {
    try {
      emit(TeacherStudentLoading());
      final result = await _repository.getTeacherStudents(event.teacherId);
      result.fold(
        (failure) => emit(TeacherStudentError(failure.message)),
        (students) => emit(TeacherStudentsLoaded(students)),
      );
    } catch (e) {
      emit(TeacherStudentError(e.toString()));
    }
  }

  Future<void> _onLoadStudentTeacher(
    LoadStudentTeacher event,
    Emitter<TeacherStudentState> emit,
  ) async {
    try {
      emit(TeacherStudentLoading());
      final result = await _repository.getStudentTeacher(event.studentId);
      result.fold(
        (failure) => emit(TeacherStudentError(failure.message)),
        (teacher) => emit(StudentTeacherLoaded(teacher)),
      );
    } catch (e) {
      emit(TeacherStudentError(e.toString()));
    }
  }

  Future<void> _onLinkTeacherStudent(
    LinkTeacherStudent event,
    Emitter<TeacherStudentState> emit,
  ) async {
    try {
      emit(TeacherStudentLoading());
      final result = await _repository.linkTeacherStudent(
        teacherId: event.teacherId,
        studentId: event.studentId,
      );
      result.fold(
        (failure) => emit(TeacherStudentError(failure.message)),
        (_) => emit(TeacherStudentLinked()),
      );
      add(LoadTeacherStudents(event.teacherId));
    } catch (e) {
      emit(TeacherStudentError(e.toString()));
    }
  }

  Future<void> _onUnlinkTeacherStudent(
    UnlinkTeacherStudent event,
    Emitter<TeacherStudentState> emit,
  ) async {
    try {
      emit(TeacherStudentLoading());
      final result = await _repository.unlinkTeacherStudent(
        teacherId: event.teacherId,
        studentId: event.studentId,
      );
      result.fold(
        (failure) => emit(TeacherStudentError(failure.message)),
        (_) => emit(TeacherStudentUnlinked()),
      );
      add(LoadTeacherStudents(event.teacherId));
    } catch (e) {
      emit(TeacherStudentError(e.toString()));
    }
  }
} 