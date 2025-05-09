import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/assessment_repository.dart';
import 'assessment_event.dart';
import 'assessment_state.dart';

class AssessmentBloc extends Bloc<AssessmentEvent, AssessmentState> {
  final AssessmentRepository assessmentRepository;

  AssessmentBloc({required this.assessmentRepository}) : super(const AssessmentInitial()) {
    on<LoadStudentAssessments>(_onLoadStudentAssessments);
    on<LoadTeacherAssessments>(_onLoadTeacherAssessments);
    on<LoadAssessment>(_onLoadAssessment);
    on<CreateAssessment>(_onCreateAssessment);
    on<UpdateAssessment>(_onUpdateAssessment);
    on<DeleteAssessment>(_onDeleteAssessment);
  }

  Future<void> _onLoadStudentAssessments(
    LoadStudentAssessments event,
    Emitter<AssessmentState> emit,
  ) async {
    emit(const AssessmentLoading());
    final result = await assessmentRepository.getStudentAssessments(event.studentId);

    await result.fold(
      (error) async {
        emit(AssessmentError('Không thể tải đánh giá: $error'));
      },
      (assessments) async {
        emit(StudentAssessmentsLoaded(assessments));
      },
    );
  }

  Future<void> _onLoadTeacherAssessments(
    LoadTeacherAssessments event,
    Emitter<AssessmentState> emit,
  ) async {
    emit(const AssessmentLoading());
    final result = await assessmentRepository.getTeacherAssessments(event.teacherId);

    await result.fold(
      (error) async {
        emit(AssessmentError('Không thể tải đánh giá: $error'));
      },
      (assessments) async {
        emit(TeacherAssessmentsLoaded(assessments));
      },
    );
  }

  Future<void> _onLoadAssessment(
    LoadAssessment event,
    Emitter<AssessmentState> emit,
  ) async {
    emit(const AssessmentLoading());
    final result = await assessmentRepository.getAssessment(event.assessmentId);

    await result.fold(
      (error) async {
        emit(AssessmentError('Không thể tải đánh giá: $error'));
      },
      (assessment) async {
        emit(AssessmentLoaded(assessment));
      },
    );
  }

  Future<void> _onCreateAssessment(
    CreateAssessment event,
    Emitter<AssessmentState> emit,
  ) async {
    emit(const AssessmentLoading());
    final result = await assessmentRepository.createAssessment(event.assessment);

    await result.fold(
      (error) async {
        emit(AssessmentError('Không thể tạo đánh giá: $error'));
      },
      (assessmentId) async {
        emit(AssessmentCreated(assessmentId));
      },
    );
  }

  Future<void> _onUpdateAssessment(
    UpdateAssessment event,
    Emitter<AssessmentState> emit,
  ) async {
    emit(const AssessmentLoading());
    final result = await assessmentRepository.updateAssessment(event.assessment);

    await result.fold(
      (error) async {
        emit(AssessmentError('Không thể cập nhật đánh giá: $error'));
      },
      (_) async {
        emit(const AssessmentUpdated());
      },
    );
  }

  Future<void> _onDeleteAssessment(
    DeleteAssessment event,
    Emitter<AssessmentState> emit,
  ) async {
    emit(const AssessmentLoading());
    final result = await assessmentRepository.deleteAssessment(event.assessmentId);

    await result.fold(
      (error) async {
        emit(AssessmentError('Không thể xóa đánh giá: $error'));
      },
      (_) async {
        emit(const AssessmentDeleted());
      },
    );
  }
}
