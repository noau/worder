import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:worder/entity/word_model.dart';

/// 共用单词卡片(Library 与 Dashboard 复用)。
///
/// 视觉 1:1 复刻原 LibraryPage._WordRow。
/// onTap 默认 'Detail view coming soon' BotToast,可由调用方注入。
class WordCard extends StatelessWidget {
  const WordCard({super.key, required this.word, this.onTap});

  final WordModel word;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap:
            onTap ?? () => BotToast.showText(text: 'Detail view coming soon'),
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
