enum TaskType {
  habit,
  once,
  deadline,
}

extension TaskTypeExtension on TaskType {
  String get label {
    switch (this) {
      case TaskType.habit:
        return '习惯';
      case TaskType.once:
        return '一次性';
      case TaskType.deadline:
        return '截止日期';
    }
  }
}

class Task {
  final String id;
  final String treeId;
  final String? milestoneId;
  final String title;
  final TaskType type;
  final String? repeatRule;
  final DateTime? dueDate;
  final DateTime? completedAt;
  final DateTime createdAt;

  Task({
    required this.id,
    required this.treeId,
    this.milestoneId,
    required this.title,
    this.type = TaskType.once,
    this.repeatRule,
    this.dueDate,
    this.completedAt,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  bool get isCompleted => completedAt != null;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'treeId': treeId,
      'milestoneId': milestoneId,
      'title': title,
      'type': type.index,
      'repeatRule': repeatRule,
      'dueDate': dueDate?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] as String,
      treeId: map['treeId'] as String,
      milestoneId: map['milestoneId'] as String?,
      title: map['title'] as String,
      type: TaskType.values[map['type'] as int],
      repeatRule: map['repeatRule'] as String?,
      dueDate: map['dueDate'] != null
          ? DateTime.parse(map['dueDate'] as String)
          : null,
      completedAt: map['completedAt'] != null
          ? DateTime.parse(map['completedAt'] as String)
          : null,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  Task copyWith({
    String? id,
    String? treeId,
    String? milestoneId,
    String? title,
    TaskType? type,
    String? repeatRule,
    DateTime? dueDate,
    DateTime? completedAt,
    DateTime? createdAt,
    bool clearCompletedAt = false,
    bool clearMilestoneId = false,
  }) {
    return Task(
      id: id ?? this.id,
      treeId: treeId ?? this.treeId,
      milestoneId:
          clearMilestoneId ? null : (milestoneId ?? this.milestoneId),
      title: title ?? this.title,
      type: type ?? this.type,
      repeatRule: repeatRule ?? this.repeatRule,
      dueDate: dueDate ?? this.dueDate,
      completedAt: clearCompletedAt ? null : (completedAt ?? this.completedAt),
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
