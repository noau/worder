import 'package:auto_route/auto_route.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:worder/database.dart';
import 'package:worder/entity/word_model.dart';
import 'package:worder/repository.dart';
import 'package:worder/util/context_l10n.dart';
import 'package:worder/util/date_format.dart';
import 'package:worder/util/word_hero_source.dart';

/// 单个 word 的详情页。
///
/// 通过 `LibraryWordCard` 与 `DashboardWordCard` 的 onTap 进入。展示三块内容:
/// word 信息(词 / 拼音 / 释义)、FSRS scheduling(到期 / 上次复习 / 状态 / 难度 /
/// 可回忆概率 + 时间线)、note 列表(长按操作:编辑 / 置顶 / 删除)。
@RoutePage()
class WordDetailPage extends StatefulWidget {
  const WordDetailPage({super.key, required this.word, required this.source});

  final WordModel word;

  /// Hero tag 按来源 tab 区分。卡片端的 `LibraryWordCard` /
  /// `DashboardWordCard` 各自硬编码自己的 `WordDetailSource`,
  /// 这里也必须传同一个,否则 Hero flight 匹配不上。
  final WordDetailSource source;

  @override
  State<WordDetailPage> createState() => _WordDetailPageState();
}

class _WordDetailPageState extends State<WordDetailPage> {
  /// `watchAllWords()` 是按 id 过滤的单条流,缓存于 State 避免重复订阅
  /// (参照 `LibraryPage` 同款模式)。
  late final Stream<WordModel?> _stream;

  /// 最近一次从 StreamBuilder 收到的 word,用于 FAB / sheet 回调读到最新数据。
  /// 初始化为路由参数保证 FAB 首帧也能打开编辑器;`late`(非 final)允许
  /// StreamBuilder 多次 rebuild 时覆盖。
  late WordModel _latest;

  @override
  void initState() {
    super.initState();
    _latest = widget.word;
    _stream = context.read<AppDatabase>().watchWord(wordId: _latest.id);
  }

  Future<void> _saveNotes(List<String> notes) async {
    final db = context.read<AppDatabase>();
    try {
      await db.saveWord(_latest.copyWith(notes: notes));
    } catch (_) {
      if (!mounted) return;
      BotToast.showText(text: context.l10n.wordDetailNoteSaveError);
    }
  }

  Future<void> _moveNoteToTop(int index) async {
    if (index <= 0) return;
    final notes = [..._latest.notes];
    final moved = notes.removeAt(index);
    notes.insert(0, moved);
    await _saveNotes(notes);
  }

  Future<void> _deleteNote(int index) async {
    final notes = [..._latest.notes]..removeAt(index);
    await _saveNotes(notes);
  }

