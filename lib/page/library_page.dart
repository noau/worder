import 'dart:developer';

import 'package:auto_route/auto_route.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:worder/entity/word_model.dart';
import 'package:worder/routing.dart';
import 'package:worder/service.dart';

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

  // Track the last error we logged so the error branch in build() doesn't
  // re-emit the same log line on every parent rebuild while the error persists.
  Object? _lastLoggedError;

  @override
  void initState() {
    super.initState();
    _stream = context.read<WorderStorageService>().watchAllWords();
  }

  void _retry() {
    setState(() {
      _stream = context.read<WorderStorageService>().watchAllWords();
    });
  }

  void _logErrorOnce(Object error) {
    if (!identical(error, _lastLoggedError)) {
      _lastLoggedError = error;
      log("Failed to load words: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<WordModel>>(
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
          itemBuilder: (_, i) => _WordRow(word: words[i]),
        );
      },
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
            "Couldn't load your library",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          FilledButton.tonal(onPressed: onRetry, child: const Text('Retry')),
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
            Text('Library is empty', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              'Add your first word to start building your collection',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => context.pushRoute(AddWordRoute()),
              icon: const Icon(Icons.add),
              label: const Text('Add Word'),
            ),
          ],
        ),
      ),
    );
  }
}

class _WordRow extends StatelessWidget {
  const _WordRow({required this.word});

  final WordModel word;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => BotToast.showText(text: 'Detail view coming soon'),
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
      ),
    );
  }
}
