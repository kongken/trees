import 'package:flutter/material.dart';
import '../models/task.dart';
import '../models/goal_tree.dart';
import '../theme/app_theme.dart';

class TaskTile extends StatelessWidget {
  final Task task;
  final GoalTree? tree;
  final VoidCallback? onComplete;
  final VoidCallback? onUncomplete;
  final VoidCallback? onDelete;
  final bool showTreeBadge;

  const TaskTile({
    super.key,
    required this.task,
    this.tree,
    this.onComplete,
    this.onUncomplete,
    this.onDelete,
    this.showTreeBadge = false,
  });

  @override
  Widget build(BuildContext context) {
    final isCompleted = task.isCompleted;
    final categoryColor = tree != null
        ? AppTheme.getCategoryColor(tree!.category.index)
        : AppTheme.leafGreen;

    return Dismissible(
      key: Key(task.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.red),
      ),
      onDismissed: (_) => onDelete?.call(),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: ListTile(
          leading: GestureDetector(
            onTap: isCompleted ? onUncomplete : onComplete,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted ? categoryColor : Colors.transparent,
                border: Border.all(
                  color: categoryColor,
                  width: 2,
                ),
              ),
              child: isCompleted
                  ? const Icon(Icons.check, size: 18, color: Colors.white)
                  : null,
            ),
          ),
          title: Text(
            task.title,
            style: TextStyle(
              fontSize: 15,
              decoration: isCompleted ? TextDecoration.lineThrough : null,
              color: isCompleted ? AppTheme.textSecondary : AppTheme.textDark,
            ),
          ),
          subtitle: showTreeBadge && tree != null
              ? Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: categoryColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${tree!.category.icon} ${tree!.title}',
                          style: TextStyle(
                            fontSize: 11,
                            color: categoryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      if (task.type != TaskType.once) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.paleGreen.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            task.type.label,
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                )
              : null,
          trailing: task.type == TaskType.habit
              ? Icon(Icons.repeat, size: 18, color: categoryColor)
              : null,
        ),
      ),
    );
  }
}