  Future<void> _openNoteEditor({String? initialText, int? editIndex}) {
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      useSafeArea: true,
      constraints: BoxConstraints(minHeight: 480),
      // 让 sheet 在软键盘弹出时跟随上推,否则 TextField 会被遮挡
      isScrollControlled: true,
      builder: (_) => _NoteEditorSheet(
        word: _latest,
        initialText: initialText,
        editIndex: editIndex,
      ),
    );
  }

  Future<void> _openNoteActions(int index) {
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      useSafeArea: true,
      builder: (_) => _NoteActionsSheet(
        word: _latest,
        // FIXME(review#3): `index` 是 long-press 时闭包捕获的原始 int,
        // 而 _deleteNote / _moveNoteToTop 在调用时读 _latest.notes。
        // 如果 long-press 与点击之间 watchWord 因 drift 任何写入(比如
        // LearningSessionManager 在 review 页 saveWord)重新发射,
        // _latest.notes 会变成新列表,被闭包捕获的 index 指向另一条 note,
        // 造成 wrong note silently deleted / moved-to-top。
        //
        // 修复方案:把 notes snapshot(而非 index)传给 sheet,sheet 的
        // onDelete/onMoveToTop 在调用时基于该 snapshot 操作,或者干脆把
        // _deleteNote 改成按 note id 而非 index 操作。
        noteIndex: index,
        onEdit: () => _openNoteEditor(
          initialText: _latest.notes[index],
          editIndex: index,
        ),
        onMoveToTop: () => _moveNoteToTop(index),
        onDelete: () => _deleteNote(index),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // FIXME(review#5): AppBar title 读 widget.word.word(路由参数快照,构造时锁定),
      // body 内的 StreamBuilder 读 stream。两者没有共享 notifier,如果 word 字段
      // 被别处更新(未来增加 edit word 功能、或 drift 流重新发射)会导致 title/body
      // 不一致。修复方案:把 AppBar 也包进 StreamBuilder,或用 ValueNotifier
      // 把 widget.word 提升为可变 state 并在每次 snapshot.data 到达时更新。
      appBar: AppBar(title: Text(widget.word.word)),
      body: SafeArea(
        child: StreamBuilder<WordModel?>(
          stream: _stream,
          initialData: widget.word,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return _InlineError(message: snapshot.error.toString());
            }
            final word = snapshot.data;
            // 流已发过数据但内容为 null → 当前 word 在别处被删除
            // 流还没发数据(初始帧用 widget.word) → 仍渲染 widget.word
            // 这两个 case 由 `snapshot.hasData` 区分
            if (word == null) {
              if (snapshot.hasData) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) context.pop();
                });
              }
              return const SizedBox.shrink();
            }
            // 缓存给回调使用，避免 FAB / sheet 拿到过期 word
            _latest = word;
            return SingleChildScrollView(
              // 96px 底部 padding = FAB (56) + 标准间距 (16) + 额外留白,
              // 保证最后一行 note 不被 FAB 遮挡(对齐 LibraryPage:111)
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _WordInfoArea(word: word, source: widget.source),
                  const SizedBox(height: 16),
                  Text(
                    context.l10n.wordDetailSectionStats,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  _FsrsInfoArea(word: word),
                  const SizedBox(height: 16),
                  Text(
                    context.l10n.wordDetailSectionNotes,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  _NoteArea(word: word, onLongPressNote: _openNoteActions),
                ],
              ),
            );
          },
        ),
      ),
      // FIXME(review#2): 当 watchWord 因别处删除该 word 而发 null 时,
      // builder 返回 SizedBox.shrink() 并通过 addPostFrameCallback 延迟
      // 到下一帧才 context.pop()。但 FAB 是 Scaffold 的直接子节点,
      // 不在 StreamBuilder 内,这一帧内仍可点击。如果用户点了 FAB → 打开
      // editor → 保存,editor 走 `db.saveWord(widget.word.copyWith(...))`,
      // saveWord 的 insertOnConflictUpdate 会用原 id 重新插入该行,
      // 静默复活已删除的 word。
      //
      // 修复方案:在 word==null && snapshot.hasData 分支里把 FAB 禁用,
      // 或者把 _NoteEditorSheet 的保存路径加一个 `if (!_latest.alive) return;` 守卫。
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openNoteEditor(),
        tooltip: context.l10n.wordDetailFabTooltip,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _InlineError extends StatelessWidget {
  const _InlineError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.error,
          ),
        ),
      ),
    );
  }
}

// ===========================================================================
// WordInfoArea
// ===========================================================================

class _WordInfoArea extends StatelessWidget {
  const _WordInfoArea({required this.word, required this.source});

  final WordModel word;

  /// Hero 来源 tab,与卡片端硬编码的 `WordDetailSource` 同名才能匹配。
  final WordDetailSource source;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        _WordHeadline(
          word: word.word,
          pinyin: word.pinyin,
          wordId: word.id,
          source: source,
          wordStyle: theme.textTheme.displayLarge,
          pinyinStyle: theme.textTheme.displayMedium?.copyWith(
            color: colors.onSurfaceVariant,
          ),
        ),
        Text(
          word.meaning,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: colors.onSurfaceVariant,
          ),
          softWrap: true,
        ),
      ],
    );
  }
}

/// Word + pinyin 的标题行,长 word / 长 pinyin 不会横向溢出。
///
/// 默认情况下保持与原本 `Row(... baseline, ideographic)` 一致的视觉
/// (单词 + 拼音同行,baseline 对齐)。当 word + pinyin 在当前 display 尺寸下
/// 的自然总宽超过父容器可用宽度时,降级为纵向 Column(pinyin 在上,word 在下):
/// 这样能保留 word 的"主标题"视觉层级,同时把拼音作为小一号注释放上方,
/// 避免溢出。word 或 pinyin 任一单条仍超出可用宽度时,各自用 `FittedBox.scaleDown`
/// 兜底,强制单行(过宽则缩小字号),避免 word 被字符级换行砍半或 pinyin 失去
/// 一行注音的读感。
class _WordHeadline extends StatelessWidget {
  const _WordHeadline({
    required this.word,
    required this.pinyin,
    required this.wordStyle,
    required this.pinyinStyle,
    this.wordId,
    this.source,
  });

