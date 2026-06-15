import 'dart:developer';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:auto_route/auto_route.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:worder/database.dart';
import 'package:worder/entity/word_model.dart';
import 'package:worder/repository.dart';
import 'package:worder/routing.dart';
import 'package:worder/widget/word_card.dart';

const String _kSlogan = 'Every word, one step further.';

// TODO: 真实首启日期或 Settings 选项
const int _kDaysUsingApp = 7;

String _formatDate(DateTime d) {
  final l = d.toLocal();
  final m = l.month.toString().padLeft(2, '0');
  final day = l.day.toString().padLeft(2, '0');
  return '${l.year}/$m/$day';
}

@RoutePage()
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  // Cached so build() never recreates a new stream subscription. Same pattern
  // as LibraryPage — calling watchXxx() in build() would churn the
  // StreamBuilder on every parent rebuild.
  late final Stream<List<WordModel>> _expiredStream;
  late final Stream<List<WordModel>> _reviewedTodayStream;
  late final Stream<List<WordModel>> _recentStream;

  // Dedupe key per (stream name, error). tostore may emit a new error
  // instance per tick — string fingerprint survives that. Different streams
  // with different errors each get logged once independently.
  String? _lastLoggedFingerprint;

  @override
  void initState() {
    super.initState();
    final appDb = context.read<AppDatabase>();
    _expiredStream = appDb.watchExpiredWords();
    _reviewedTodayStream = appDb.watchReviewedToday();
    _recentStream = appDb.watchRecentlyReviewed();
  }

  void _logErr(String name, Object e) {
    final fp = '$name: $e';
    if (fp != _lastLoggedFingerprint) {
      _lastLoggedFingerprint = fp;
      log('Dashboard stream "$name" error: $e');
    }
  }

  Future<void> _onReview() => _openReview();

  Future<void> _onLearn() async {
    final svc = context.read<AppDatabase>();

    // If review work is waiting, nudge the user — but always let them choose to
    // learn anyway.
    final int dueCount;
    try {
      dueCount = await svc.getExpiredWordsCount();
    } catch (_) {
      if (!mounted) return;
      BotToast.showText(text: 'Could not load review status');
      return;
    }
    if (!mounted) return;
    if (dueCount > 0) {
      final result = await showOkCancelAlertDialog(
        context: context,
        barrierDismissible: false,
        title: 'Review work waiting',
        message:
            '$dueCount word${dueCount == 1 ? '' : 's'} '
            '${dueCount == 1 ? 'is' : 'are'} due for review. '
            'Review them first, or continue with learning?',
        okLabel: 'Review',
        cancelLabel: 'Continue learning',
      );
      if (!mounted || result == OkCancelResult.ok) return;
    }

    final prefs = context.read<PreferencesRepository>();
    final List<WordModel> words;
    try {
      words = await svc.getLearningWords(limit: prefs.learnBatchSize);
    } catch (_) {
      if (!mounted) return;
      BotToast.showText(text: 'Could not load learning words');
      return;
    }
    if (!mounted) return;
    if (words.isEmpty) {
      await showOkAlertDialog(
        context: context,
        title: 'No new words yet',
        message:
            'You have no new words to learn right now. Try to add some new words!',
      );
      return;
    }
    context.pushRoute(LearnReviewRoute(words: words));
  }

  /// Fetch the due review batch and push the session page. Returns silently on
  /// error (toast already shown) or unmount. Used by both the Review button
  /// and the OK branch of the Learn-button's "review first" dialog. Shows a
  /// dismiss-only "all caught up" dialog when the batch is empty.
  Future<void> _openReview() async {
    final svc = context.read<AppDatabase>();
    final prefs = context.read<PreferencesRepository>();
    final List<WordModel> words;
    try {
      words = await svc.getExpiredWords(limit: prefs.reviewBatchSize);
    } catch (_) {
      if (!mounted) return;
      BotToast.showText(text: 'Could not load review words');
      return;
    }
    if (!mounted) return;
    if (words.isEmpty) {
      await showOkAlertDialog(
        context: context,
        title: 'All caught up!',
        message:
            'You have no words due for review right now. Try to learn some new words!',
      );
      return;
    }
    context.pushRoute(LearnReviewRoute(words: words));
  }

  @override
  Widget build(BuildContext context) {
    final date = _formatDate(DateTime.now());
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
      children: [
        _Header(date: date, days: _kDaysUsingApp),
        const SizedBox(height: 16),
        _StatsCard(
          expired: _expiredStream,
          reviewed: _reviewedTodayStream,
          onReview: () => _onReview(),
          onLearn: () => _onLearn(),
          onError: _logErr,
        ),
        const SizedBox(height: 24),
        _RecentSection(stream: _recentStream, onError: _logErr),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.date, required this.days});

  final String date;
  final int days;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.ideographic,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Worder', style: theme.textTheme.headlineMedium),
            const SizedBox(height: 2),
            Text(
              _kSlogan,
              style: theme.textTheme.titleSmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(date, style: theme.textTheme.titleMedium),
            const SizedBox(height: 2),
            Text('Day $days', style: theme.textTheme.titleMedium),
          ],
        ),
      ],
    );
  }
}

