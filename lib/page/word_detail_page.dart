import 'package:auto_route/auto_route.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:worder/database.dart';
import 'package:worder/entity/word_model.dart';
import 'package:worder/repository.dart';
import 'package:worder/util/date_format.dart';

/// 单个 word 的详情页。
///
/// 通过 `LibraryWordCard` 与 `DashboardWordCard` 的 onTap 进入。展示三块内容:
/// word 信息(词 / 拼音 / 释义)、FSRS scheduling(到期 / 上次复习 / 状态 / 难度 /
/// 可回忆概率 + 时间线)、note 列表(长按操作:编辑 / 置顶 / 删除)。
@RoutePage()
class WordDetailPage extends StatefulWidget {
  const WordDetailPage({super.key, required this.word});

  final WordModel word;

  @override
  State<WordDetailPage> createState() => _WordDetailPageState();
}

class _WordDetailPageState extends State<WordDetailPage> {
  static const _noteSaveErrorMessage = 'Failed to save note';

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
      BotToast.showText(text: _noteSaveErrorMessage);
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
                  _WordInfoArea(word: word),
                  const SizedBox(height: 16),
                  Text("Stats", style: Theme.of(context).textTheme.titleMedium),
                  _FsrsInfoArea(word: word),
                  const SizedBox(height: 16),
                  Text("Notes", style: Theme.of(context).textTheme.titleMedium),
                  _NoteArea(word: word, onLongPressNote: _openNoteActions),
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openNoteEditor(),
        tooltip: 'New note',
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
  const _WordInfoArea({required this.word});

  final WordModel word;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.ideographic,
          spacing: 4,
          children: [
            Text(word.word, style: theme.textTheme.displayLarge),
            Text(
              word.pinyin,
              style: theme.textTheme.displayMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
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
          label: 'Created',
          value: formatAbsoluteDate(word.createAt),
        ),
        _TimelineCell(
          icon: Icons.history,
          label: 'Last review',
          value: card.lastReview == null
              ? 'Never'
              : formatAbsoluteDate(card.lastReview!),
          sub: card.lastReview == null ? '' : formatRelative(card.lastReview!),
        ),
        _TimelineCell(
          icon: Icons.update,
          label: 'Next due',
          value: formatAbsoluteDate(card.due),
          sub: formatRelative(card.due),
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
          label: 'Recall',
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
          label: 'Difficulty',
          value: card.difficulty!.toStringAsFixed(1),
        ),
        _TimelineCell(
          icon: Icons.hourglass_bottom_outlined,
          label: 'Stability',
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
          Icon(
            Icons.lock_outline,
            size: 18,
            color: colors.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Rate this card to see memory stats',
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
              'No notes yet',
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
            child: Row(
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
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.edit_outlined),
            title: const Text('Edit'),
            onTap: () {
              context.pop();
              onEdit();
            },
          ),
          ListTile(
            leading: const Icon(Icons.vertical_align_top),
            title: const Text('Move to top'),
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
            title: Text('Delete', style: TextStyle(color: error)),
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
  static const _saveErrorMessage = 'Failed to save note';

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
      BotToast.showText(text: _saveErrorMessage);
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
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.ideographic,
                spacing: 4,
                children: [
                  Text(widget.word.word, style: theme.textTheme.displayMedium),
                  Text(
                    widget.word.pinyin,
                    style: theme.textTheme.displaySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            TextField(
              controller: _controller,
              minLines: 3,
              maxLines: null,
              maxLength: _maxLength,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Write a note...',
                border: OutlineInputBorder(),
              ),
              onChanged: (v) => setState(() => _canSave = v.trim().isNotEmpty),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _isSaving ? null : () => context.pop(),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: (_canSave && !_isSaving) ? _save : null,
                  child: const Text('Save'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
