enum GoalCategory {
  health,
  career,
  finance,
  learning,
  social,
  hobby,
  custom,
}

extension GoalCategoryExtension on GoalCategory {
  String get label {
    switch (this) {
      case GoalCategory.health:
        return '健康';
      case GoalCategory.career:
        return '事业';
      case GoalCategory.finance:
        return '财务';
      case GoalCategory.learning:
        return '学习';
      case GoalCategory.social:
        return '人际';
      case GoalCategory.hobby:
        return '兴趣';
      case GoalCategory.custom:
        return '自定义';
    }
  }

  String get icon {
    switch (this) {
      case GoalCategory.health:
        return '💪';
      case GoalCategory.career:
        return '💼';
      case GoalCategory.finance:
        return '💰';
      case GoalCategory.learning:
        return '📚';
      case GoalCategory.social:
        return '👥';
      case GoalCategory.hobby:
        return '🎨';
      case GoalCategory.custom:
        return '🌱';
    }
  }
}

enum GoalStatus {
  active,
  completed,
  dormant,
}

class GoalTree {
  final String id;
  final String yearId;
  final String title;
  final GoalCategory category;
  final String successDefinition;
  final DateTime createdAt;
  final GoalStatus status;
  final double progress;

  GoalTree({
    required this.id,
    required this.yearId,
    required this.title,
    required this.category,
    this.successDefinition = '',
    DateTime? createdAt,
    this.status = GoalStatus.active,
    this.progress = 0.0,
  }) : createdAt = createdAt ?? DateTime.now();

  int get growthStage {
    if (progress >= 1.0) return 4;
    if (progress >= 0.75) return 3;
    if (progress >= 0.50) return 2;
    if (progress >= 0.25) return 1;
    return 0;
  }

  String get growthLabel {
    switch (growthStage) {
      case 0:
        return '小树苗';
      case 1:
        return '小树';
      case 2:
        return '枝叶繁茂';
      case 3:
        return '硕果累累';
      case 4:
        return '大树';
      default:
        return '小树苗';
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'yearId': yearId,
      'title': title,
      'category': category.index,
      'successDefinition': successDefinition,
      'createdAt': createdAt.toIso8601String(),
      'status': status.index,
      'progress': progress,
    };
  }

  factory GoalTree.fromMap(Map<String, dynamic> map) {
    return GoalTree(
      id: map['id'] as String,
      yearId: map['yearId'] as String,
      title: map['title'] as String,
      category: GoalCategory.values[map['category'] as int],
      successDefinition: (map['successDefinition'] as String?) ?? '',
      createdAt: DateTime.parse(map['createdAt'] as String),
      status: GoalStatus.values[map['status'] as int],
      progress: (map['progress'] as num).toDouble(),
    );
  }

  GoalTree copyWith({
    String? id,
    String? yearId,
    String? title,
    GoalCategory? category,
    String? successDefinition,
    DateTime? createdAt,
    GoalStatus? status,
    double? progress,
  }) {
    return GoalTree(
      id: id ?? this.id,
      yearId: yearId ?? this.yearId,
      title: title ?? this.title,
      category: category ?? this.category,
      successDefinition: successDefinition ?? this.successDefinition,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      progress: progress ?? this.progress,
    );
  }
}
