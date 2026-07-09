import 'package:flutter/material.dart';
import 'package:worder/entity/word_model.dart';
import 'package:worder/util/word_hero_source.dart';

/// Library 标签页专用卡片。
///
/// 视觉与 Dashboard 卡片保持一致(后续可能分化)。
/// - onTap:由 LibraryPage 注入,跳转到 WordDetailPage。
/// - onLongPress:由 LibraryPage 注入,触发底部动作面板。
class LibraryWordCard extends StatelessWidget {
  const LibraryWordCard({
    super.key,
    required this.word,
    this.onTap,
    this.onLongPress,
  });

  final WordModel word;
  // FIXME(review#10): onTap 是 nullable VoidCallback,InkWell(onTap: null)
  // 完全静默(无 ripple、无响应)。原版本有 BotToast stub 'Detail view coming
  // soon'——即便 detail 页未实现,点 card 至少有个 toast 自检信号;新版本
  // 删掉 stub 改为 nullable,未来调用方漏传会变成死 UI(无任何反馈)。
  //
  // 修复方案:把 onTap 改成 required(强制每个调用方显式传入);
  // 或者保留 nullable 但在 InkWell 外包一个 Builder,onTap 为 null 时
  // 展示一个 disabled 视觉提示。
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
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
                  Hero(
                    tag: wordHeroTag(WordDetailSource.library, word.id),
                    child: Text(word.word, style: theme.textTheme.titleLarge),
                  ),
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
