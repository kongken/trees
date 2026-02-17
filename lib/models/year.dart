class Year {
  final String id;
  final int yearNumber;
  final String themeSentence;
  final DateTime createdAt;

  Year({
    required this.id,
    required this.yearNumber,
    required this.themeSentence,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'yearNumber': yearNumber,
      'themeSentence': themeSentence,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Year.fromMap(Map<String, dynamic> map) {
    return Year(
      id: map['id'] as String,
      yearNumber: map['yearNumber'] as int,
      themeSentence: map['themeSentence'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  Year copyWith({
    String? id,
    int? yearNumber,
    String? themeSentence,
    DateTime? createdAt,
  }) {
    return Year(
      id: id ?? this.id,
      yearNumber: yearNumber ?? this.yearNumber,
      themeSentence: themeSentence ?? this.themeSentence,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
