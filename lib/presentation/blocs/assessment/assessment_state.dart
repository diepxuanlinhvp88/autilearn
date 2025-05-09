import 'package:equatable/equatable.dart';
import '../../../data/models/skill_assessment_model.dart';

abstract class AssessmentState extends Equatable {
  const AssessmentState();

  @override
  List<Object?> get props => [];
}

class AssessmentInitial extends AssessmentState {
  const AssessmentInitial();
}

class AssessmentLoading extends AssessmentState {
  const AssessmentLoading();
}

class StudentAssessmentsLoaded extends AssessmentState {
  final List<SkillAssessmentModel> assessments;

  const StudentAssessmentsLoaded(this.assessments);

  @override
  List<Object?> get props => [assessments];
}

class TeacherAssessmentsLoaded extends AssessmentState {
  final List<SkillAssessmentModel> assessments;

  const TeacherAssessmentsLoaded(this.assessments);

  @override
  List<Object?> get props => [assessments];
}

class AssessmentLoaded extends AssessmentState {
  final SkillAssessmentModel assessment;

  const AssessmentLoaded(this.assessment);

  @override
  List<Object?> get props => [assessment];
}

class AssessmentCreated extends AssessmentState {
  final String assessmentId;

  const AssessmentCreated(this.assessmentId);

  @override
  List<Object?> get props => [assessmentId];
}

class AssessmentUpdated extends AssessmentState {
  const AssessmentUpdated();
}

class AssessmentDeleted extends AssessmentState {
  const AssessmentDeleted();
}

class AssessmentError extends AssessmentState {
  final String message;

  const AssessmentError(this.message);

  @override
  List<Object?> get props => [message];
}
