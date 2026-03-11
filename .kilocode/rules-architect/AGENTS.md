# Architect Mode Rules

## Data Flow
```
Models (SQLite serialization) 
  → DatabaseHelper (singleton) 
  → ForestProvider (ChangeNotifier) 
  → UI Screens (Consumer widgets)
```

## Database Schema
```
years ──┬── goal_trees ──┬── milestones
        │                ├── tasks
        │                └── logs
```

## Key Architecture Decisions
- SQLite for local-first data storage (no remote backend)
- Provider for simple state management (avoiding complex solutions like BLoC)
- Material 3 with custom forest theme for cohesive visual identity
- Chinese locale as primary target (`zh_CN`)