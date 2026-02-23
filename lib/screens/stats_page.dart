import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/forest_provider.dart';
import '../models/goal_tree.dart';
import '../theme/app_theme.dart';

class StatsPage extends StatelessWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ForestProvider>(
      builder: (context, provider, child) {
        final trees = provider.currentTrees;
        final year = provider.currentYear;

        return Scaffold(
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Text(
                    '${year?.yearNumber ?? DateTime.now().year} 年度回顾',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.forestGreen,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSummaryCard(provider, trees),
                  const SizedBox(height: 16),
                  _buildOverviewCard(trees),
                  const SizedBox(height: 16),
                  _buildCategoryBreakdown(trees),
                  const SizedBox(height: 16),
                  _buildTreeList(trees),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSummaryCard(ForestProvider provider, List<GoalTree> trees) {
    final completedCount = trees.where((t) => t.progress >= 1.0).length;
    final activeCount =
        trees.where((t) => t.status == GoalStatus.active).length;
    final dormantCount =
        trees.where((t) => t.status == GoalStatus.dormant).length;

    String summaryText;
    if (trees.isEmpty) {
      summaryText = '这一年还没种下任何树，开始规划你的目标吧';
    } else {
      summaryText =
          '你在这一年种下了 ${trees.length} 棵树，其中 $completedCount 棵已长成大树';
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.auto_awesome,
                    color: AppTheme.sunYellow, size: 24),
                const SizedBox(width: 8),
                const Text(
                  '年度总结',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.forestGreen,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              summaryText,
              style: const TextStyle(
                fontSize: 16,
                height: 1.5,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('总目标', '${trees.length}', AppTheme.forestGreen),
                _buildStatItem('进行中', '$activeCount', AppTheme.leafGreen),
                _buildStatItem('已完成', '$completedCount', AppTheme.sunYellow),
                _buildStatItem('休眠中', '$dormantCount', AppTheme.textSecondary),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildOverviewCard(List<GoalTree> trees) {
    if (trees.isEmpty) return const SizedBox.shrink();

    final overallProgress =
        trees.fold<double>(0.0, (sum, t) => sum + t.progress) / trees.length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '整体进度',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.forestGreen,
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: SizedBox(
                width: 120,
                height: 120,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 120,
                      height: 120,
                      child: CircularProgressIndicator(
                        value: overallProgress,
                        strokeWidth: 10,
                        backgroundColor: AppTheme.paleGreen,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                            AppTheme.leafGreen),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${(overallProgress * 100).toInt()}%',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.forestGreen,
                          ),
                        ),
                        const Text(
                          '完成度',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryBreakdown(List<GoalTree> trees) {
    if (trees.isEmpty) return const SizedBox.shrink();

    final categoryMap = <GoalCategory, List<GoalTree>>{};
    for (final tree in trees) {
      categoryMap.putIfAbsent(tree.category, () => []).add(tree);
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '分类详情',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.forestGreen,
              ),
            ),
            const SizedBox(height: 16),
            ...categoryMap.entries.map((entry) {
              final avgProgress = entry.value
                      .fold<double>(0.0, (sum, t) => sum + t.progress) /
                  entry.value.length;
              final color = AppTheme.getCategoryColor(entry.key.index);

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Text(entry.key.icon, style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${entry.key.label} (${entry.value.length}棵树)',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                '${(avgProgress * 100).toInt()}%',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: color,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: avgProgress,
                              minHeight: 6,
                              backgroundColor: color.withValues(alpha: 0.15),
                              valueColor: AlwaysStoppedAnimation<Color>(color),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildTreeList(List<GoalTree> trees) {
    if (trees.isEmpty) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '所有目标树',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.forestGreen,
              ),
            ),
            const SizedBox(height: 12),
            ...trees.map((tree) {
              final color = AppTheme.getCategoryColor(tree.category.index);
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(tree.category.icon,
                            style: const TextStyle(fontSize: 18)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tree.title,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              decoration: tree.status == GoalStatus.dormant
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                          Text(
                            tree.growthLabel,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 60,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: LinearProgressIndicator(
                          value: tree.progress,
                          minHeight: 5,
                          backgroundColor: color.withValues(alpha: 0.15),
                          valueColor: AlwaysStoppedAnimation<Color>(color),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${(tree.progress * 100).toInt()}%',
                      style: TextStyle(
                        fontSize: 12,
                        color: color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