class _StatsCard extends StatelessWidget {
  const _StatsCard({
    required this.expired,
    required this.reviewed,
    required this.onReview,
    required this.onLearn,
    required this.onError,
  });

  final Stream<List<WordModel>> expired;
  final Stream<List<WordModel>> reviewed;
  final VoidCallback onReview;
  final VoidCallback onLearn;
  final void Function(String name, Object error) onError;

  @override
  Widget build(BuildContext context) {
    final dividerColor = Theme.of(context).colorScheme.outlineVariant;
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        child: Column(
          children: [
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: _StatCell(
                      label: 'Need to Review',
                      stream: expired,
                      streamName: 'expired',
                      onError: onError,
                    ),
                  ),
                  VerticalDivider(width: 1, color: dividerColor),
                  Expanded(
                    child: _StatCell(
                      label: 'Reviewed Today',
                      stream: reviewed,
                      streamName: 'reviewed',
                      onError: onError,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Divider(),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onReview,
                    child: const Text('Review'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.tonal(
                    onPressed: onLearn,
                    child: const Text('Learn'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  const _StatCell({
    required this.label,
    required this.stream,
    required this.streamName,
    required this.onError,
  });

  final String label;
  final Stream<List<WordModel>> stream;
  final String streamName;
  final void Function(String name, Object error) onError;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return StreamBuilder<List<WordModel>>(
      stream: stream,
      builder: (_, snap) {
        // 等待首帧数据时显示 '—',避免 0 → 真实数字的闪动。
        final waiting =
            snap.connectionState == ConnectionState.waiting && !snap.hasData;
        if (snap.hasError) {
          onError(streamName, snap.error!);
        }
        final display = snap.hasError || waiting
            ? '—'
            : (snap.data?.length ?? 0).toString();
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Text(display, style: theme.textTheme.headlineSmall),
          ],
        );
      },
    );
  }
}

class _RecentSection extends StatelessWidget {
  const _RecentSection({required this.stream, required this.onError});

  final Stream<List<WordModel>> stream;
  final void Function(String name, Object error) onError;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text('Recently reviewed', style: theme.textTheme.titleMedium),
        ),
        const SizedBox(height: 8),
        StreamBuilder<List<WordModel>>(
          stream: stream,
          builder: (_, snap) {
            if (snap.hasError) {
              onError('recent', snap.error!);
              return const _InlineMsg(text: 'Could not load recent reviews.');
            }
            if (snap.connectionState == ConnectionState.waiting &&
                !snap.hasData) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            final words = snap.data ?? const <WordModel>[];
            if (words.isEmpty) {
              return const _InlineMsg(text: 'No reviewed words yet.');
            }
            return Column(
              children: [
                for (final w in words)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: WordCard(word: w),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _InlineMsg extends StatelessWidget {
  const _InlineMsg({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 24),
    child: Center(child: Text(text)),
  );
}
