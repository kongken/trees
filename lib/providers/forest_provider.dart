import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../database/database_helper.dart';
import '../models/year.dart';
import '../models/goal_tree.dart';
import '../models/milestone.dart';
import '../models/task.dart';
import '../models/log.dart';

class ForestProvider extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper();
  final Uuid _uuid = const Uuid();

  List<Year> _years = [];
  Year? _currentYear;
  List<GoalTree> _currentTrees = [];
  Map<String, List<Milestone>> _milestones = {};
  Map<String, List<Task>> _tasks = {};
  Map<String, List<GoalLog>> _logs = {};
  List<Task> _todayTasks = [];
  bool _isLoading = false;

  List<Year> get years => _years;
  Year? get currentYear => _currentYear;
  List<GoalTree> get currentTrees => _currentTrees;
  Map<String, List<Milestone>> get milestones => _milestones;
  Map<String, List<Task>> get tasks => _tasks;
  Map<String, List<GoalLog>> get logs => _logs;
  List<Task> get todayTasks => _todayTasks;
  bool get isLoading => _isLoading;

  double get yearProgress {
    if (_currentTrees.isEmpty) return 0.0;
    final total =
        _currentTrees.fold<double>(0.0, (sum, tree) => sum + tree.progress);
    return total / _currentTrees.length;
  }

  int get completedTreesCount =>
      _currentTrees.where((t) => t.progress >= 1.0).length;

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    _years = await _db.getYears();

    final currentYearNumber = DateTime.now().year;
    _currentYear = _years.firstWhere(
      (y) => y.yearNumber == currentYearNumber,
      orElse: () => _years.isNotEmpty ? _years.first : _createDefaultYear(currentYearNumber),
    );

    if (_years.isEmpty) {
      await _db.insertYear(_currentYear!);
      _years = [_currentYear!];
    }

    await _loadTreesForYear(_currentYear!.id);
    await _loadTodayTasks();

    _isLoading = false;
    notifyListeners();
  }

  Year _createDefaultYear(int yearNumber) {
    return Year(
      id: _uuid.v4(),
      yearNumber: yearNumber,
      themeSentence: '',
    );
  }

  Future<void> switchYear(int yearNumber) async {
    final year = _years.firstWhere(
      (y) => y.yearNumber == yearNumber,
      orElse: () => _createDefaultYear(yearNumber),
    );

    if (!_years.any((y) => y.yearNumber == yearNumber)) {
      await _db.insertYear(year);
      _years = await _db.getYears();
    }

    _currentYear = year;
    await _loadTreesForYear(year.id);
    notifyListeners();
  }

  Future<void> _loadTreesForYear(String yearId) async {
    _currentTrees = await _db.getGoalTreesByYear(yearId);
    _milestones = {};
    _tasks = {};
    _logs = {};

    for (final tree in _currentTrees) {
      _milestones[tree.id] = await _db.getMilestonesByTree(tree.id);
      _tasks[tree.id] = await _db.getTasksByTree(tree.id);
      _logs[tree.id] = await _db.getLogsByTree(tree.id);
    }
  }

  Future<void> _loadTodayTasks() async {
    if (_currentYear == null) return;
    _todayTasks = await _db.getIncompleteTasksByYear(_currentYear!.id);
  }

  // --- Year operations ---

  Future<void> updateYearTheme(String themeSentence) async {
    if (_currentYear == null) return;
    _currentYear = _currentYear!.copyWith(themeSentence: themeSentence);
    await _db.updateYear(_currentYear!);
    final index = _years.indexWhere((y) => y.id == _currentYear!.id);
    if (index >= 0) _years[index] = _currentYear!;
    notifyListeners();
  }

  Future<Year> createYear(int yearNumber, String themeSentence) async {
    final year = Year(
      id: _uuid.v4(),
      yearNumber: yearNumber,
      themeSentence: themeSentence,
    );
    await _db.insertYear(year);
    _years = await _db.getYears();
    notifyListeners();
    return year;
  }

  // --- GoalTree operations ---

  Future<GoalTree> createGoalTree({
    required String title,
    required GoalCategory category,
    String successDefinition = '',
  }) async {
    if (_currentYear == null) throw Exception('No current year selected');

    final tree = GoalTree(
      id: _uuid.v4(),
      yearId: _currentYear!.id,
      title: title,
      category: category,
      successDefinition: successDefinition,
    );

    await _db.insertGoalTree(tree);
    _currentTrees.add(tree);
    _milestones[tree.id] = [];
    _tasks[tree.id] = [];
    _logs[tree.id] = [];

    await _addSystemLog(
        tree.id, '种下了一棵新树：${tree.title} ${tree.category.icon}');

    notifyListeners();
    return tree;
  }

  Future<void> updateGoalTree(GoalTree tree) async {
    await _db.updateGoalTree(tree);
    final index = _currentTrees.indexWhere((t) => t.id == tree.id);
    if (index >= 0) _currentTrees[index] = tree;
    notifyListeners();
  }

  Future<void> deleteGoalTree(String treeId) async {
    await _db.deleteGoalTree(treeId);
    _currentTrees.removeWhere((t) => t.id == treeId);
    _milestones.remove(treeId);
    _tasks.remove(treeId);
    _logs.remove(treeId);
    await _loadTodayTasks();
    notifyListeners();
  }

  Future<void> moveTreeToDormant(String treeId) async {
    final index = _currentTrees.indexWhere((t) => t.id == treeId);
    if (index < 0) return;
    final tree = _currentTrees[index].copyWith(status: GoalStatus.dormant);
    await _db.updateGoalTree(tree);
    _currentTrees[index] = tree;
    await _addSystemLog(treeId, '这棵树进入了休眠林地');
    notifyListeners();
  }

  // --- Milestone operations ---

  Future<Milestone> createMilestone({
    required String treeId,
    required String title,
    DateTime? dueDate,
  }) async {
    final existing = _milestones[treeId] ?? [];
    final milestone = Milestone(
      id: _uuid.v4(),
      treeId: treeId,
      title: title,
      dueDate: dueDate,
      order: existing.length,
    );

    await _db.insertMilestone(milestone);
    _milestones[treeId] = [...existing, milestone];
    await _recalculateProgress(treeId);
    notifyListeners();
    return milestone;
  }

  Future<void> completeMilestone(String milestoneId) async {
    for (final entry in _milestones.entries) {
      final index = entry.value.indexWhere((m) => m.id == milestoneId);
      if (index >= 0) {
        final milestone =
            entry.value[index].copyWith(completedAt: DateTime.now());
        await _db.updateMilestone(milestone);
        entry.value[index] = milestone;

        await _addSystemLog(entry.key, '完成了里程碑：${milestone.title}！树又长高了！');
        await _recalculateProgress(entry.key);
        notifyListeners();
        return;
      }
    }
  }

  Future<void> deleteMilestone(String milestoneId) async {
    for (final entry in _milestones.entries) {
      final index = entry.value.indexWhere((m) => m.id == milestoneId);
      if (index >= 0) {
        await _db.deleteMilestone(milestoneId);
        entry.value.removeAt(index);
        await _recalculateProgress(entry.key);
        notifyListeners();
        return;
      }
    }
  }

  // --- Task operations ---

  Future<Task> createTask({
    required String treeId,
    String? milestoneId,
    required String title,
    TaskType type = TaskType.once,
    String? repeatRule,
    DateTime? dueDate,
  }) async {
    final task = Task(
      id: _uuid.v4(),
      treeId: treeId,
      milestoneId: milestoneId,
      title: title,
      type: type,
      repeatRule: repeatRule,
      dueDate: dueDate,
    );

    await _db.insertTask(task);
    _tasks[treeId] = [...(_tasks[treeId] ?? []), task];
    await _loadTodayTasks();
    await _recalculateProgress(treeId);
    notifyListeners();
    return task;
  }

  Future<void> completeTask(String taskId) async {
    for (final entry in _tasks.entries) {
      final index = entry.value.indexWhere((t) => t.id == taskId);
      if (index >= 0) {
        final task = entry.value[index].copyWith(completedAt: DateTime.now());
        await _db.updateTask(task);
        entry.value[index] = task;

        await _addSystemLog(entry.key, '完成了任务：${task.title}，树又长出了新叶！');
        await _recalculateProgress(entry.key);
        await _loadTodayTasks();
        notifyListeners();
        return;
      }
    }
  }

  Future<void> uncompleteTask(String taskId) async {
    for (final entry in _tasks.entries) {
      final index = entry.value.indexWhere((t) => t.id == taskId);
      if (index >= 0) {
        final task = entry.value[index].copyWith(clearCompletedAt: true);
        await _db.updateTask(task);
        entry.value[index] = task;
        await _recalculateProgress(entry.key);
        await _loadTodayTasks();
        notifyListeners();
        return;
      }
    }
  }

  Future<void> deleteTask(String taskId) async {
    for (final entry in _tasks.entries) {
      final index = entry.value.indexWhere((t) => t.id == taskId);
      if (index >= 0) {
        await _db.deleteTask(taskId);
        entry.value.removeAt(index);
        await _recalculateProgress(entry.key);
        await _loadTodayTasks();
        notifyListeners();
        return;
      }
    }
  }

  // --- Log operations ---

  Future<GoalLog> addJournalLog(String treeId, String content) async {
    final log = GoalLog(
      id: _uuid.v4(),
      treeId: treeId,
      content: content,
      type: LogType.userJournal,
    );
    await _db.insertLog(log);
    _logs[treeId] = [log, ...(_logs[treeId] ?? [])];
    notifyListeners();
    return log;
  }

  Future<void> _addSystemLog(String treeId, String content) async {
    final log = GoalLog(
      id: _uuid.v4(),
      treeId: treeId,
      content: content,
      type: LogType.system,
    );
    await _db.insertLog(log);
    _logs[treeId] = [log, ...(_logs[treeId] ?? [])];
  }

  // --- Progress calculation ---

  Future<void> _recalculateProgress(String treeId) async {
    final treeTasks = _tasks[treeId] ?? [];
    final treeMilestones = _milestones[treeId] ?? [];

    if (treeTasks.isEmpty && treeMilestones.isEmpty) return;

    double taskProgress = 0.0;
    double milestoneProgress = 0.0;

    if (treeTasks.isNotEmpty) {
      final completedTasks =
          treeTasks.where((t) => t.isCompleted).length;
      taskProgress = completedTasks / treeTasks.length;
    }

    if (treeMilestones.isNotEmpty) {
      final completedMilestones =
          treeMilestones.where((m) => m.isCompleted).length;
      milestoneProgress = completedMilestones / treeMilestones.length;
    }

    double progress;
    if (treeTasks.isNotEmpty && treeMilestones.isNotEmpty) {
      progress = taskProgress * 0.4 + milestoneProgress * 0.6;
    } else if (treeMilestones.isNotEmpty) {
      progress = milestoneProgress;
    } else {
      progress = taskProgress;
    }

    final index = _currentTrees.indexWhere((t) => t.id == treeId);
    if (index >= 0) {
      final tree = _currentTrees[index].copyWith(progress: progress);
      await _db.updateGoalTree(tree);
      _currentTrees[index] = tree;
    }
  }

  // --- Helper methods ---

  List<Task> getTasksForTree(String treeId) => _tasks[treeId] ?? [];
  List<Milestone> getMilestonesForTree(String treeId) =>
      _milestones[treeId] ?? [];
  List<GoalLog> getLogsForTree(String treeId) => _logs[treeId] ?? [];

  GoalTree? getTreeById(String treeId) {
    try {
      return _currentTrees.firstWhere((t) => t.id == treeId);
    } catch (_) {
      return null;
    }
  }
}
