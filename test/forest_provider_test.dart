import 'package:flutter_test/flutter_test.dart';

import 'package:trees/models/goal_tree.dart';
import 'package:trees/models/milestone.dart';
import 'package:trees/models/task.dart';

/// Tests for the progress calculation logic used by ForestProvider.
///
/// Since ForestProvider._recalculateProgress is private and tightly coupled
/// to DatabaseHelper, we extract and test the same computation logic here
/// to verify correctness of the progress algorithm.
double calculateProgress(List<Task> tasks, List<Milestone> milestones) {
  if (tasks.isEmpty && milestones.isEmpty) return 0.0;

  double taskProgress = 0.0;
  double milestoneProgress = 0.0;

  if (tasks.isNotEmpty) {
    final completedTasks = tasks.where((t) => t.isCompleted).length;
    taskProgress = completedTasks / tasks.length;
  }

  if (milestones.isNotEmpty) {
    final completedMilestones = milestones.where((m) => m.isCompleted).length;
    milestoneProgress = completedMilestones / milestones.length;
  }

  if (tasks.isNotEmpty && milestones.isNotEmpty) {
    return taskProgress * 0.4 + milestoneProgress * 0.6;
  } else if (milestones.isNotEmpty) {
    return milestoneProgress;
  } else {
    return taskProgress;
  }
}

double calculateYearProgress(List<GoalTree> trees) {
  if (trees.isEmpty) return 0.0;
  final total = trees.fold<double>(0.0, (sum, tree) => sum + tree.progress);
  return total / trees.length;
}

int calculateCompletedTreesCount(List<GoalTree> trees) {
  return trees.where((t) => t.progress >= 1.0).length;
}

