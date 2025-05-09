import 'package:flutter/material.dart';
import '../../../data/models/skill_assessment_model.dart';
import 'skill_level_indicator.dart';

class SkillCategoryCard extends StatelessWidget {
  final String categoryKey;
  final SkillCategory category;
  final bool isEditable;
  final Function(String, String, int)? onSkillLevelChanged;
  final Function(String, String, String)? onSkillNotesChanged;

  const SkillCategoryCard({
    Key? key,
    required this.categoryKey,
    required this.category,
    this.isEditable = false,
    this.onSkillLevelChanged,
    this.onSkillNotesChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              category.name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...category.skills.entries.map((entry) {
              final skillKey = entry.key;
              final skill = entry.value;
              return _buildSkillItem(context, skillKey, skill);
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildSkillItem(BuildContext context, String skillKey, Skill skill) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      skill.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (skill.description.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          skill.description,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              SkillLevelIndicator(
                level: skill.level,
                isEditable: isEditable,
                onLevelChanged: isEditable
                    ? (newLevel) {
                        onSkillLevelChanged?.call(categoryKey, skillKey, newLevel);
                      }
                    : null,
              ),
            ],
          ),
          if (isEditable || skill.notes.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: isEditable
                  ? TextFormField(
                      decoration: const InputDecoration(
                        hintText: 'Ghi chú về kỹ năng này...',
                        isDense: true,
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                      initialValue: skill.notes,
                      onChanged: (value) {
                        onSkillNotesChanged?.call(categoryKey, skillKey, value);
                      },
                    )
                  : Text(
                      'Ghi chú: ${skill.notes}',
                      style: TextStyle(
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                        color: Colors.grey.shade700,
                      ),
                    ),
            ),
        ],
      ),
    );
  }
}
