import 'dart:developer';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:auto_route/auto_route.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:worder/database.dart';
import 'package:worder/entity/word_model.dart';
import 'package:worder/routing.dart';
import 'package:worder/util/context_l10n.dart';
import 'package:worder/util/word_hero_source.dart';
import 'package:worder/widget/library_word_card.dart';

@RoutePage()
class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  // Cached so _retry can replace it with a fresh stream and trigger
  // StreamBuilder to re-subscribe. Calling watchAllWords() in build() would
  // return a new Stream per build, causing redundant re-subscriptions.
  Stream<List<WordModel>>? _stream;

  // String fingerprint (not Object identity) so the storage backend's per-tick
  // error instance doesn't bypass dedupe.
  String? _lastLoggedFingerprint;

  @override
  void initState() {
    super.initState();
    _stream = context.read<AppDatabase>().watchAllWords();
  }

  void _retry() {
    setState(() {
      _stream = context.read<AppDatabase>().watchAllWords();
    });
  }

  void _logErrorOnce(Object error) {
    final fp = error.toString();
    if (fp != _lastLoggedFingerprint) {
      _lastLoggedFingerprint = fp;
      log("Failed to load words: $error");
    }
  }

  Future<void> _openActions(BuildContext context, WordModel word) {
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      useSafeArea: true,
      constraints: BoxConstraints(minHeight: 360),
      builder: (_) => _CardActionsSheet(
        word: word,
        onDelete: () => _confirmDelete(context, word),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WordModel word) async {
    final db = context.read<AppDatabase>();
    final ok = await showOkCancelAlertDialog(
      context: context,
      title: context.l10n.libraryDialogDeleteTitle,
      message: context.l10n.libraryDialogDeleteMessage(word.word),
      okLabel: context.l10n.libraryDialogDeleteOk,
      cancelLabel: context.l10n.libraryDialogDeleteCancel,
      isDestructiveAction: true,
    );
    if (ok != OkCancelResult.ok) return;
    try {
      await db.deleteWord(word);
    } catch (_) {
      if (!mounted) return;
      BotToast.showText(text: context.l10n.libraryToastDeleteError);
      return;
    }
    if (!mounted) return;
    BotToast.showText(text: context.l10n.libraryToastDeleteSuccess);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: StreamBuilder<List<WordModel>>(
        stream: _stream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            _logErrorOnce(snapshot.error!);
            return _ErrorState(onRetry: _retry);
          }
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const _LoadingSkeleton();
          }
          final words = snapshot.data ?? const <WordModel>[];
          if (words.isEmpty) {
            return const _EmptyState();
          }
          return ListView.builder(
            // 96px bottom padding = FAB (56) + standard margin (16) + extra
            // breathing room, so the last row isn't hidden under the host FAB.
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
            itemCount: words.length,
            itemBuilder: (_, i) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: LibraryWordCard(
                word: words[i],
                onTap: () => context.pushRoute(
                  WordDetailRoute(word: words[i], source: WordDetailSource.library),
                ),
                onLongPress: () => _openActions(context, words[i]),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _LoadingSkeleton extends StatelessWidget {
  const _LoadingSkeleton();

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.surfaceContainerHighest;
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      itemCount: 6,
      itemBuilder: (_, _) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(width: 120, height: 18, color: color),
                const SizedBox(height: 12),
                Container(width: 80, height: 12, color: color),
                const SizedBox(height: 8),
                Container(width: double.infinity, height: 12, color: color),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, size: 64, color: colors.error),
          const SizedBox(height: 16),
          Text(
            context.l10n.libraryErrorLoadTitle,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          FilledButton.tonal(
            onPressed: onRetry,
            child: Text(context.l10n.libraryErrorRetry),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.menu_book_outlined,
              size: 64,
              color: colors.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              context.l10n.libraryEmptyTitle,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              context.l10n.libraryEmptyMessage,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => context.pushRoute(AddWordRoute()),
              icon: const Icon(Icons.add),
              label: Text(context.l10n.libraryEmptyAddButton),
            ),
          ],
        ),
      ),
    );
  }
}

class _CardActionsSheet extends StatelessWidget {
  const _CardActionsSheet({required this.word, required this.onDelete});

  final WordModel word;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final error = theme.colorScheme.error;
    return SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
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
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ListTile(
            leading: Icon(Icons.delete_outline, color: error),
            title: Text(
              context.l10n.libraryActionsDelete,
              style: TextStyle(color: error),
            ),
            onTap: () {
              Navigator.of(context).pop();
              onDelete();
            },
          ),
          // 未来动作追加在这里,无需改其他结构。
        ],
      ),
    );
  }
}
