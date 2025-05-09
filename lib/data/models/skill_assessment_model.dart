import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SkillAssessmentModel extends Equatable {
  final String id;
  final String studentId;
  final String teacherId;
  final Map<String, SkillCategory> skillCategories;
  final String notes;
  final DateTime assessmentDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SkillAssessmentModel({
    required this.id,
    required this.studentId,
    required this.teacherId,
    required this.skillCategories,
    this.notes = '',
    required this.assessmentDate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SkillAssessmentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    final Map<String, SkillCategory> skillCategories = {};
    if (data['skillCategories'] != null) {
      (data['skillCategories'] as Map<String, dynamic>).forEach((key, value) {
        skillCategories[key] = SkillCategory.fromMap(value);
      });
    }
    
    return SkillAssessmentModel(
      id: doc.id,
      studentId: data['studentId'] ?? '',
      teacherId: data['teacherId'] ?? '',
      skillCategories: skillCategories,
      notes: data['notes'] ?? '',
      assessmentDate: data['assessmentDate'] != null 
          ? (data['assessmentDate'] as Timestamp).toDate() 
          : DateTime.now(),
      createdAt: data['createdAt'] != null 
          ? (data['createdAt'] as Timestamp).toDate() 
          : DateTime.now(),
      updatedAt: data['updatedAt'] != null 
          ? (data['updatedAt'] as Timestamp).toDate() 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> skillCategoriesMap = {};
    skillCategories.forEach((key, value) {
      skillCategoriesMap[key] = value.toMap();
    });
    
    return {
      'studentId': studentId,
      'teacherId': teacherId,
      'skillCategories': skillCategoriesMap,
      'notes': notes,
      'assessmentDate': Timestamp.fromDate(assessmentDate),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  SkillAssessmentModel copyWith({
    String? id,
    String? studentId,
    String? teacherId,
    Map<String, SkillCategory>? skillCategories,
    String? notes,
    DateTime? assessmentDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SkillAssessmentModel(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      teacherId: teacherId ?? this.teacherId,
      skillCategories: skillCategories ?? this.skillCategories,
      notes: notes ?? this.notes,
      assessmentDate: assessmentDate ?? this.assessmentDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        studentId,
        teacherId,
        skillCategories,
        notes,
        assessmentDate,
        createdAt,
        updatedAt,
      ];
}

class SkillCategory extends Equatable {
  final String name;
  final Map<String, Skill> skills;

  const SkillCategory({
    required this.name,
    required this.skills,
  });

  factory SkillCategory.fromMap(Map<String, dynamic> map) {
    final Map<String, Skill> skills = {};
    if (map['skills'] != null) {
      (map['skills'] as Map<String, dynamic>).forEach((key, value) {
        skills[key] = Skill.fromMap(value);
      });
    }
    
    return SkillCategory(
      name: map['name'] ?? '',
      skills: skills,
    );
  }

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> skillsMap = {};
    skills.forEach((key, value) {
      skillsMap[key] = value.toMap();
    });
    
    return {
      'name': name,
      'skills': skillsMap,
    };
  }

  SkillCategory copyWith({
    String? name,
    Map<String, Skill>? skills,
  }) {
    return SkillCategory(
      name: name ?? this.name,
      skills: skills ?? this.skills,
    );
  }

  @override
  List<Object?> get props => [name, skills];
}

class Skill extends Equatable {
  final String name;
  final String description;
  final int level; // 1-5: 1 = Chưa phát triển, 5 = Thành thạo
  final String notes;

  const Skill({
    required this.name,
    this.description = '',
    required this.level,
    this.notes = '',
  });

  factory Skill.fromMap(Map<String, dynamic> map) {
    return Skill(
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      level: map['level'] ?? 1,
      notes: map['notes'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'level': level,
      'notes': notes,
    };
  }

  Skill copyWith({
    String? name,
    String? description,
    int? level,
    String? notes,
  }) {
    return Skill(
      name: name ?? this.name,
      description: description ?? this.description,
      level: level ?? this.level,
      notes: notes ?? this.notes,
    );
  }

  @override
  List<Object?> get props => [name, description, level, notes];
}

// Các danh mục kỹ năng mặc định
class DefaultSkillCategories {
  static Map<String, SkillCategory> getDefaultCategories() {
    return {
      'communication': SkillCategory(
        name: 'Giao tiếp',
        skills: {
          'verbal': Skill(
            name: 'Giao tiếp bằng lời',
            description: 'Khả năng sử dụng ngôn ngữ nói để giao tiếp',
            level: 1,
          ),
          'nonverbal': Skill(
            name: 'Giao tiếp không lời',
            description: 'Khả năng hiểu và sử dụng cử chỉ, biểu cảm khuôn mặt',
            level: 1,
          ),
          'listening': Skill(
            name: 'Lắng nghe',
            description: 'Khả năng lắng nghe và hiểu người khác',
            level: 1,
          ),
        },
      ),
      'social': SkillCategory(
        name: 'Kỹ năng xã hội',
        skills: {
          'turntaking': Skill(
            name: 'Luân phiên',
            description: 'Khả năng chờ đợi lượt và tham gia luân phiên',
            level: 1,
          ),
          'sharing': Skill(
            name: 'Chia sẻ',
            description: 'Khả năng chia sẻ đồ vật và không gian với người khác',
            level: 1,
          ),
          'empathy': Skill(
            name: 'Đồng cảm',
            description: 'Khả năng hiểu cảm xúc của người khác',
            level: 1,
          ),
        },
      ),
      'cognitive': SkillCategory(
        name: 'Nhận thức',
        skills: {
          'attention': Skill(
            name: 'Tập trung',
            description: 'Khả năng duy trì sự chú ý vào một nhiệm vụ',
            level: 1,
          ),
          'memory': Skill(
            name: 'Trí nhớ',
            description: 'Khả năng ghi nhớ thông tin',
            level: 1,
          ),
          'problemsolving': Skill(
            name: 'Giải quyết vấn đề',
            description: 'Khả năng tìm giải pháp cho các vấn đề',
            level: 1,
          ),
        },
      ),
      'emotional': SkillCategory(
        name: 'Cảm xúc',
        skills: {
          'selfregulation': Skill(
            name: 'Tự điều chỉnh',
            description: 'Khả năng kiểm soát cảm xúc và hành vi',
            level: 1,
          ),
          'emotionrecognition': Skill(
            name: 'Nhận biết cảm xúc',
            description: 'Khả năng nhận biết và gọi tên cảm xúc',
            level: 1,
          ),
          'copingstrategies': Skill(
            name: 'Chiến lược đối phó',
            description: 'Khả năng sử dụng các chiến lược để đối phó với căng thẳng',
            level: 1,
          ),
        },
      ),
      'motor': SkillCategory(
        name: 'Vận động',
        skills: {
          'grossmotor': Skill(
            name: 'Vận động thô',
            description: 'Khả năng kiểm soát các cơ lớn (chạy, nhảy)',
            level: 1,
          ),
          'finemotor': Skill(
            name: 'Vận động tinh',
            description: 'Khả năng kiểm soát các cơ nhỏ (viết, cắt)',
            level: 1,
          ),
          'coordination': Skill(
            name: 'Phối hợp',
            description: 'Khả năng phối hợp tay-mắt và các bộ phận cơ thể',
            level: 1,
          ),
        },
      ),
    };
  }
}
