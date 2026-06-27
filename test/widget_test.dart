import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:trees/models/year.dart';
import 'package:trees/models/goal_tree.dart';
import 'package:trees/models/milestone.dart';
import 'package:trees/models/task.dart';
import 'package:trees/models/log.dart';
import 'package:trees/theme/app_theme.dart';

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

    test('creates Year with default createdAt', () {
      final before = DateTime.now();
      final year = Year(
        id: 'y1',
        yearNumber: 2026,
        themeSentence: '',
      );
      final after = DateTime.now();

      expect(year.createdAt.isAfter(before.subtract(const Duration(seconds: 1))), true);
      expect(year.createdAt.isBefore(after.add(const Duration(seconds: 1))), true);
    });

    test('Year with empty themeSentence', () {
      final year = Year(id: 'y1', yearNumber: 2026, themeSentence: '');
      expect(year.themeSentence, '');

      final map = year.toMap();
      final restored = Year.fromMap(map);
      expect(restored.themeSentence, '');
    });

    test('Year serialization preserves createdAt accurately', () {
      final specificTime = DateTime(2026, 3, 15, 10, 30, 45);
      final year = Year(
        id: 'y1',
        yearNumber: 2026,
        themeSentence: '坚持学习',
        createdAt: specificTime,
      );

      final map = year.toMap();
      expect(map['createdAt'], specificTime.toIso8601String());

      final restored = Year.fromMap(map);
      expect(restored.createdAt, specificTime);
    });

    test('Year copyWith can update all fields', () {
      final year = Year(
        id: 'y1',
        yearNumber: 2025,
        themeSentence: '旧主题',
        createdAt: DateTime(2025, 1, 1),
      );

      final newTime = DateTime(2026, 6, 1);
      final updated = year.copyWith(
        id: 'y2',
        yearNumber: 2026,
        themeSentence: '新主题',
        createdAt: newTime,
      );

      expect(updated.id, 'y2');
      expect(updated.yearNumber, 2026);
      expect(updated.themeSentence, '新主题');
      expect(updated.createdAt, newTime);
    });

    test('Year copyWith preserves original when no args', () {
      final original = Year(
        id: 'y1',
        yearNumber: 2026,
        themeSentence: '主题',
        createdAt: DateTime(2026, 1, 1),
      );

      final copy = original.copyWith();
      expect(copy.id, original.id);
      expect(copy.yearNumber, original.yearNumber);
      expect(copy.themeSentence, original.themeSentence);
      expect(copy.createdAt, original.createdAt);
    });

    test('Year toMap produces correct keys', () {
      final year = Year(
        id: 'y1',
        yearNumber: 2026,
        themeSentence: '测试',
        createdAt: DateTime(2026, 1, 1),
      );

      final map = year.toMap();
      expect(map.containsKey('id'), true);
      expect(map.containsKey('yearNumber'), true);
      expect(map.containsKey('themeSentence'), true);
      expect(map.containsKey('createdAt'), true);
      expect(map.length, 4);
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
      expect(tree.successDefinition, '');
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

    test('growthStage at exact boundary values', () {
      GoalTree tree(double p) => GoalTree(
            id: 'x', yearId: 'y', title: 't', category: GoalCategory.health,
            progress: p,
          );

      expect(tree(0.0).growthStage, 0);
      expect(tree(0.24).growthStage, 0);
      expect(tree(0.25).growthStage, 1);
      expect(tree(0.49).growthStage, 1);
      expect(tree(0.50).growthStage, 2);
      expect(tree(0.74).growthStage, 2);
      expect(tree(0.75).growthStage, 3);
      expect(tree(0.99).growthStage, 3);
      expect(tree(1.0).growthStage, 4);
    });

    test('growthLabel covers all stages', () {
      GoalTree tree(double p) => GoalTree(
            id: 'x', yearId: 'y', title: 't', category: GoalCategory.health,
            progress: p,
          );

      expect(tree(0.0).growthLabel, '小树苗');
      expect(tree(0.25).growthLabel, '小树');
      expect(tree(0.50).growthLabel, '枝叶繁茂');
      expect(tree(0.75).growthLabel, '硕果累累');
      expect(tree(1.0).growthLabel, '大树');
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

    test('GoalCategory has correct icons', () {
      expect(GoalCategory.health.icon, '💪');
      expect(GoalCategory.career.icon, '💼');
      expect(GoalCategory.finance.icon, '💰');
      expect(GoalCategory.learning.icon, '📚');
      expect(GoalCategory.social.icon, '👥');
      expect(GoalCategory.hobby.icon, '🎨');
      expect(GoalCategory.custom.icon, '🌱');
    });

    test('GoalTree serialization preserves all fields', () {
      final createdAt = DateTime(2026, 3, 1, 12, 0, 0);
      final tree = GoalTree(
        id: 'tree-1',
        yearId: 'year-1',
        title: '阅读50本书',
        category: GoalCategory.learning,
        successDefinition: '每周阅读一本',
        createdAt: createdAt,
        status: GoalStatus.completed,
        progress: 1.0,
      );

      final map = tree.toMap();
      final restored = GoalTree.fromMap(map);

      expect(restored.id, 'tree-1');
      expect(restored.yearId, 'year-1');
      expect(restored.title, '阅读50本书');
      expect(restored.category, GoalCategory.learning);
      expect(restored.successDefinition, '每周阅读一本');
      expect(restored.createdAt, createdAt);
      expect(restored.status, GoalStatus.completed);
      expect(restored.progress, 1.0);
    });

    test('GoalTree serialization with all GoalStatus values', () {
      for (final status in GoalStatus.values) {
        final tree = GoalTree(
          id: 'tree-s',
          yearId: 'y',
          title: 't',
          category: GoalCategory.health,
          status: status,
        );

        final restored = GoalTree.fromMap(tree.toMap());
        expect(restored.status, status);
      }
    });

    test('GoalTree serialization with all GoalCategory values', () {
      for (final category in GoalCategory.values) {
        final tree = GoalTree(
          id: 'tree-c',
          yearId: 'y',
          title: 't',
          category: category,
        );

        final restored = GoalTree.fromMap(tree.toMap());
        expect(restored.category, category);
      }
    });

    test('GoalTree fromMap handles null successDefinition', () {
      final map = {
        'id': 'tree-1',
        'yearId': 'year-1',
        'title': '测试',
        'category': 0,
        'successDefinition': null,
        'createdAt': DateTime(2026, 1, 1).toIso8601String(),
        'status': 0,
        'progress': 0.0,
      };

      final tree = GoalTree.fromMap(map);
      expect(tree.successDefinition, '');
    });

    test('GoalTree copyWith updates specific fields', () {
      final tree = GoalTree(
        id: 'tree-1',
        yearId: 'year-1',
        title: '原标题',
        category: GoalCategory.health,
        status: GoalStatus.active,
        progress: 0.3,
      );

      final updated = tree.copyWith(
        title: '新标题',
        progress: 0.8,
        status: GoalStatus.completed,
      );

      expect(updated.id, 'tree-1');
      expect(updated.yearId, 'year-1');
      expect(updated.title, '新标题');
      expect(updated.category, GoalCategory.health);
      expect(updated.progress, 0.8);
      expect(updated.status, GoalStatus.completed);
    });

    test('GoalTree copyWith preserves original when no args', () {
      final original = GoalTree(
        id: 'tree-1',
        yearId: 'year-1',
        title: '标题',
        category: GoalCategory.finance,
        successDefinition: '定义',
        status: GoalStatus.dormant,
        progress: 0.5,
        createdAt: DateTime(2026, 1, 1),
      );

      final copy = original.copyWith();
      expect(copy.id, original.id);
      expect(copy.yearId, original.yearId);
      expect(copy.title, original.title);
      expect(copy.category, original.category);
      expect(copy.successDefinition, original.successDefinition);
      expect(copy.status, original.status);
      expect(copy.progress, original.progress);
      expect(copy.createdAt, original.createdAt);
    });

    test('GoalTree toMap uses enum index for category and status', () {
      final tree = GoalTree(
        id: 'tree-1',
        yearId: 'year-1',
        title: 't',
        category: GoalCategory.learning,
        status: GoalStatus.dormant,
      );

      final map = tree.toMap();
      expect(map['category'], GoalCategory.learning.index);
      expect(map['status'], GoalStatus.dormant.index);
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

    test('Milestone copyWith clearCompletedAt resets completion', () {
      final milestone = Milestone(
        id: 'm-1',
        treeId: 'tree-1',
        title: '里程碑A',
        completedAt: DateTime(2026, 6, 15),
      );

      expect(milestone.isCompleted, true);

      final uncompleted = milestone.copyWith(clearCompletedAt: true);
      expect(uncompleted.isCompleted, false);
      expect(uncompleted.completedAt, null);
      expect(uncompleted.title, '里程碑A');
    });

    test('Milestone serialization with null dueDate', () {
      final milestone = Milestone(
        id: 'm-1',
        treeId: 'tree-1',
        title: '无截止日期',
      );

      final map = milestone.toMap();
      expect(map['dueDate'], null);

      final restored = Milestone.fromMap(map);
      expect(restored.dueDate, null);
    });

    test('Milestone serialization with dueDate', () {
      final dueDate = DateTime(2026, 12, 31);
      final milestone = Milestone(
        id: 'm-1',
        treeId: 'tree-1',
        title: '年底完成',
        dueDate: dueDate,
      );

      final map = milestone.toMap();
      expect(map['dueDate'], dueDate.toIso8601String());

      final restored = Milestone.fromMap(map);
      expect(restored.dueDate, dueDate);
    });

    test('Milestone serialization with completedAt', () {
      final completedAt = DateTime(2026, 6, 20, 14, 30, 0);
      final milestone = Milestone(
        id: 'm-1',
        treeId: 'tree-1',
        title: '已完成里程碑',
        completedAt: completedAt,
      );

      final map = milestone.toMap();
      final restored = Milestone.fromMap(map);
      expect(restored.isCompleted, true);
      expect(restored.completedAt, completedAt);
    });

    test('Milestone serialization with null completedAt', () {
      final milestone = Milestone(
        id: 'm-1',
        treeId: 'tree-1',
        title: '未完成里程碑',
      );

      final map = milestone.toMap();
      expect(map['completedAt'], null);

      final restored = Milestone.fromMap(map);
      expect(restored.isCompleted, false);
      expect(restored.completedAt, null);
    });

    test('Milestone default order is 0', () {
      final milestone = Milestone(
        id: 'm-1',
        treeId: 'tree-1',
        title: '默认排序',
      );

      expect(milestone.order, 0);
    });

    test('Milestone toMap uses orderIndex key', () {
      final milestone = Milestone(
        id: 'm-1',
        treeId: 'tree-1',
        title: '排序测试',
        order: 3,
      );

      final map = milestone.toMap();
      expect(map['orderIndex'], 3);
      expect(map.containsKey('order'), false);
    });

    test('Milestone fromMap handles null orderIndex', () {
      final map = {
        'id': 'm-1',
        'treeId': 'tree-1',
        'title': '测试',
        'dueDate': null,
        'completedAt': null,
        'orderIndex': null,
      };

      final milestone = Milestone.fromMap(map);
      expect(milestone.order, 0);
    });

    test('Milestone copyWith preserves original when no args', () {
      final original = Milestone(
        id: 'm-1',
        treeId: 'tree-1',
        title: '原里程碑',
        dueDate: DateTime(2026, 12, 31),
        completedAt: DateTime(2026, 6, 1),
        order: 2,
      );

      final copy = original.copyWith();
      expect(copy.id, original.id);
      expect(copy.treeId, original.treeId);
      expect(copy.title, original.title);
      expect(copy.dueDate, original.dueDate);
      expect(copy.completedAt, original.completedAt);
      expect(copy.order, original.order);
    });

    test('Milestone copyWith updates specific fields', () {
      final milestone = Milestone(
        id: 'm-1',
        treeId: 'tree-1',
        title: '原始标题',
        order: 0,
      );

      final updated = milestone.copyWith(
        title: '新标题',
        order: 5,
        dueDate: DateTime(2026, 9, 1),
      );

      expect(updated.title, '新标题');
      expect(updated.order, 5);
      expect(updated.dueDate, DateTime(2026, 9, 1));
      expect(updated.id, 'm-1');
      expect(updated.treeId, 'tree-1');
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
      expect(task.milestoneId, null);
      expect(task.repeatRule, null);
      expect(task.dueDate, null);
      expect(task.completedAt, null);
    });

    test('Task default type is once', () {
      final task = Task(
        id: 't-1',
        treeId: 'tree-1',
        title: '一次性任务',
      );

      expect(task.type, TaskType.once);
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

    test('Task serialization preserves all fields', () {
      final createdAt = DateTime(2026, 3, 1);
      final dueDate = DateTime(2026, 6, 30);
      final completedAt = DateTime(2026, 6, 15);

      final task = Task(
        id: 't-1',
        treeId: 'tree-1',
        milestoneId: 'm-1',
        title: '完成报告',
        type: TaskType.deadline,
        repeatRule: 'monthly',
        dueDate: dueDate,
        completedAt: completedAt,
        createdAt: createdAt,
      );

      final map = task.toMap();
      final restored = Task.fromMap(map);

      expect(restored.id, 't-1');
      expect(restored.treeId, 'tree-1');
      expect(restored.milestoneId, 'm-1');
      expect(restored.title, '完成报告');
      expect(restored.type, TaskType.deadline);
      expect(restored.repeatRule, 'monthly');
      expect(restored.dueDate, dueDate);
      expect(restored.completedAt, completedAt);
      expect(restored.createdAt, createdAt);
    });

    test('Task serialization with all null optional fields', () {
      final task = Task(
        id: 't-1',
        treeId: 'tree-1',
        title: '简单任务',
      );

      final map = task.toMap();
      expect(map['milestoneId'], null);
      expect(map['repeatRule'], null);
      expect(map['dueDate'], null);
      expect(map['completedAt'], null);

      final restored = Task.fromMap(map);
      expect(restored.milestoneId, null);
      expect(restored.repeatRule, null);
      expect(restored.dueDate, null);
      expect(restored.completedAt, null);
    });

    test('Task serialization with all TaskType values', () {
      for (final type in TaskType.values) {
        final task = Task(
          id: 't-type',
          treeId: 'tree-1',
          title: '类型测试',
          type: type,
        );

        final restored = Task.fromMap(task.toMap());
        expect(restored.type, type);
      }
    });

    test('Task copyWith clearCompletedAt resets completion', () {
      final task = Task(
        id: 't-1',
        treeId: 'tree-1',
        title: '已完成任务',
        completedAt: DateTime(2026, 6, 15),
      );

      expect(task.isCompleted, true);

      final uncompleted = task.copyWith(clearCompletedAt: true);
      expect(uncompleted.isCompleted, false);
      expect(uncompleted.completedAt, null);
      expect(uncompleted.title, '已完成任务');
    });

    test('Task copyWith clearMilestoneId removes milestone link', () {
      final task = Task(
        id: 't-1',
        treeId: 'tree-1',
        milestoneId: 'm-1',
        title: '关联任务',
      );

      expect(task.milestoneId, 'm-1');

      final unlinked = task.copyWith(clearMilestoneId: true);
      expect(unlinked.milestoneId, null);
      expect(unlinked.title, '关联任务');
    });

    test('Task copyWith preserves original when no args', () {
      final original = Task(
        id: 't-1',
        treeId: 'tree-1',
        milestoneId: 'm-1',
        title: '原始任务',
        type: TaskType.deadline,
        repeatRule: 'daily',
        dueDate: DateTime(2026, 12, 31),
        completedAt: DateTime(2026, 6, 1),
        createdAt: DateTime(2026, 1, 1),
      );

      final copy = original.copyWith();
      expect(copy.id, original.id);
      expect(copy.treeId, original.treeId);
      expect(copy.milestoneId, original.milestoneId);
      expect(copy.title, original.title);
      expect(copy.type, original.type);
      expect(copy.repeatRule, original.repeatRule);
      expect(copy.dueDate, original.dueDate);
      expect(copy.completedAt, original.completedAt);
      expect(copy.createdAt, original.createdAt);
    });

    test('Task copyWith updates specific fields', () {
      final task = Task(
        id: 't-1',
        treeId: 'tree-1',
        title: '原标题',
        type: TaskType.once,
      );

      final updated = task.copyWith(
        title: '新标题',
        type: TaskType.habit,
        repeatRule: 'weekly',
      );

      expect(updated.title, '新标题');
      expect(updated.type, TaskType.habit);
      expect(updated.repeatRule, 'weekly');
      expect(updated.id, 't-1');
      expect(updated.treeId, 'tree-1');
    });

    test('Task isCompleted reflects completedAt state', () {
      final incomplete = Task(
        id: 't-1',
        treeId: 'tree-1',
        title: '任务',
      );
      expect(incomplete.isCompleted, false);

      final completed = incomplete.copyWith(completedAt: DateTime.now());
      expect(completed.isCompleted, true);

      final uncompleted = completed.copyWith(clearCompletedAt: true);
      expect(uncompleted.isCompleted, false);
    });

    test('Task creates with default createdAt', () {
      final before = DateTime.now();
      final task = Task(
        id: 't-1',
        treeId: 'tree-1',
        title: '任务',
      );
      final after = DateTime.now();

      expect(task.createdAt.isAfter(before.subtract(const Duration(seconds: 1))), true);
      expect(task.createdAt.isBefore(after.add(const Duration(seconds: 1))), true);
    });

    test('Task toMap uses enum index for type', () {
      final task = Task(
        id: 't-1',
        treeId: 'tree-1',
        title: '任务',
        type: TaskType.deadline,
      );

      final map = task.toMap();
      expect(map['type'], TaskType.deadline.index);
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

    test('GoalLog serialization preserves all fields', () {
      final createdAt = DateTime(2026, 6, 15, 10, 30, 0);
      final log = GoalLog(
        id: 'l-1',
        treeId: 'tree-1',
        content: '完成了重要里程碑',
        createdAt: createdAt,
        type: LogType.system,
      );

      final map = log.toMap();
      final restored = GoalLog.fromMap(map);

      expect(restored.id, 'l-1');
      expect(restored.treeId, 'tree-1');
      expect(restored.content, '完成了重要里程碑');
      expect(restored.createdAt, createdAt);
      expect(restored.type, LogType.system);
    });

    test('GoalLog serialization with all LogType values', () {
      for (final type in LogType.values) {
        final log = GoalLog(
          id: 'l-type',
          treeId: 'tree-1',
          content: '日志',
          type: type,
        );

        final restored = GoalLog.fromMap(log.toMap());
        expect(restored.type, type);
      }
    });

    test('GoalLog creates with default createdAt', () {
      final before = DateTime.now();
      final log = GoalLog(
        id: 'l-1',
        treeId: 'tree-1',
        content: '新日志',
      );
      final after = DateTime.now();

      expect(log.createdAt.isAfter(before.subtract(const Duration(seconds: 1))), true);
      expect(log.createdAt.isBefore(after.add(const Duration(seconds: 1))), true);
    });

    test('GoalLog copyWith updates specific fields', () {
      final log = GoalLog(
        id: 'l-1',
        treeId: 'tree-1',
        content: '原内容',
        type: LogType.userJournal,
      );

      final updated = log.copyWith(
        content: '新内容',
        type: LogType.system,
      );

      expect(updated.content, '新内容');
      expect(updated.type, LogType.system);
      expect(updated.id, 'l-1');
      expect(updated.treeId, 'tree-1');
    });

    test('GoalLog copyWith preserves original when no args', () {
      final original = GoalLog(
        id: 'l-1',
        treeId: 'tree-1',
        content: '内容',
        createdAt: DateTime(2026, 1, 1),
        type: LogType.system,
      );

      final copy = original.copyWith();
      expect(copy.id, original.id);
      expect(copy.treeId, original.treeId);
      expect(copy.content, original.content);
      expect(copy.createdAt, original.createdAt);
      expect(copy.type, original.type);
    });

    test('GoalLog toMap uses enum index for type', () {
      final systemLog = GoalLog(
        id: 'l-1',
        treeId: 'tree-1',
        content: '系统',
        type: LogType.system,
      );
      expect(systemLog.toMap()['type'], LogType.system.index);

      final journalLog = GoalLog(
        id: 'l-2',
        treeId: 'tree-1',
        content: '日记',
        type: LogType.userJournal,
      );
      expect(journalLog.toMap()['type'], LogType.userJournal.index);
    });
  });

  group('AppTheme', () {
    test('getCategoryColor returns correct color for each category', () {
      expect(AppTheme.getCategoryColor(0), const Color(0xFF66BB6A)); // health
      expect(AppTheme.getCategoryColor(1), const Color(0xFF42A5F5)); // career
      expect(AppTheme.getCategoryColor(2), const Color(0xFFFFCA28)); // finance
      expect(AppTheme.getCategoryColor(3), const Color(0xFFAB47BC)); // learning
      expect(AppTheme.getCategoryColor(4), const Color(0xFFEF5350)); // social
      expect(AppTheme.getCategoryColor(5), const Color(0xFFFF7043)); // hobby
      expect(AppTheme.getCategoryColor(6), const Color(0xFF78909C)); // custom
    });

    test('getCategoryColor wraps with modular index', () {
      expect(AppTheme.getCategoryColor(7), AppTheme.getCategoryColor(0));
      expect(AppTheme.getCategoryColor(8), AppTheme.getCategoryColor(1));
      expect(AppTheme.getCategoryColor(14), AppTheme.getCategoryColor(0));
    });

    test('getCategoryColor matches GoalCategory index', () {
      for (final category in GoalCategory.values) {
        final color = AppTheme.getCategoryColor(category.index);
        expect(color, isNotNull);
        expect(color, isA<Color>());
      }
    });

    test('lightTheme creates valid ThemeData', () {
      final theme = AppTheme.lightTheme;
      expect(theme, isA<ThemeData>());
      expect(theme.useMaterial3, true);
      expect(theme.brightness, Brightness.light);
      expect(theme.scaffoldBackgroundColor, AppTheme.backgroundLight);
    });

    test('theme constants are correct', () {
      expect(AppTheme.forestGreen, const Color(0xFF2D5016));
      expect(AppTheme.leafGreen, const Color(0xFF4CAF50));
      expect(AppTheme.backgroundLight, const Color(0xFFF1F8E9));
      expect(AppTheme.backgroundCream, const Color(0xFFFFF8E1));
      expect(AppTheme.earthBrown, const Color(0xFF795548));
      expect(AppTheme.sunYellow, const Color(0xFFFFD54F));
    });
  });
}
