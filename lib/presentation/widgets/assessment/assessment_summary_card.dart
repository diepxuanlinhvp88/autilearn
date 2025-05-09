import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../data/models/skill_assessment_model.dart';

class AssessmentSummaryCard extends StatelessWidget {
  final SkillAssessmentModel assessment;
  final VoidCallback? onTap;

  const AssessmentSummaryCard({
    Key? key,
    required this.assessment,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Tính điểm trung bình
    double averageLevel = 0;
    int totalSkills = 0;

    assessment.skillCategories.forEach((_, category) {
      category.skills.forEach((_, skill) {
        averageLevel += skill.level;
        totalSkills++;
      });
    });

    if (totalSkills > 0) {
      averageLevel /= totalSkills;
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: _getAverageLevelColor(averageLevel).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        averageLevel.toStringAsFixed(1),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _getAverageLevelColor(averageLevel),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Đánh giá ngày ${DateFormat('dd/MM/yyyy').format(assessment.assessmentDate)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${assessment.skillCategories.length} danh mục, $totalSkills kỹ năng',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    color: Colors.grey.shade400,
                  ),
                ],
              ),
              if (assessment.notes.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    assessment.notes,
                    style: TextStyle(
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                      color: Colors.grey.shade700,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              const SizedBox(height: 12),
              _buildSkillCategoriesPreview(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSkillCategoriesPreview() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: assessment.skillCategories.entries.map((entry) {
        final category = entry.value;
        
        // Tính điểm trung bình cho danh mục
        double categoryAverage = 0;
        category.skills.forEach((_, skill) {
          categoryAverage += skill.level;
        });
        
        if (category.skills.isNotEmpty) {
          categoryAverage /= category.skills.length;
        }
        
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _getAverageLevelColor(categoryAverage).withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _getAverageLevelColor(categoryAverage).withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Text(
            '${category.name}: ${categoryAverage.toStringAsFixed(1)}',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: _getAverageLevelColor(categoryAverage),
            ),
          ),
        );
      }).toList(),
    );
  }

  Color _getAverageLevelColor(double level) {
    if (level < 1.5) {
      return Colors.red;
    } else if (level < 2.5) {
      return Colors.orange;
    } else if (level < 3.5) {
      return Colors.yellow.shade700;
    } else if (level < 4.5) {
      return Colors.lightGreen;
    } else {
      return Colors.green;
    }
  }
}
