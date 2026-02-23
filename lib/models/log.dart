enum LogType {
  system,
  userJournal,
}

class GoalLog {
  final String id;
  final String treeId;
  final String content;
  final DateTime createdAt;
  final LogType type;

  GoalLog({
    required this.id,
    required this.treeId,
    required this.content,
    DateTime? createdAt,
    this.type = LogType.userJournal,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'treeId': treeId,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'type': type.index,
    };
  }

  factory GoalLog.fromMap(Map<String, dynamic> map) {
    return GoalLog(
      id: map['id'] as String,
      treeId: map['treeId'] as String,
      content: map['content'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
      type: LogType.values[map['type'] as int],
    );
  }

  GoalLog copyWith({
    String? id,
    String? treeId,
    String? content,
    DateTime? createdAt,
    LogType? type,
  }) {
    return GoalLog(
      id: id ?? this.id,
      treeId: treeId ?? this.treeId,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      type: type ?? this.type,
    );
  }
}
