# Debug Mode Rules

## Database Location
- SQLite database file: `trees_forest.db` stored in app's database directory
- Access via `getDatabasesPath()` from sqflite package

## Common Issues
- App requires `zh_CN` locale initialization at startup - missing this causes date formatting errors
- All database operations are async - check for unhandled Future errors