  final String word;
  final String pinyin;
  final TextStyle? wordStyle;
  final TextStyle? pinyinStyle;

  /// Hero tag 中的 wordId。给定时 word 文本会作为 Hero 源/目的端。
  final String? wordId;

  /// Hero tag 中的来源 tab。Library 与 Dashboard 两个源在 tree 里
  /// 共存(由 `AutoTabsScaffold` IndexedStack 行为导致),同一 wordId
  /// 在两个 tab 上同名 Hero 会撞 tag,所以这里把 source 也写进 tag。
  ///
  /// `_WordInfoArea` 处两者都给,`Hero(tag: wordHeroTag(source!, wordId!))`;
  /// `_NoteActionsSheet` / `_NoteEditorSheet` 里都不给,回到纯 Text。
  final WordDetailSource? source;

  /// 横向布局时 word 与 pinyin 之间的间距(对齐原 Row spacing)。
  static const double _hGap = 4;

  /// 纵向降级布局时 word 与 pinyin 之间的间距。
  static const double _vGap = 2;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        final wordWidth = _measureTextWidth(word, wordStyle);
        final pinyinWidth = _measureTextWidth(pinyin, pinyinStyle);
        // 正常 case:word + pinyin 总宽塞得下,保留原 baseline 对齐 Row,
        // 视觉与改动前字节一致。
        if (wordWidth + _hGap + pinyinWidth <= maxWidth) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.ideographic,
            spacing: _hGap,
            children: [
              _heroWord(),
              Text(pinyin, style: pinyinStyle),
            ],
          );
        }
        // 溢出 case:纵向堆叠,word 与 pinyin 任一超宽都用 FittedBox.scaleDown
        // 缩小到单行,而不是依赖字符级 softWrap——避免 word 被砍半或 pinyin
        // 失去一行注音的读感。
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: _vGap,
          children: [
            if (pinyinWidth <= maxWidth)
              Text(pinyin, style: pinyinStyle)
            else
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(pinyin, style: pinyinStyle),
              ),
            if (wordWidth <= maxWidth)
              _heroWord()
            else
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: _heroWord(),
              ),
          ],
        );
      },
    );
  }

  /// word 文本按 [wordId] 是否给定切换 Hero / 纯 Text。
  ///
  /// 仅 word 参与 Hero,pinyin 留在原地——pinyin 从 `titleMedium`(card)飞到
  /// `displayMedium`(detail)尺寸跨度太大,会让飞行看起来"被拉伸",纯
  /// Text 由 Flutter 在源 / 目的端各画一份反而自然。
  Widget _heroWord() {
    final text = Text(word, style: wordStyle);
    if (wordId == null || source == null) return text;
    return Hero(tag: wordHeroTag(source!, wordId!), child: text);
  }

  /// 量出 text 在给定 style 下的自然单行宽度。
  /// style 允许为 null,与 `Text` 渲染时的行为一致。
  double _measureTextWidth(String text, TextStyle? style) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    final width = painter.width;
    painter.dispose();
    return width;
  }
}

// ===========================================================================
// FsrsInfoArea
// ===========================================================================

class _FsrsInfoArea extends StatelessWidget {
  const _FsrsInfoArea({required this.word});

  final WordModel word;

  @override
  Widget build(BuildContext context) {
    // 两行布局:时间线(过去/现在/未来) + 记忆状态(FSRS 当前估计)。
    // 共用 `_TimelineCell` 视觉模板;两个维度天然分离,避免手机宽度的拥挤。
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _TimelineRow(word: word),
        const SizedBox(height: 12),
        _MemoryStatsRow(word: word),
      ],
    );
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({required this.word});

  final WordModel word;

  @override
  Widget build(BuildContext context) {
    final card = word.fsrsCard;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      mainAxisSize: MainAxisSize.max,
      // 不能用 CrossAxisAlignment.stretch:父级 SingleChildScrollView 给了
      // 无限垂直高度,stretch 会让 Row 试图撑到 Infinity,触发断言。
      // Row 高度跟随最高子节点即可,这里改成 start。
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        _TimelineCell(
          icon: Icons.event_outlined,
          label: context.l10n.wordDetailTimelineCreated,
          value: formatAbsoluteDate(context, word.createAt),
        ),
        _TimelineCell(
          icon: Icons.history,
          label: context.l10n.wordDetailTimelineLastReview,
          value: card.lastReview == null
              ? context.l10n.wordDetailTimelineLastReviewNever
              : formatAbsoluteDate(context, card.lastReview!),
          sub: card.lastReview == null
              ? ''
              : formatRelative(context, card.lastReview!),
        ),
        _TimelineCell(
          icon: Icons.update,
          label: context.l10n.wordDetailTimelineNextDue,
          value: formatAbsoluteDate(context, card.due),
          sub: formatRelative(context, card.due),
        ),
      ],
    );
  }
}

