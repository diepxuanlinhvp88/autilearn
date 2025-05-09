import 'package:equatable/equatable.dart';
import '../../../data/models/skill_assessment_model.dart';

abstract class AssessmentEvent extends Equatable {
  const AssessmentEvent();

  @override
  List<Object?> get props => [];
}

class LoadStudentAssessments extends AssessmentEvent {
  final String studentId;

  const LoadStudentAssessments(this.studentId);

  @override
  List<Object?> get props => [studentId];
}

class LoadTeacherAssessments extends AssessmentEvent {
  final String teacherId;

  const LoadTeacherAssessments(this.teacherId);

  @override
  List<Object?> get props => [teacherId];
}

class LoadAssessment extends AssessmentEvent {
  final String assessmentId;

  const LoadAssessment(this.assessmentId);

  @override
  List<Object?> get props => [assessmentId];
}

class CreateAssessment extends AssessmentEvent {
  final SkillAssessmentModel assessment;

  const CreateAssessment(this.assessment);

  @override
  List<Object?> get props => [assessment];
}

class UpdateAssessment extends AssessmentEvent {
  final SkillAssessmentModel assessment;

  const UpdateAssessment(this.assessment);

  @override
  List<Object?> get props => [assessment];
}

class DeleteAssessment extends AssessmentEvent {
  final String assessmentId;

  const DeleteAssessment(this.assessmentId);

  @override
  List<Object?> get props => [assessmentId];
}
