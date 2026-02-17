import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/milestone.dart';
import '../theme/app_theme.dart';

class MilestoneTimeline extends StatelessWidget {
  final List<Milestone> milestones;
  final Function(String milestoneId)? onComplete;
  final Function(String milestoneId)? onDelete;

  const MilestoneTimeline({
    super.key,
    required this.milestones,
    this.onComplete,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (milestones.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Icon(Icons.flag_outlined,
                  size: 48, color: AppTheme.leafGreen.withValues(alpha: 0.4)),
              const SizedBox(height: 8),
              const Text(
                '还没有里程碑\n添加关键节点来让树干成长',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppTheme.textSecondary),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: milestones.length,
      itemBuilder: (context, index) {
        final milestone = milestones[index];
        final isLast = index == milestones.length - 1;

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 40,
                child: Column(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: milestone.isCompleted
                            ? AppTheme.leafGreen
                            : Colors.white,
                        border: Border.all(
                          color: milestone.isCompleted
                              ? AppTheme.leafGreen
                              : AppTheme.textSecondary,
                          width: 2,
                        ),
                      ),
                      child: milestone.isCompleted
                          ? const Icon(Icons.check,
                              size: 14, color: Colors.white)
                          : null,
                    ),
                    if (!isLast)
                      Expanded(
                        child: Container(
                          width: 2,
                          color: milestone.isCompleted
                              ? AppTheme.leafGreen
                              : AppTheme.paleGreen,
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  milestone.title,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    decoration: milestone.isCompleted
                                        ? TextDecoration.lineThrough
                                        : null,
                                    color: milestone.isCompleted
                                        ? AppTheme.textSecondary
                                        : AppTheme.textDark,
                                  ),
                                ),
                                if (milestone.dueDate != null) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    '目标日期：${DateFormat('yyyy-MM-dd').format(milestone.dueDate!)}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppTheme.textSecondary,
                                    ),
                                  ),
                                ],
                                if (milestone.isCompleted &&
                                    milestone.completedAt != null) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    '完成于：${DateFormat('yyyy-MM-dd').format(milestone.completedAt!)}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppTheme.leafGreen,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          if (!milestone.isCompleted && onComplete != null)
                            IconButton(
                              icon: const Icon(Icons.check_circle_outline),
                              color: AppTheme.leafGreen,
                              onPressed: () => onComplete!(milestone.id),
                            ),
                          if (onDelete != null)
                            IconButton(
                              icon: const Icon(Icons.close, size: 18),
                              color: AppTheme.textSecondary,
                              onPressed: () => onDelete!(milestone.id),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
