import 'package:flutter/material.dart';
import 'package:worder/entity/word_model.dart';

/// Dashboard 标签页专用卡片,纯展示。
///
/// 视觉与 [LibraryWordCard] 当前一致(后续会与 Library 卡片分化)。
/// 无任何手势响应:不包 InkWell,不响应轻点/长按 —— Dashboard
/// 当前没有作用于卡片本身的动作,展示卡不应假装响应点击。
class DashboardWordCard extends StatelessWidget {
  const DashboardWordCard({super.key, required this.word});

  final WordModel word;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.ideographic,
              spacing: 4,
              children: [
                Text(word.word, style: theme.textTheme.titleLarge),
                Text(
                  word.pinyin,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            Text(
              word.meaning,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
              softWrap: true,
            ),
          ],
        ),
      ),
    );
  }
}