void main() {
  group('Progress calculation', () {
    Task makeTask(String id, {bool completed = false}) {
      return Task(
        id: id,
        treeId: 'tree-1',
        title: '任务$id',
        completedAt: completed ? DateTime.now() : null,
      );
    }

    Milestone makeMilestone(String id, {bool completed = false}) {
      return Milestone(
        id: id,
        treeId: 'tree-1',
        title: '里程碑$id',
        completedAt: completed ? DateTime.now() : null,
      );
    }

    test('returns 0 when no tasks and no milestones', () {
      expect(calculateProgress([], []), 0.0);
    });

    test('tasks only: 0 completed out of 2', () {
      final tasks = [makeTask('1'), makeTask('2')];
      expect(calculateProgress(tasks, []), 0.0);
    });

    test('tasks only: 1 completed out of 2', () {
      final tasks = [makeTask('1', completed: true), makeTask('2')];
      expect(calculateProgress(tasks, []), 0.5);
    });

    test('tasks only: all completed', () {
      final tasks = [
        makeTask('1', completed: true),
        makeTask('2', completed: true),
      ];
      expect(calculateProgress(tasks, []), 1.0);
    });

    test('milestones only: 0 completed out of 2', () {
      final milestones = [makeMilestone('1'), makeMilestone('2')];
      expect(calculateProgress([], milestones), 0.0);
    });

    test('milestones only: 1 completed out of 2', () {
      final milestones = [
        makeMilestone('1', completed: true),
        makeMilestone('2'),
      ];
      expect(calculateProgress([], milestones), 0.5);
    });

    test('milestones only: all completed', () {
      final milestones = [
        makeMilestone('1', completed: true),
        makeMilestone('2', completed: true),
      ];
      expect(calculateProgress([], milestones), 1.0);
    });

    test('mixed: tasks 40% weight + milestones 60% weight', () {
      final tasks = [
        makeTask('1', completed: true),
        makeTask('2'),
      ];
      final milestones = [
        makeMilestone('1', completed: true),
        makeMilestone('2'),
      ];

      // taskProgress = 0.5, milestoneProgress = 0.5
      // result = 0.5 * 0.4 + 0.5 * 0.6 = 0.2 + 0.3 = 0.5
      expect(calculateProgress(tasks, milestones), 0.5);
    });

    test('mixed: all tasks done, no milestones done', () {
      final tasks = [makeTask('1', completed: true)];
      final milestones = [makeMilestone('1'), makeMilestone('2')];

      // taskProgress = 1.0, milestoneProgress = 0.0
      // result = 1.0 * 0.4 + 0.0 * 0.6 = 0.4
      expect(calculateProgress(tasks, milestones), closeTo(0.4, 0.001));
    });

    test('mixed: no tasks done, all milestones done', () {
      final tasks = [makeTask('1'), makeTask('2')];
      final milestones = [makeMilestone('1', completed: true)];

      // taskProgress = 0.0, milestoneProgress = 1.0
      // result = 0.0 * 0.4 + 1.0 * 0.6 = 0.6
      expect(calculateProgress(tasks, milestones), closeTo(0.6, 0.001));
    });

    test('mixed: all done', () {
      final tasks = [
        makeTask('1', completed: true),
        makeTask('2', completed: true),
      ];
      final milestones = [
        makeMilestone('1', completed: true),
      ];

      // taskProgress = 1.0, milestoneProgress = 1.0
      // result = 1.0 * 0.4 + 1.0 * 0.6 = 1.0
      expect(calculateProgress(tasks, milestones), 1.0);
    });

    test('mixed: uneven task/milestone counts', () {
      final tasks = [
        makeTask('1', completed: true),
        makeTask('2', completed: true),
        makeTask('3'),
      ];
      final milestones = [
        makeMilestone('1', completed: true),
        makeMilestone('2'),
        makeMilestone('3'),
        makeMilestone('4'),
      ];

      // taskProgress = 2/3 ≈ 0.6667
      // milestoneProgress = 1/4 = 0.25
      // result = 0.6667 * 0.4 + 0.25 * 0.6 = 0.2667 + 0.15 = 0.4167
      final result = calculateProgress(tasks, milestones);
      expect(result, closeTo(0.4167, 0.001));
    });

    test('single task completed', () {
      final tasks = [makeTask('1', completed: true)];
      expect(calculateProgress(tasks, []), 1.0);
    });

    test('single milestone completed', () {
      final milestones = [makeMilestone('1', completed: true)];
      expect(calculateProgress([], milestones), 1.0);
    });
  });

  group('Year progress calculation', () {
    GoalTree makeTree(String id, double progress) {
      return GoalTree(
        id: id,
        yearId: 'year-1',
        title: '目标$id',
        category: GoalCategory.health,
        progress: progress,
      );
    }

    test('returns 0 when no trees', () {
      expect(calculateYearProgress([]), 0.0);
    });

    test('returns exact progress for single tree', () {
      expect(calculateYearProgress([makeTree('1', 0.5)]), 0.5);
    });

    test('averages progress across multiple trees', () {
      final trees = [
        makeTree('1', 0.0),
        makeTree('2', 0.5),
        makeTree('3', 1.0),
      ];
      expect(calculateYearProgress(trees), 0.5);
    });

    test('returns 1.0 when all trees complete', () {
      final trees = [
        makeTree('1', 1.0),
        makeTree('2', 1.0),
      ];
      expect(calculateYearProgress(trees), 1.0);
    });

    test('returns 0 when all trees at 0', () {
      final trees = [
        makeTree('1', 0.0),
        makeTree('2', 0.0),
      ];
      expect(calculateYearProgress(trees), 0.0);
    });
  });

  group('Completed trees count', () {
    GoalTree makeTree(String id, double progress) {
      return GoalTree(
        id: id,
        yearId: 'year-1',
        title: '目标$id',
        category: GoalCategory.health,
        progress: progress,
      );
    }

    test('returns 0 when no trees', () {
      expect(calculateCompletedTreesCount([]), 0);
    });

    test('returns 0 when no trees at 100%', () {
      final trees = [
        makeTree('1', 0.5),
        makeTree('2', 0.99),
      ];
      expect(calculateCompletedTreesCount(trees), 0);
    });

    test('counts trees at exactly 1.0', () {
      final trees = [
        makeTree('1', 1.0),
        makeTree('2', 0.5),
        makeTree('3', 1.0),
      ];
      expect(calculateCompletedTreesCount(trees), 2);
    });

    test('counts all trees when all at 1.0', () {
      final trees = [
        makeTree('1', 1.0),
        makeTree('2', 1.0),
        makeTree('3', 1.0),
      ];
      expect(calculateCompletedTreesCount(trees), 3);
    });
  });
}
