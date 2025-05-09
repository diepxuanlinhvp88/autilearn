import 'package:flutter/material.dart';

class SkillLevelIndicator extends StatelessWidget {
  final int level;
  final int maxLevel;
  final double size;
  final bool isEditable;
  final Function(int)? onLevelChanged;

  const SkillLevelIndicator({
    Key? key,
    required this.level,
    this.maxLevel = 5,
    this.size = 24,
    this.isEditable = false,
    this.onLevelChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(maxLevel, (index) {
        final isActive = index < level;
        return GestureDetector(
          onTap: isEditable
              ? () {
                  onLevelChanged?.call(index + 1);
                }
              : null,
          child: Container(
            width: size,
            height: size,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: isActive ? _getLevelColor(level) : Colors.grey.shade200,
              shape: BoxShape.circle,
              border: Border.all(
                color: isActive ? _getLevelColor(level).withOpacity(0.8) : Colors.grey.shade400,
                width: 1,
              ),
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: TextStyle(
                  color: isActive ? Colors.white : Colors.grey.shade600,
                  fontWeight: FontWeight.bold,
                  fontSize: size * 0.5,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Color _getLevelColor(int level) {
    switch (level) {
      case 1:
        return Colors.red;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.yellow.shade700;
      case 4:
        return Colors.lightGreen;
      case 5:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
