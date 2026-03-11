# AGENTS.md

This file provides guidance to agents when working with code in this repository.

## Build/Test Commands
```bash
flutter pub get              # Install dependencies
flutter run                  # Run app (requires device/simulator)
flutter test                 # Run all tests
flutter test test/widget_test.dart  # Run single test file
flutter analyze              # Static analysis
```

## Architecture Overview
- **Entry Point**: `lib/main.dart` - initializes date formatting for `zh_CN` locale before runApp
- **State Management**: `ForestProvider` (ChangeNotifier) injected at root via Provider
- **Database**: `DatabaseHelper` singleton using sqflite with `trees_forest.db`
- **Data Flow**: Models → DatabaseHelper → ForestProvider → UI Screens

## Key Patterns
- All models implement `toMap()`/`fromMap()` for SQLite serialization
- Enums use extension methods for Chinese labels (e.g., `GoalCategory.health.label` → '健康')
- UUID v4 used for all entity IDs via `package:uuid`

## Database Schema
Tables: `years`, `goal_trees`, `milestones`, `tasks`, `logs` with foreign key relationships.

## Notes
- App uses Material 3 with custom forest theme (`AppTheme` in `lib/theme/`)
- Chinese locale required at app startup (`initializeDateFormatting('zh_CN', null)`)
