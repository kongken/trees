import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/forest_provider.dart';
import '../models/goal_tree.dart';
import '../models/task.dart';
import '../theme/app_theme.dart';
import '../widgets/task_tile.dart';

class TodayPage extends StatelessWidget {
  const TodayPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ForestProvider>(
      builder: (context, provider, child) {
        final todayTasks = provider.todayTasks;
        final today = DateTime.now();

        return Scaffold(
          body: SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          DateFormat('MM月dd日 EEEE', 'zh_CN').format(today),
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          '今日行动',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.forestGreen,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: _buildWateringReport(context, provider),
                ),
                if (todayTasks.isEmpty)
                  SliverFillRemaining(
                    child: _buildEmptyState(),
                  )
                else
                  ..._buildTasksByTree(provider, todayTasks),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWateringReport(BuildContext context, ForestProvider provider) {
    final completedToday =
        provider.currentTrees.fold<int>(0, (sum, tree) {
      final tasks = provider.getTasksForTree(tree.id);
      final today = DateTime.now();
      return sum +
          tasks
              .where((t) =>
                  t.completedAt != null &&
                  t.completedAt!.year == today.year &&
                  t.completedAt!.month == today.month &&
                  t.completedAt!.day == today.day)
              .length;
    });

    final treesWateredToday = <String>{};
    for (final tree in provider.currentTrees) {
      final tasks = provider.getTasksForTree(tree.id);
      final today = DateTime.now();
      final hasCompletedToday = tasks.any((t) =>
          t.completedAt != null &&
          t.completedAt!.year == today.year &&
          t.completedAt!.month == today.month &&
          t.completedAt!.day == today.day);
      if (hasCompletedToday) {
        treesWateredToday.add(tree.id);
      }
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.leafGreen.withValues(alpha: 0.15),
            AppTheme.skyBlue.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.leafGreen.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.water_drop,
                color: AppTheme.leafGreen, size: 24),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '今日浇水报告',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.forestGreen.withValues(alpha: 0.8),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                completedToday > 0
                    ? '完成 $completedToday 个任务，浇灌了 ${treesWateredToday.length} 棵树'
                    : '今天还没开始浇水，来浇浇你的树吧',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _buildTasksByTree(
      ForestProvider provider, List<Task> todayTasks) {
    final tasksByTree = <String, List<Task>>{};
    for (final task in todayTasks) {
      tasksByTree.putIfAbsent(task.treeId, () => []).add(task);
    }

    final slivers = <Widget>[];

    for (final entry in tasksByTree.entries) {
      final tree = provider.getTreeById(entry.key);
      if (tree == null) continue;

      final categoryColor = AppTheme.getCategoryColor(tree.category.index);

      slivers.add(
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
            child: Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: categoryColor,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${tree.category.icon} ${tree.title}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: categoryColor,
                  ),
                ),
                const Spacer(),
                Text(
                  '${(tree.progress * 100).toInt()}%',
                  style: TextStyle(
                    fontSize: 12,
                    color: categoryColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      slivers.add(
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final task = entry.value[index];
              return TaskTile(
                task: task,
                tree: tree,
                onComplete: () => provider.completeTask(task.id),
                onUncomplete: () => provider.uncompleteTask(task.id),
                onDelete: () => provider.deleteTask(task.id),
              );
            },
            childCount: entry.value.length,
          ),
        ),
      );
    }

    return slivers;
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.wb_sunny,
            size: 64,
            color: AppTheme.sunYellow.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            '今天没有待办事项',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '去目标树里添加一些具体任务吧',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
