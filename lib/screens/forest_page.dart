import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/forest_provider.dart';
import '../models/goal_tree.dart';
import '../theme/app_theme.dart';
import '../widgets/tree_widget.dart';
import 'goal_detail_page.dart';
import 'create_goal_page.dart';

class ForestPage extends StatelessWidget {
  const ForestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ForestProvider>(
      builder: (context, provider, child) {
        final year = provider.currentYear;
        final trees = provider.currentTrees;

        return Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                _buildYearSelector(context, provider),
                if (year != null && year.themeSentence.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      '「${year.themeSentence}」',
                      style: const TextStyle(
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                        color: AppTheme.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                const SizedBox(height: 8),
                _buildProgressBar(provider),
                const SizedBox(height: 12),
                Expanded(
                  child: trees.isEmpty
                      ? _buildEmptyState(context)
                      : _buildForestView(context, provider, trees),
                ),
                _buildTodayPreview(context, provider),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _showCreateGoal(context),
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  Widget _buildYearSelector(BuildContext context, ForestProvider provider) {
    final currentYearNumber = provider.currentYear?.yearNumber ?? DateTime.now().year;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () => provider.switchYear(currentYearNumber - 1),
          ),
          GestureDetector(
            onTap: () => _showYearPicker(context, provider, currentYearNumber),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.forestGreen.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$currentYearNumber',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.forestGreen,
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () => provider.switchYear(currentYearNumber + 1),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.leafGreen.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              '${(provider.yearProgress * 100).toInt()}%',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.forestGreen,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(ForestProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: LinearProgressIndicator(
          value: provider.yearProgress,
          minHeight: 6,
          backgroundColor: AppTheme.paleGreen,
          valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.leafGreen),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.park_outlined,
            size: 80,
            color: AppTheme.leafGreen.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          const Text(
            '这片林地还是空的',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '种下你的第一棵目标树吧！',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showCreateGoal(context),
            icon: const Icon(Icons.eco),
            label: const Text('种下种子'),
          ),
        ],
      ),
    );
  }

  Widget _buildForestView(
      BuildContext context, ForestProvider provider, List trees) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: trees.map((tree) {
          final treeHeight = 140.0 + tree.progress * 60.0;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: TreeWidget(
              tree: tree,
              width: 110,
              height: treeHeight,
              showLabel: true,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => GoalDetailPage(treeId: tree.id),
                  ),
                );
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTodayPreview(BuildContext context, ForestProvider provider) {
    final tasks = provider.todayTasks.take(3).toList();

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(Icons.wb_sunny_outlined,
                  color: AppTheme.sunYellow, size: 20),
              const SizedBox(width: 8),
              Text(
                '今天可以做的${provider.todayTasks.length}件事',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textDark,
                ),
              ),
            ],
          ),
          if (tasks.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text(
                '暂无待办事项，享受今天吧！',
                style: TextStyle(
                    fontSize: 13, color: AppTheme.textSecondary),
              ),
            )
          else
            ...tasks.map((task) {
              final tree = provider.getTreeById(task.treeId);
              return Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    if (tree != null)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.getCategoryColor(
                              tree.category.index),
                        ),
                      ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        task.title,
                        style: const TextStyle(fontSize: 13),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (tree != null)
                      Text(
                        tree.category.icon,
                        style: const TextStyle(fontSize: 12),
                      ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  void _showCreateGoal(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const CreateGoalPage()),
    );
  }

  void _showYearPicker(
      BuildContext context, ForestProvider provider, int currentYear) {
    showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: const Text('选择年份'),
          children: List.generate(10, (index) {
            final year = DateTime.now().year - 3 + index;
            return SimpleDialogOption(
              onPressed: () {
                provider.switchYear(year);
                Navigator.pop(context);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  '$year 年',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight:
                        year == currentYear ? FontWeight.bold : FontWeight.normal,
                    color:
                        year == currentYear ? AppTheme.forestGreen : AppTheme.textDark,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
