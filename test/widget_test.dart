import 'package:flutter_test/flutter_test.dart';

import 'package:trees/models/year.dart';
import 'package:trees/models/goal_tree.dart';
import 'package:trees/models/milestone.dart';
import 'package:trees/models/task.dart';
import 'package:trees/models/log.dart';

void main() {
  group('Year model', () {
    test('creates Year with correct fields', () {
      final year = Year(
        id: 'test-id',
        yearNumber: 2026,
        themeSentence: '变得更健康',
      );

      expect(year.id, 'test-id');
      expect(year.yearNumber, 2026);
      expect(year.themeSentence, '变得更健康');
    });

    test('Year serialization round-trip', () {
      final year = Year(
        id: 'test-id',
        yearNumber: 2026,
        themeSentence: '变得更健康',
        createdAt: DateTime(2026, 1, 1),
      );

      final map = year.toMap();
      final restored = Year.fromMap(map);

      expect(restored.id, year.id);
      expect(restored.yearNumber, year.yearNumber);
      expect(restored.themeSentence, year.themeSentence);
    });

    test('Year copyWith works correctly', () {
      final year = Year(
        id: 'test-id',
        yearNumber: 2026,
        themeSentence: '变得更健康',
      );

      final updated = year.copyWith(themeSentence: '向管理者迈进');
      expect(updated.themeSentence, '向管理者迈进');
      expect(updated.id, year.id);
      expect(updated.yearNumber, year.yearNumber);
    });
  });

  group('GoalTree model', () {
    test('creates GoalTree with correct defaults', () {
      final tree = GoalTree(
        id: 'tree-1',
        yearId: 'year-1',
        title: '升职为资深工程师',
        category: GoalCategory.career,
      );

      expect(tree.status, GoalStatus.active);
      expect(tree.progress, 0.0);
      expect(tree.growthStage, 0);
      expect(tree.growthLabel, '小树苗');
    });

    test('growthStage reflects progress correctly', () {
      expect(
        GoalTree(
          id: '1', yearId: 'y', title: 't', category: GoalCategory.career,
          progress: 0.0,
        ).growthStage,
        0,
      );
      expect(
        GoalTree(
          id: '2', yearId: 'y', title: 't', category: GoalCategory.career,
          progress: 0.30,
        ).growthStage,
        1,
      );
      expect(
        GoalTree(
          id: '3', yearId: 'y', title: 't', category: GoalCategory.career,
          progress: 0.55,
        ).growthStage,
        2,
      );
      expect(
        GoalTree(
          id: '4', yearId: 'y', title: 't', category: GoalCategory.career,
          progress: 0.80,
        ).growthStage,
        3,
      );
      expect(
        GoalTree(
          id: '5', yearId: 'y', title: 't', category: GoalCategory.career,
          progress: 1.0,
        ).growthStage,
        4,
      );
    });

    test('GoalTree serialization round-trip', () {
      final tree = GoalTree(
        id: 'tree-1',
        yearId: 'year-1',
        title: '升职',
        category: GoalCategory.career,
        successDefinition: '通过评审',
        status: GoalStatus.active,
        progress: 0.5,
      );

      final map = tree.toMap();
      final restored = GoalTree.fromMap(map);

      expect(restored.id, tree.id);
      expect(restored.title, tree.title);
      expect(restored.category, tree.category);
      expect(restored.progress, tree.progress);
    });

    test('GoalCategory has correct labels', () {
      expect(GoalCategory.health.label, '健康');
      expect(GoalCategory.career.label, '事业');
      expect(GoalCategory.finance.label, '财务');
      expect(GoalCategory.learning.label, '学习');
      expect(GoalCategory.social.label, '人际');
      expect(GoalCategory.hobby.label, '兴趣');
      expect(GoalCategory.custom.label, '自定义');
    });
  });

  group('Milestone model', () {
    test('creates Milestone and checks completion', () {
      final milestone = Milestone(
        id: 'm-1',
        treeId: 'tree-1',
        title: '完成项目A',
      );

      expect(milestone.isCompleted, false);

      final completed = milestone.copyWith(completedAt: DateTime.now());
      expect(completed.isCompleted, true);
    });

    test('Milestone serialization round-trip', () {
      final milestone = Milestone(
        id: 'm-1',
        treeId: 'tree-1',
        title: '完成项目A',
        dueDate: DateTime(2026, 6, 30),
        order: 1,
      );

      final map = milestone.toMap();
      final restored = Milestone.fromMap(map);

      expect(restored.id, milestone.id);
      expect(restored.title, milestone.title);
      expect(restored.order, milestone.order);
    });
  });

  group('Task model', () {
    test('creates Task with correct defaults', () {
      final task = Task(
        id: 't-1',
        treeId: 'tree-1',
        title: '每周阅读2篇技术文章',
        type: TaskType.habit,
      );

      expect(task.isCompleted, false);
      expect(task.type, TaskType.habit);
    });

    test('Task type labels are correct', () {
      expect(TaskType.habit.label, '习惯');
      expect(TaskType.once.label, '一次性');
      expect(TaskType.deadline.label, '截止日期');
    });

    test('Task serialization round-trip', () {
      final task = Task(
        id: 't-1',
        treeId: 'tree-1',
        milestoneId: 'm-1',
        title: '每周阅读',
        type: TaskType.habit,
        repeatRule: 'weekly',
      );

      final map = task.toMap();
      final restored = Task.fromMap(map);

      expect(restored.id, task.id);
      expect(restored.title, task.title);
      expect(restored.type, task.type);
      expect(restored.milestoneId, task.milestoneId);
    });
  });

  group('GoalLog model', () {
    test('creates GoalLog with correct defaults', () {
      final log = GoalLog(
        id: 'l-1',
        treeId: 'tree-1',
        content: '今天完成了第一个任务',
      );

      expect(log.type, LogType.userJournal);
    });

    test('GoalLog serialization round-trip', () {
      final log = GoalLog(
        id: 'l-1',
        treeId: 'tree-1',
        content: '系统记录',
        type: LogType.system,
      );

      final map = log.toMap();
      final restored = GoalLog.fromMap(map);

      expect(restored.id, log.id);
      expect(restored.content, log.content);
      expect(restored.type, LogType.system);
    });
  });
}
