import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../presentation/blocs/assessment/assessment_bloc.dart';
import '../../../presentation/blocs/assessment/assessment_event.dart';
import '../../../presentation/blocs/assessment/assessment_state.dart';
import '../../../presentation/blocs/user/user_bloc.dart';
import '../../../presentation/blocs/user/user_state.dart';
import '../../../presentation/blocs/user/user_event.dart';
import '../../../presentation/blocs/auth/auth_bloc.dart';
import '../../../presentation/blocs/auth/auth_state.dart';
import '../../../presentation/widgets/assessment/skill_category_card.dart';
import '../../../data/models/skill_assessment_model.dart';
import '../../../main.dart';

class EditAssessmentPage extends StatefulWidget {
  final SkillAssessmentModel assessment;

  const EditAssessmentPage({
    Key? key,
    required this.assessment,
  }) : super(key: key);

  @override
  State<EditAssessmentPage> createState() => _EditAssessmentPageState();
}

class _EditAssessmentPageState extends State<EditAssessmentPage> {
  final _formKey = GlobalKey<FormState>();
  late String _studentId;
  late DateTime _assessmentDate;
  late Map<String, SkillCategory> _skillCategories;
  late String _notes;

  @override
  void initState() {
    super.initState();
    _studentId = widget.assessment.studentId;
    _assessmentDate = widget.assessment.assessmentDate;
    _skillCategories = Map<String, SkillCategory>.from(widget.assessment.skillCategories);
    _notes = widget.assessment.notes;
  }

  @override
  Widget build(BuildContext context) {
    // Đảm bảo UserBloc đã được tải
    if (context.read<UserBloc>().state is! UserProfileLoaded) {
      final authState = context.read<AuthBloc>().state;
      if (authState is Authenticated) {
        context.read<UserBloc>().add(LoadUserProfile(authState.user.uid));
      }
    }

    return BlocProvider<AssessmentBloc>(
      create: (context) => getIt<AssessmentBloc>(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Chỉnh sửa đánh giá'),
          backgroundColor: Colors.purple,
          foregroundColor: Colors.white,
          actions: [
            BlocBuilder<AssessmentBloc, AssessmentState>(
              builder: (context, state) {
                return IconButton(
                  icon: const Icon(Icons.save),
                  onPressed: state is AssessmentLoading
                      ? null
                      : () => _saveAssessment(context),
                  tooltip: 'Lưu thay đổi',
                );
              },
            ),
          ],
        ),
        body: BlocConsumer<AssessmentBloc, AssessmentState>(
          listener: (context, state) {
            if (state is AssessmentError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            } else if (state is AssessmentUpdated) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Đã cập nhật đánh giá'),
                  backgroundColor: Colors.green,
                ),
              );

              Navigator.of(context).pop();
            }
          },
          builder: (context, state) {
            if (state is AssessmentLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            return Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Thông tin đánh giá',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              decoration: const InputDecoration(
                                labelText: 'ID học sinh',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.person),
                              ),
                              initialValue: _studentId,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Vui lòng nhập ID học sinh';
                                }
                                return null;
                              },
                              onChanged: (value) {
                                _studentId = value;
                              },
                            ),
                            const SizedBox(height: 16),
                            InkWell(
                              onTap: () => _selectDate(context),
                              child: InputDecorator(
                                decoration: const InputDecoration(
                                  labelText: 'Ngày đánh giá',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.calendar_today),
                                ),
                                child: Text(
                                  DateFormat('dd/MM/yyyy').format(_assessmentDate),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              decoration: const InputDecoration(
                                labelText: 'Ghi chú',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.note),
                              ),
                              maxLines: 3,
                              initialValue: _notes,
                              onChanged: (value) {
                                _notes = value;
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Đánh giá kỹ năng',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ..._skillCategories.entries.map((entry) {
                      final categoryKey = entry.key;
                      final category = entry.value;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: SkillCategoryCard(
                          categoryKey: categoryKey,
                          category: category,
                          isEditable: true,
                          onSkillLevelChanged: (categoryKey, skillKey, newLevel) {
                            setState(() {
                              final updatedSkills = Map<String, Skill>.from(_skillCategories[categoryKey]!.skills);
                              updatedSkills[skillKey] = updatedSkills[skillKey]!.copyWith(level: newLevel);

                              _skillCategories[categoryKey] = _skillCategories[categoryKey]!.copyWith(
                                skills: updatedSkills,
                              );
                            });
                          },
                          onSkillNotesChanged: (categoryKey, skillKey, notes) {
                            setState(() {
                              final updatedSkills = Map<String, Skill>.from(_skillCategories[categoryKey]!.skills);
                              updatedSkills[skillKey] = updatedSkills[skillKey]!.copyWith(notes: notes);

                              _skillCategories[categoryKey] = _skillCategories[categoryKey]!.copyWith(
                                skills: updatedSkills,
                              );
                            });
                          },
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _assessmentDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != _assessmentDate) {
      setState(() {
        _assessmentDate = picked;
      });
    }
  }

  void _saveAssessment(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      final updatedAssessment = widget.assessment.copyWith(
        studentId: _studentId,
        skillCategories: _skillCategories,
        notes: _notes,
        assessmentDate: _assessmentDate,
        updatedAt: DateTime.now(),
      );

      context.read<AssessmentBloc>().add(UpdateAssessment(updatedAssessment));
    }
  }
}