/// FSRS 记忆状态行:Recall / Difficulty / Stability。
///
/// 卡片未评过时(`stability == null || lastReview == null`)整行替换为
/// 占位条,而不是显示半成品的 "Not rated yet" 单元格。
class _MemoryStatsRow extends StatelessWidget {
  const _MemoryStatsRow({required this.word});

  final WordModel word;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final card = word.fsrsCard;

    if (card.stability == null || card.lastReview == null) {
      return _MemoryStatsPlaceholder(colors: colors, theme: theme);
    }

    final scheduler = context.read<SchedulerRepository>().scheduler;
    final r = scheduler.getCardRetrievability(card).clamp(0.0, 1.0);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        _TimelineCell(
          icon: Icons.psychology_outlined,
          label: context.l10n.wordDetailMemoryRecall,
          value: '${(r * 100).round()}%',
          secondaryWidget: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: LinearProgressIndicator(
              value: r,
              minHeight: 4,
              backgroundColor: colors.surfaceContainerHighest,
            ),
          ),
        ),
        _TimelineCell(
          icon: Icons.terrain_outlined,
          label: context.l10n.wordDetailMemoryDifficulty,
          value: card.difficulty!.toStringAsFixed(1),
        ),
        _TimelineCell(
          icon: Icons.hourglass_bottom_outlined,
          label: context.l10n.wordDetailMemoryStability,
          value: '${card.stability!.toStringAsFixed(1)} d',
        ),
      ],
    );
  }
}

/// Memory stats 行的占位条:卡片未评过时显示。
class _MemoryStatsPlaceholder extends StatelessWidget {
  const _MemoryStatsPlaceholder({required this.colors, required this.theme});

