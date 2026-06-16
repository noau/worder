import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:worder/entity/word_model.dart';

/// Library 标签页专用卡片。
///
/// 视觉与原 [WordCard] 一致(后续可能与 Dashboard 卡片分化)。
/// - onTap:暂保留 'Detail view coming soon' BotToast 占位,与原行为一致。
/// - onLongPress:由 LibraryPage 注入,触发底部动作面板。
class LibraryWordCard extends StatelessWidget {
  const LibraryWordCard({super.key, required this.word, this.onLongPress});

  final WordModel word;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => BotToast.showText(text: 'Detail view coming soon'),
        onLongPress: onLongPress,
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
