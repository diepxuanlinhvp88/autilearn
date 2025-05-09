import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../presentation/blocs/auth/auth_bloc.dart';
import '../../../presentation/blocs/auth/auth_state.dart';
import '../../../presentation/blocs/user/user_bloc.dart';
import '../../../presentation/blocs/user/user_state.dart';
import '../../../presentation/blocs/user/user_event.dart';
import '../../../presentation/blocs/assessment/assessment_bloc.dart';
import '../../../presentation/blocs/assessment/assessment_event.dart';
import '../../../presentation/blocs/assessment/assessment_state.dart';
import '../../../presentation/widgets/assessment/skill_category_card.dart';
import '../../../data/models/skill_assessment_model.dart';
import '../../../main.dart';
import 'assessment_detail_page.dart';

class CreateAssessmentPage extends StatefulWidget {
  final String? studentId;

  const CreateAssessmentPage({
    Key? key,
    this.studentId,
  }) : super(key: key);

  @override
  State<CreateAssessmentPage> createState() => _CreateAssessmentPageState();
}

class _CreateAssessmentPageState extends State<CreateAssessmentPage> {
  final _formKey = GlobalKey<FormState>();
  late String _studentId;
  late DateTime _assessmentDate;
  late Map<String, SkillCategory> _skillCategories;
  String _notes = '';

  @override
  void initState() {
    super.initState();
    _studentId = widget.studentId ?? '';
    _assessmentDate = DateTime.now();
    _skillCategories = DefaultSkillCategories.getDefaultCategories();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AssessmentBloc>(
      create: (context) => getIt<AssessmentBloc>(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Tạo đánh giá mới'),
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
                  tooltip: 'Lưu đánh giá',
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
            } else if (state is AssessmentCreated) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Đã tạo đánh giá mới'),
                  backgroundColor: Colors.green,
                ),
              );

              // Chuyển đến trang chi tiết đánh giá
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => AssessmentDetailPage(
                    assessmentId: state.assessmentId,
                  ),
                ),
              );
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
      final authState = context.read<AuthBloc>().state;
      if (authState is Authenticated) {
        final teacherId = authState.user.uid;

        // Đảm bảo UserBloc đã được tải
        if (context.read<UserBloc>().state is! UserProfileLoaded) {
          context.read<UserBloc>().add(LoadUserProfile(authState.user.uid));
        }

        final assessment = SkillAssessmentModel(
          id: '', // ID sẽ được tạo bởi Firebase
          studentId: _studentId,
          teacherId: teacherId,
          skillCategories: _skillCategories,
          notes: _notes,
          assessmentDate: _assessmentDate,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        context.read<AssessmentBloc>().add(CreateAssessment(assessment));
      }
    }
  }
}
