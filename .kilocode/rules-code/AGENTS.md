# Code Mode Rules

## Model Pattern
All models must implement:
- `toMap()` - serialize to SQLite-compatible Map
- `fromMap(Map<String, dynamic>)` - factory constructor for deserialization
- `copyWith()` - immutable updates with optional field clearing

## Enum Pattern
Enums use extension methods for Chinese labels:
```dart
enum GoalCategory { health, career, ... }
extension GoalCategoryExtension on GoalCategory {
  String get label => switch (this) {
    GoalCategory.health => '健康',
    ...
  };
}
```

## ID Generation
All entity IDs use UUID v4: `const Uuid().v4()`

## Database
- DatabaseHelper is a singleton - access via `DatabaseHelper()` factory
- Database file: `trees_forest.db`
- Foreign keys enforced between tables

## Provider Pattern
`ForestProvider` extends ChangeNotifier, injected at root:
```dart
ChangeNotifierProvider(
  create: (_) => ForestProvider()..initialize(),
  ...
)