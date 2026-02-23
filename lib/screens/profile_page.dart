import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/forest_provider.dart';
import '../models/goal_tree.dart';
import '../theme/app_theme.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ForestProvider>(
      builder: (context, provider, child) {
        final totalTrees = provider.currentTrees.length;
        final completedTrees =
            provider.currentTrees.where((t) => t.progress >= 1.0).length;
        final totalYears = provider.years.length;

        return Scaffold(
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppTheme.leafGreen.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.park,
                      size: 40,
                      color: AppTheme.forestGreen,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '我的森林',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.forestGreen,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildStatsRow(totalYears, totalTrees, completedTrees),
                  const SizedBox(height: 24),
                  _buildYearThemeCard(context, provider),
                  const SizedBox(height: 16),
                  _buildBadgesCard(provider),
                  const SizedBox(height: 16),
                  _buildYearHistory(provider),
                  const SizedBox(height: 16),
                  _buildSettingsSection(context),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatsRow(int years, int trees, int completed) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStatColumn(Icons.calendar_today, '$years', '年'),
        Container(
          height: 40,
          width: 1,
          color: AppTheme.paleGreen,
        ),
        _buildStatColumn(Icons.park_outlined, '$trees', '棵树'),
        Container(
          height: 40,
          width: 1,
          color: AppTheme.paleGreen,
        ),
        _buildStatColumn(Icons.emoji_events, '$completed', '已成'),
      ],
    );
  }

  Widget _buildStatColumn(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.leafGreen, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.forestGreen,
          ),
        ),
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

  Widget _buildYearThemeCard(BuildContext context, ForestProvider provider) {
    final year = provider.currentYear;
    final theme = year?.themeSentence ?? '';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.format_quote,
                    color: AppTheme.forestGreen, size: 20),
                const SizedBox(width: 8),
                Text(
                  '${year?.yearNumber ?? DateTime.now().year} 年度主题',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.forestGreen,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.edit, size: 18),
                  color: AppTheme.textSecondary,
                  onPressed: () => _editYearTheme(context, provider, theme),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              theme.isNotEmpty ? '「$theme」' : '点击编辑，写下你今年的主题句',
              style: TextStyle(
                fontSize: 15,
                fontStyle:
                    theme.isEmpty ? FontStyle.italic : FontStyle.normal,
                color:
                    theme.isEmpty ? AppTheme.textSecondary : AppTheme.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadgesCard(ForestProvider provider) {
    final badges = _calculateBadges(provider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.workspace_premium,
                    color: AppTheme.sunYellow, size: 20),
                SizedBox(width: 8),
                Text(
                  '成就徽章',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.forestGreen,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (badges.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    '继续努力，解锁你的第一个徽章！',
                    style: TextStyle(color: AppTheme.textSecondary),
                  ),
                ),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: badges.map((badge) {
                  return Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.sunYellow.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: AppTheme.sunYellow.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(badge['icon'] as String,
                            style: const TextStyle(fontSize: 18)),
                        const SizedBox(width: 6),
                        Text(
                          badge['name'] as String,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textDark,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  List<Map<String, String>> _calculateBadges(ForestProvider provider) {
    final badges = <Map<String, String>>[];
    final trees = provider.currentTrees;

    if (trees.isNotEmpty) {
      badges.add({'icon': '🌱', 'name': '播种者'});
    }

    if (trees.length >= 3) {
      badges.add({'icon': '🌳', 'name': '森林规划师'});
    }

    final completedTrees = trees.where((t) => t.progress >= 1.0).length;
    if (completedTrees >= 1) {
      badges.add({'icon': '🏆', 'name': '目标达成'});
    }

    if (completedTrees >= 3) {
      badges.add({'icon': '👑', 'name': '专注之林'});
    }

    final dormantTrees = trees.where((t) => t.status == GoalStatus.dormant).length;
    if (dormantTrees >= 1) {
      badges.add({'icon': '🍂', 'name': '勇于放下'});
    }

    return badges;
  }

  Widget _buildYearHistory(ForestProvider provider) {
    final years = provider.years;

    if (years.length <= 1) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.history, color: AppTheme.forestGreen, size: 20),
                SizedBox(width: 8),
                Text(
                  '人生森林',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.forestGreen,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...years.map((year) {
              final isCurrentYear =
                  year.id == provider.currentYear?.id;
              return ListTile(
                leading: Icon(
                  isCurrentYear ? Icons.park : Icons.park_outlined,
                  color: isCurrentYear
                      ? AppTheme.leafGreen
                      : AppTheme.textSecondary,
                ),
                title: Text(
                  '${year.yearNumber} 年',
                  style: TextStyle(
                    fontWeight: isCurrentYear
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
                subtitle: year.themeSentence.isNotEmpty
                    ? Text(
                        year.themeSentence,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12),
                      )
                    : null,
                trailing: isCurrentYear
                    ? Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.leafGreen.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          '当前',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppTheme.forestGreen,
                          ),
                        ),
                      )
                    : null,
                onTap: () => provider.switchYear(year.yearNumber),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSection(BuildContext context) {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading:
                const Icon(Icons.lock_outline, color: AppTheme.forestGreen),
            title: const Text('隐私设置'),
            subtitle: const Text('应用锁定、数据保护'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('隐私设置功能开发中...')),
              );
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.share_outlined,
                color: AppTheme.forestGreen),
            title: const Text('分享森林'),
            subtitle: const Text('分享你的森林截图'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('分享功能开发中...')),
              );
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.info_outline,
                color: AppTheme.forestGreen),
            title: const Text('关于'),
            subtitle: const Text('Life Forest v1.0.0'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'Life Forest',
                applicationVersion: '1.0.0',
                applicationLegalese: '把每年的目标种成一片森林',
                children: [
                  const SizedBox(height: 16),
                  const Text(
                    '用户通过设定年度目标、拆分行动，每完成一步，就让自己的树长高、长枝、长叶甚至结果。',
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  void _editYearTheme(
      BuildContext context, ForestProvider provider, String currentTheme) {
    final controller = TextEditingController(text: currentTheme);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              '编辑年度主题',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              '用一句话描述你今年最想实现的愿景',
              style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: '例如：变得更健康、向管理者迈进一步',
              ),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                provider.updateYearTheme(controller.text.trim());
                Navigator.pop(ctx);
              },
              child: const Text('保存'),
            ),
          ],
        ),
      ),
    );
  }
}
