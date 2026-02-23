class Milestone {
  final String id;
  final String treeId;
  final String title;
  final DateTime? dueDate;
  final DateTime? completedAt;
  final int order;

  Milestone({
    required this.id,
    required this.treeId,
    required this.title,
    this.dueDate,
    this.completedAt,
    this.order = 0,
  });

  bool get isCompleted => completedAt != null;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'treeId': treeId,
      'title': title,
      'dueDate': dueDate?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'orderIndex': order,
    };
  }

  factory Milestone.fromMap(Map<String, dynamic> map) {
    return Milestone(
      id: map['id'] as String,
      treeId: map['treeId'] as String,
      title: map['title'] as String,
      dueDate: map['dueDate'] != null
          ? DateTime.parse(map['dueDate'] as String)
          : null,
      completedAt: map['completedAt'] != null
          ? DateTime.parse(map['completedAt'] as String)
          : null,
      order: (map['orderIndex'] as int?) ?? 0,
    );
  }

  Milestone copyWith({
    String? id,
    String? treeId,
    String? title,
    DateTime? dueDate,
    DateTime? completedAt,
    int? order,
    bool clearCompletedAt = false,
  }) {
    return Milestone(
      id: id ?? this.id,
      treeId: treeId ?? this.treeId,
      title: title ?? this.title,
      dueDate: dueDate ?? this.dueDate,
      completedAt: clearCompletedAt ? null : (completedAt ?? this.completedAt),
      order: order ?? this.order,
    );
  }
}
