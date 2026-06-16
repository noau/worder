import 'package:flutter/material.dart';
import 'package:worder/entity/word_model.dart';

/// Dashboard 标签页专用卡片。
///
/// 视觉与 [LibraryWordCard] 保持一致(后续可能分化)。
/// onTap 由 DashboardPage 注入,跳转到 WordDetailPage。
class DashboardWordCard extends StatelessWidget {
  const DashboardWordCard({super.key, required this.word, this.onTap});

  final WordModel word;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
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
      ),
    );
  }
}
