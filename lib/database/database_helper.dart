import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/year.dart';
import '../models/goal_tree.dart';
import '../models/milestone.dart';
import '../models/task.dart';
import '../models/log.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'trees_forest.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE years (
        id TEXT PRIMARY KEY,
        yearNumber INTEGER NOT NULL,
        themeSentence TEXT NOT NULL,
        createdAt TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE goal_trees (
        id TEXT PRIMARY KEY,
        yearId TEXT NOT NULL,
        title TEXT NOT NULL,
        category INTEGER NOT NULL,
        successDefinition TEXT DEFAULT '',
        createdAt TEXT NOT NULL,
        status INTEGER NOT NULL DEFAULT 0,
        progress REAL NOT NULL DEFAULT 0.0,
        FOREIGN KEY (yearId) REFERENCES years(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE milestones (
        id TEXT PRIMARY KEY,
        treeId TEXT NOT NULL,
        title TEXT NOT NULL,
        dueDate TEXT,
        completedAt TEXT,
        orderIndex INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (treeId) REFERENCES goal_trees(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE tasks (
        id TEXT PRIMARY KEY,
        treeId TEXT NOT NULL,
        milestoneId TEXT,
        title TEXT NOT NULL,
        type INTEGER NOT NULL DEFAULT 0,
        repeatRule TEXT,
        dueDate TEXT,
        completedAt TEXT,
        createdAt TEXT NOT NULL,
        FOREIGN KEY (treeId) REFERENCES goal_trees(id),
        FOREIGN KEY (milestoneId) REFERENCES milestones(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE logs (
        id TEXT PRIMARY KEY,
        treeId TEXT NOT NULL,
        content TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        type INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (treeId) REFERENCES goal_trees(id)
      )
    ''');
  }

  // --- Year CRUD ---

  Future<void> insertYear(Year year) async {
    final db = await database;
    await db.insert('years', year.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Year>> getYears() async {
    final db = await database;
    final maps = await db.query('years', orderBy: 'yearNumber DESC');
    return maps.map((m) => Year.fromMap(m)).toList();
  }

  Future<Year?> getYear(String id) async {
    final db = await database;
    final maps = await db.query('years', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return Year.fromMap(maps.first);
  }

  Future<Year?> getYearByNumber(int yearNumber) async {
    final db = await database;
    final maps = await db.query('years',
        where: 'yearNumber = ?', whereArgs: [yearNumber]);
    if (maps.isEmpty) return null;
    return Year.fromMap(maps.first);
  }

  Future<void> updateYear(Year year) async {
    final db = await database;
    await db
        .update('years', year.toMap(), where: 'id = ?', whereArgs: [year.id]);
  }

  Future<void> deleteYear(String id) async {
    final db = await database;
    await db.delete('years', where: 'id = ?', whereArgs: [id]);
  }

  // --- GoalTree CRUD ---

  Future<void> insertGoalTree(GoalTree tree) async {
    final db = await database;
    await db.insert('goal_trees', tree.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<GoalTree>> getGoalTreesByYear(String yearId) async {
    final db = await database;
    final maps = await db.query('goal_trees',
        where: 'yearId = ?', whereArgs: [yearId], orderBy: 'createdAt ASC');
    return maps.map((m) => GoalTree.fromMap(m)).toList();
  }

  Future<GoalTree?> getGoalTree(String id) async {
    final db = await database;
    final maps =
        await db.query('goal_trees', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return GoalTree.fromMap(maps.first);
  }

  Future<void> updateGoalTree(GoalTree tree) async {
    final db = await database;
    await db.update('goal_trees', tree.toMap(),
        where: 'id = ?', whereArgs: [tree.id]);
  }

  Future<void> deleteGoalTree(String id) async {
    final db = await database;
    await db.delete('tasks', where: 'treeId = ?', whereArgs: [id]);
    await db.delete('milestones', where: 'treeId = ?', whereArgs: [id]);
    await db.delete('logs', where: 'treeId = ?', whereArgs: [id]);
    await db.delete('goal_trees', where: 'id = ?', whereArgs: [id]);
  }

  // --- Milestone CRUD ---

  Future<void> insertMilestone(Milestone milestone) async {
    final db = await database;
    await db.insert('milestones', milestone.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Milestone>> getMilestonesByTree(String treeId) async {
    final db = await database;
    final maps = await db.query('milestones',
        where: 'treeId = ?', whereArgs: [treeId], orderBy: 'orderIndex ASC');
    return maps.map((m) => Milestone.fromMap(m)).toList();
  }

  Future<void> updateMilestone(Milestone milestone) async {
    final db = await database;
    await db.update('milestones', milestone.toMap(),
        where: 'id = ?', whereArgs: [milestone.id]);
  }

  Future<void> deleteMilestone(String id) async {
    final db = await database;
    await db.delete('tasks', where: 'milestoneId = ?', whereArgs: [id]);
    await db.delete('milestones', where: 'id = ?', whereArgs: [id]);
  }

  // --- Task CRUD ---

  Future<void> insertTask(Task task) async {
    final db = await database;
    await db.insert('tasks', task.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Task>> getTasksByTree(String treeId) async {
    final db = await database;
    final maps = await db.query('tasks',
        where: 'treeId = ?', whereArgs: [treeId], orderBy: 'createdAt ASC');
    return maps.map((m) => Task.fromMap(m)).toList();
  }

  Future<List<Task>> getTasksByMilestone(String milestoneId) async {
    final db = await database;
    final maps = await db.query('tasks',
        where: 'milestoneId = ?',
        whereArgs: [milestoneId],
        orderBy: 'createdAt ASC');
    return maps.map((m) => Task.fromMap(m)).toList();
  }

  Future<List<Task>> getIncompleteTasks() async {
    final db = await database;
    final maps = await db.query('tasks',
        where: 'completedAt IS NULL', orderBy: 'createdAt ASC');
    return maps.map((m) => Task.fromMap(m)).toList();
  }

  Future<List<Task>> getIncompleteTasksByYear(String yearId) async {
    final db = await database;
    final maps = await db.rawQuery('''
      SELECT tasks.* FROM tasks
      INNER JOIN goal_trees ON tasks.treeId = goal_trees.id
      WHERE goal_trees.yearId = ? AND tasks.completedAt IS NULL
      ORDER BY tasks.createdAt ASC
    ''', [yearId]);
    return maps.map((m) => Task.fromMap(m)).toList();
  }

  Future<List<Task>> getCompletedTasksToday() async {
    final db = await database;
    final today = DateTime.now();
    final startOfDay =
        DateTime(today.year, today.month, today.day).toIso8601String();
    final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59)
        .toIso8601String();
    final maps = await db.query('tasks',
        where: 'completedAt >= ? AND completedAt <= ?',
        whereArgs: [startOfDay, endOfDay]);
    return maps.map((m) => Task.fromMap(m)).toList();
  }

  Future<void> updateTask(Task task) async {
    final db = await database;
    await db.update('tasks', task.toMap(),
        where: 'id = ?', whereArgs: [task.id]);
  }

  Future<void> deleteTask(String id) async {
    final db = await database;
    await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }

  // --- Log CRUD ---

  Future<void> insertLog(GoalLog log) async {
    final db = await database;
    await db.insert('logs', log.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<GoalLog>> getLogsByTree(String treeId) async {
    final db = await database;
    final maps = await db.query('logs',
        where: 'treeId = ?', whereArgs: [treeId], orderBy: 'createdAt DESC');
    return maps.map((m) => GoalLog.fromMap(m)).toList();
  }

  Future<void> deleteLog(String id) async {
    final db = await database;
    await db.delete('logs', where: 'id = ?', whereArgs: [id]);
  }
}
