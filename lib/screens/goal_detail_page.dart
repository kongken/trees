import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/forest_provider.dart';
import '../models/goal_tree.dart';
import '../models/task.dart';
import '../models/log.dart';
import '../theme/app_theme.dart';
import '../widgets/tree_widget.dart';
import '../widgets/milestone_timeline.dart';
import '../widgets/task_tile.dart';

class GoalDetailPage extends StatefulWidget {
  final String treeId;

  const GoalDetailPage({super.key, required this.treeId});

  @override
  State<GoalDetailPage> createState() => _GoalDetailPageState();
}

class _GoalDetailPageState extends State<GoalDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ForestProvider>(
      builder: (context, provider, child) {
        final tree = provider.getTreeById(widget.treeId);
        if (tree == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('目标详情')),
            body: const Center(child: Text('目标不存在')),
          );
        }

        final milestones = provider.getMilestonesForTree(widget.treeId);
        final tasks = provider.getTasksForTree(widget.treeId);
        final logs = provider.getLogsForTree(widget.treeId);
        final categoryColor = AppTheme.getCategoryColor(tree.category.index);

        return Scaffold(
          appBar: AppBar(
            title: Text(tree.title),
            actions: [
              PopupMenuButton<String>(
                onSelected: (value) =>
                    _handleMenuAction(context, provider, tree, value),
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'edit', child: Text('编辑目标')),
                  const PopupMenuItem(value: 'dormant', child: Text('移入休眠林地')),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Text('删除', style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            ],
          ),
          body: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) => [
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    LargeTreeWidget(tree: tree),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: categoryColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${tree.category.icon} ${tree.category.label}',
                              style: TextStyle(
                                  color: categoryColor, fontSize: 13),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.paleGreen.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              tree.growthLabel,
                              style: const TextStyle(
                                  color: AppTheme.forestGreen, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (tree.successDefinition.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.backgroundCream,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '成功定义',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                tree.successDefinition,
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                  ],
                ),
              ),
              SliverPersistentHeader(
                pinned: true,
                delegate: _SliverTabBarDelegate(
                  TabBar(
                    controller: _tabController,
                    labelColor: AppTheme.forestGreen,
                    unselectedLabelColor: AppTheme.textSecondary,
                    indicatorColor: categoryColor,
                    tabs: [
                      Tab(text: '里程碑 (${milestones.length})'),
                      Tab(text: '任务 (${tasks.length})'),
                      Tab(text: '日志 (${logs.length})'),
                    ],
                  ),
                ),
              ),
            ],
            body: TabBarView(
              controller: _tabController,
              children: [
                _buildMilestonesTab(provider, milestones),
                _buildTasksTab(provider, tree, tasks),
                _buildLogsTab(provider, logs),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _showAddOptions(context, provider),
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  Widget _buildMilestonesTab(ForestProvider provider, List milestones) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          MilestoneTimeline(
            milestones: milestones.cast(),
            onComplete: (id) => provider.completeMilestone(id),
            onDelete: (id) => provider.deleteMilestone(id),
          ),
        ],
      ),
    );
  }

  Widget _buildTasksTab(ForestProvider provider, GoalTree tree, List tasks) {
    if (tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.task_alt,
                size: 48, color: AppTheme.leafGreen.withValues(alpha: 0.3)),
            const SizedBox(height: 8),
            const Text(
              '还没有任务\n添加具体行动让树长出叶子',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ],
        ),
      );
    }

    final incompleteTasks = tasks.where((t) => !t.isCompleted).toList();
    final completedTasks = tasks.where((t) => t.isCompleted).toList();

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        if (incompleteTasks.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Text('待完成',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textSecondary)),
          ),
          ...incompleteTasks.map((task) => TaskTile(
                task: task as Task,
                tree: tree,
                onComplete: () => provider.completeTask(task.id),
                onDelete: () => provider.deleteTask(task.id),
              )),
        ],
        if (completedTasks.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Text('已完成',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textSecondary)),
          ),
          ...completedTasks.map((task) => TaskTile(
                task: task as Task,
                tree: tree,
                onUncomplete: () => provider.uncompleteTask(task.id),
                onDelete: () => provider.deleteTask(task.id),
              )),
        ],
      ],
    );
  }

  Widget _buildLogsTab(ForestProvider provider, List logs) {
    if (logs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.book_outlined,
                size: 48, color: AppTheme.leafGreen.withValues(alpha: 0.3)),
            const SizedBox(height: 8),
            const Text(
              '还没有成长日志\n记录你的感悟和进展',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: logs.length,
      itemBuilder: (context, index) {
        final log = logs[index] as GoalLog;
        final isSystem = log.type == LogType.system;

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      isSystem ? Icons.auto_awesome : Icons.edit_note,
                      size: 16,
                      color: isSystem
                          ? AppTheme.sunYellow
                          : AppTheme.forestGreen,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isSystem ? '系统记录' : '成长日志',
                      style: TextStyle(
                        fontSize: 11,
                        color: isSystem
                            ? AppTheme.sunYellow
                            : AppTheme.forestGreen,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      DateFormat('MM-dd HH:mm').format(log.createdAt),
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  log.content,
                  style: TextStyle(
                    fontSize: 14,
                    color: isSystem ? AppTheme.textSecondary : AppTheme.textDark,
                    fontStyle: isSystem ? FontStyle.italic : FontStyle.normal,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _handleMenuAction(BuildContext context, ForestProvider provider,
      GoalTree tree, String action) {
    switch (action) {
      case 'edit':
        _showEditGoal(context, provider, tree);
        break;
      case 'dormant':
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('移入休眠林地'),
            content: const Text('这棵树将进入休眠状态。你可以随时恢复它。'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('取消'),
              ),
              ElevatedButton(
                onPressed: () {
                  provider.moveTreeToDormant(tree.id);
                  Navigator.pop(ctx);
                },
                child: const Text('确认'),
              ),
            ],
          ),
        );
        break;
      case 'delete':
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('删除目标树'),
            content: const Text('确定要删除这棵树吗？所有相关数据将被清除，此操作不可撤销。'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('取消'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () {
                  provider.deleteGoalTree(tree.id);
                  Navigator.pop(ctx);
                  Navigator.pop(context);
                },
                child: const Text('删除'),
              ),
            ],
          ),
        );
        break;
    }
  }

  void _showEditGoal(
      BuildContext context, ForestProvider provider, GoalTree tree) {
    final titleController = TextEditingController(text: tree.title);
    final definitionController =
        TextEditingController(text: tree.successDefinition);

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
            const Text('编辑目标',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: '目标名称'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: definitionController,
              decoration: const InputDecoration(labelText: '成功定义'),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.trim().isNotEmpty) {
                  provider.updateGoalTree(tree.copyWith(
                    title: titleController.text.trim(),
                    successDefinition: definitionController.text.trim(),
                  ));
                  Navigator.pop(ctx);
                }
              },
              child: const Text('保存'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddOptions(BuildContext context, ForestProvider provider) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.flag, color: AppTheme.forestGreen),
              title: const Text('添加里程碑'),
              subtitle: const Text('关键节点，让树干成长'),
              onTap: () {
                Navigator.pop(ctx);
                _showAddMilestone(context, provider);
              },
            ),
            ListTile(
              leading: const Icon(Icons.task_alt, color: AppTheme.leafGreen),
              title: const Text('添加任务'),
              subtitle: const Text('具体行动，让树长出叶子'),
              onTap: () {
                Navigator.pop(ctx);
                _showAddTask(context, provider);
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit_note, color: AppTheme.warmBrown),
              title: const Text('写成长日志'),
              subtitle: const Text('记录感悟和进展'),
              onTap: () {
                Navigator.pop(ctx);
                _showAddLog(context, provider);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAddMilestone(BuildContext context, ForestProvider provider) {
    final titleController = TextEditingController();
    DateTime? selectedDate;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
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
              const Text('添加里程碑',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: '里程碑名称',
                  hintText: '例如：完成项目A的核心功能',
                ),
                autofocus: true,
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () async {
                  final date = await showDatePicker(
                    context: ctx,
                    initialDate: DateTime.now().add(const Duration(days: 30)),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 730)),
                  );
                  if (date != null) {
                    setModalState(() => selectedDate = date);
                  }
                },
                icon: const Icon(Icons.calendar_today, size: 18),
                label: Text(
                  selectedDate != null
                      ? '目标日期：${DateFormat('yyyy-MM-dd').format(selectedDate!)}'
                      : '设置目标日期（可选）',
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (titleController.text.trim().isNotEmpty) {
                    provider.createMilestone(
                      treeId: widget.treeId,
                      title: titleController.text.trim(),
                      dueDate: selectedDate,
                    );
                    Navigator.pop(ctx);
                  }
                },
                child: const Text('添加'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddTask(BuildContext context, ForestProvider provider) {
    final titleController = TextEditingController();
    TaskType selectedType = TaskType.once;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
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
              const Text('添加任务',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: '任务名称',
                  hintText: '例如：每周阅读2篇技术文章',
                ),
                autofocus: true,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: TaskType.values.map((type) {
                  return ChoiceChip(
                    label: Text(type.label),
                    selected: selectedType == type,
                    onSelected: (selected) {
                      if (selected) {
                        setModalState(() => selectedType = type);
                      }
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (titleController.text.trim().isNotEmpty) {
                    provider.createTask(
                      treeId: widget.treeId,
                      title: titleController.text.trim(),
                      type: selectedType,
                    );
                    Navigator.pop(ctx);
                  }
                },
                child: const Text('添加'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddLog(BuildContext context, ForestProvider provider) {
    final contentController = TextEditingController();

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
            const Text('写成长日志',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
              controller: contentController,
              decoration: const InputDecoration(
                labelText: '写下你的感受和进展',
                hintText: '今天的进步，遇到的困难，下一步计划...',
              ),
              maxLines: 4,
              autofocus: true,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (contentController.text.trim().isNotEmpty) {
                  provider.addJournalLog(
                      widget.treeId, contentController.text.trim());
                  Navigator.pop(ctx);
                }
              },
              child: const Text('保存'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _SliverTabBarDelegate(this.tabBar);

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: tabBar,
    );
  }

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  bool shouldRebuild(covariant _SliverTabBarDelegate oldDelegate) {
    return false;
  }
}