  final ColorScheme colors;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.lock_outline, size: 18, color: colors.onSurfaceVariant),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              context.l10n.wordDetailMemoryPlaceholder,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineCell extends StatelessWidget {
  const _TimelineCell({
    required this.icon,
    required this.label,
    required this.value,
    this.sub,
    this.secondaryWidget,
  });

  final IconData icon;
  final String label;
  final String value;
  final String? sub;
  final Widget? secondaryWidget;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Expanded(
      child: Row(
        // 占满 Expanded 的有界宽度,这样内层 Column stretch 后能给
        // LinearProgressIndicator 一个 bounded width(否则 LPI 会拿到
        // w=Infinity,触发 "BoxConstraints forces an infinite width")。
        // 纯文字 cell 不受影响:Text 已有 maxLines:1 + ellipsis 兜底。
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 4,
        children: [
          Icon(icon, size: 18, color: colors.onSurfaceVariant),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
                Text(
                  value,
                  style: theme.textTheme.bodyMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (secondaryWidget != null)
                  secondaryWidget!
                else if (sub != null && sub!.isNotEmpty)
                  Text(
                    sub!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ===========================================================================
// NoteArea
// ===========================================================================

class _NoteArea extends StatelessWidget {
  const _NoteArea({required this.word, required this.onLongPressNote});

  final WordModel word;
  final Future<void> Function(int index) onLongPressNote;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    if (word.notes.isEmpty) {
      return Card(
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Center(
            child: Text(
              context.l10n.wordDetailNotesEmpty,
              style: theme.textTheme.titleMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: word.notes
          .mapIndexed(
            (index, note) => Card(
              clipBehavior: .antiAlias,
              child: InkWell(
                onLongPress: () => onLongPressNote(index),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 16,
                  ),
                  child: Text(note),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

// ===========================================================================
// Note actions sheet (long-press a note)
// ===========================================================================

class _NoteActionsSheet extends StatelessWidget {
  const _NoteActionsSheet({
    required this.word,
    required this.noteIndex,
    required this.onEdit,
    required this.onMoveToTop,
    required this.onDelete,
  });

  final WordModel word;
  final int noteIndex;
  final VoidCallback onEdit;
  final VoidCallback onMoveToTop;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final error = colors.error;
    final atTop = noteIndex == 0;
    return SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header: 显示父 word 让用户知道操作的是哪条 word 的 note
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
            child: _WordHeadline(
              word: word.word,
              pinyin: word.pinyin,
              wordStyle: theme.textTheme.titleLarge,
              pinyinStyle: theme.textTheme.titleMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.edit_outlined),
            title: Text(context.l10n.wordDetailNoteEdit),
            onTap: () {
              context.pop();
              onEdit();
            },
          ),
          ListTile(
            leading: const Icon(Icons.vertical_align_top),
            title: Text(context.l10n.wordDetailNoteMoveToTop),
            enabled: !atTop,
            onTap: atTop
                ? null
                : () {
                    context.pop();
                    onMoveToTop();
                  },
          ),
          ListTile(
            leading: Icon(Icons.delete_outline, color: error),
            title: Text(
              context.l10n.wordDetailNoteDelete,
              style: TextStyle(color: error),
            ),
            onTap: () {
              context.pop();
              onDelete();
            },
          ),
        ],
      ),
    );
  }
}

// ===========================================================================
// Note editor sheet (FAB → add / long-press → edit)
// ===========================================================================

class _NoteEditorSheet extends StatefulWidget {
  const _NoteEditorSheet({
    required this.word,
    this.initialText,
    this.editIndex,
  });

  final WordModel word;
  final String? initialText;
  final int? editIndex;

  @override
  State<_NoteEditorSheet> createState() => _NoteEditorSheetState();
}

class _NoteEditorSheetState extends State<_NoteEditorSheet> {
  // TODO: Change to soft limit that alerts user and provide AI summary action (if AI set)
  static const _maxLength = 120;

  late final TextEditingController _controller;
  bool _canSave = false;
  bool _isSaving = false;

  bool get _isEdit => widget.editIndex != null;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialText ?? '');
    _canSave = (widget.initialText ?? '').trim().isNotEmpty;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_canSave || _isSaving) return;
    setState(() => _isSaving = true);
    final db = context.read<AppDatabase>();
    final text = _controller.text.trim();
    // FIXME(review#4): 用的是 widget.word.notes(sheet 构造时的快照)而不是父级
    // _latest.notes。父级 _saveNotes 读的是 _latest.notes。两个 writer 各自
    // 调 db.saveWord,drift 的 insertOnConflictUpdate 是 last-write-wins,
    // 先写入的笔记会被后写入的覆盖,导致 silent data loss。
    //
    // 修复方案:sheet 构造时把当前 _latest 缓存到 State 的一个 field(在
    // didChangeDependencies 或 initState 里读),save 走 `_latest.copyWith(...)`
    // 而不是 widget.word.copyWith(...);或者去掉 editIndex 路径,改用 note id
    // (但 WordModel.notes 当前是 List<String>,没有 id 字段,需要 schema 升级)。
    final notes = [...widget.word.notes];
    if (_isEdit) {
      notes[widget.editIndex!] = text;
    } else {
      notes.add(text);
    }
    try {
      await db.saveWord(widget.word.copyWith(notes: notes));
    } catch (_) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      BotToast.showText(text: context.l10n.wordDetailNoteSaveError);
      return;
    }
    if (!mounted) return;
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _WordHeadline(
                word: widget.word.word,
                pinyin: widget.word.pinyin,
                wordStyle: theme.textTheme.displayMedium,
                pinyinStyle: theme.textTheme.displaySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ),
            TextField(
              controller: _controller,
              minLines: 3,
              maxLines: null,
              maxLength: _maxLength,
              autofocus: true,
              decoration: InputDecoration(
                hintText: context.l10n.wordDetailNoteEditorHint,
                border: const OutlineInputBorder(),
              ),
              onChanged: (v) => setState(() => _canSave = v.trim().isNotEmpty),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _isSaving ? null : () => context.pop(),
                  child: Text(context.l10n.wordDetailNoteEditorCancel),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: (_canSave && !_isSaving) ? _save : null,
                  child: Text(context.l10n.wordDetailNoteEditorSave),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
