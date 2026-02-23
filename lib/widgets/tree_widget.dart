import 'package:flutter/material.dart';
import '../models/goal_tree.dart';
import '../theme/app_theme.dart';
import 'tree_painter.dart';

class TreeWidget extends StatelessWidget {
  final GoalTree tree;
  final double width;
  final double height;
  final VoidCallback? onTap;
  final bool showLabel;

  const TreeWidget({
    super.key,
    required this.tree,
    this.width = 120,
    this.height = 160,
    this.onTap,
    this.showLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    final categoryColor = AppTheme.getCategoryColor(tree.category.index);

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: width,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: width,
              height: height,
              child: CustomPaint(
                painter: TreePainter(
                  progress: tree.progress,
                  leafColor: categoryColor,
                  isDormant: tree.status == GoalStatus.dormant,
                ),
              ),
            ),
            if (showLabel) ...[
              const SizedBox(height: 4),
              Text(
                tree.title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: tree.status == GoalStatus.dormant
                      ? Colors.grey
                      : AppTheme.textDark,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                '${(tree.progress * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 11,
                  color: categoryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class LargeTreeWidget extends StatelessWidget {
  final GoalTree tree;

  const LargeTreeWidget({super.key, required this.tree});

  @override
  Widget build(BuildContext context) {
    final categoryColor = AppTheme.getCategoryColor(tree.category.index);
    final size = MediaQuery.of(context).size;

    return Column(
      children: [
        SizedBox(
          width: size.width * 0.6,
          height: size.width * 0.7,
          child: CustomPaint(
            painter: TreePainter(
              progress: tree.progress,
              leafColor: categoryColor,
              isDormant: tree.status == GoalStatus.dormant,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          tree.growthLabel,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: categoryColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '成长进度 ${(tree.progress * 100).toInt()}%',
          style: const TextStyle(
            fontSize: 14,
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: size.width * 0.5,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: tree.progress,
              minHeight: 8,
              backgroundColor: AppTheme.paleGreen,
              valueColor: AlwaysStoppedAnimation<Color>(categoryColor),
            ),
          ),
        ),
      ],
    );
  }
}
