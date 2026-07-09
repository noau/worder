import 'package:flutter/material.dart';
import 'package:worder/entity/word_model.dart';
import 'package:worder/util/word_hero_source.dart';

/// Dashboard 标签页专用卡片。
///
/// 视觉与 [LibraryWordCard] 保持一致(后续可能分化)。
/// onTap 由 DashboardPage 注入,跳转到 WordDetailPage。
class DashboardWordCard extends StatelessWidget {
  const DashboardWordCard({super.key, required this.word, this.onTap});

  final WordModel word;
  // FIXME(review#10): onTap 是 nullable VoidCallback,InkWell(onTap: null)
  // 完全静默(无 ripple、无响应)。原版本没有 InkWell / 没有 onTap,行为清晰;
  // 当前版本引入 nullable onTap 增加了 "未来调用方漏传 → 死 UI" 的风险,
  // 且失去了原 BotToast stub 'Detail view coming soon' 的最小自检信号。
  //
  // 修复方案:把 onTap 改成 required(强制每个调用方显式传入);
  // 或者保留 nullable 但在 InkWell 外包一个 Builder,onTap 为 null 时
  // 展示一个 disabled 视觉提示。
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
                  Hero(
                    tag: wordHeroTag(WordDetailSource.dashboard, word.id),
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
