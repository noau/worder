import 'dart:async';
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
import 'package:worder/util/date_format.dart';
import 'package:worder/util/day_rollover_stream.dart';
import 'package:worder/widget/dashboard_word_card.dart';

const String _kSlogan = 'Every word, one step further.';

@RoutePage()
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late final AppDatabase _db;
  late final AppLifecycleListener _lifecycleListener;
  late final DayRolloverNotifier _rolloverNotifier;
  late final StreamSubscription<DateTime> _rolloverSubscription;

  // Cached so build() never recreates a new stream subscription. Same pattern
  // as LibraryPage — calling watchXxx() in build() would churn the
  // StreamBuilder on every parent rebuild.
  late Stream<List<WordModel>> _expiredStream;
  late Stream<List<WordModel>> _reviewedTodayStream;
  late Stream<List<WordModel>> _recentStream;
  late int _daysLearnt;

  // 当前 local date。DayRolloverNotifier 只在跨过 midnight 时发一次,
  // 用 setState 驱动的字段即可,不需要 StreamBuilder。
  //
  // BUG FIX (review#1): 之前的代码把 _Header 包在 StreamBuilder 里,StreamBuilder
  // 又订阅了 `_rolloverNotifier.stream`。而 initState 里已经 `.listen()` 同一个
  // 单订阅流(StreamController 默认 + .distinct() 不改变订阅模式),build() 时
  // 第二次订阅立即抛 `Bad state: Stream has already been listened to`,
  // Dashboard 标签页首次进入即崩溃。
  //
  // 修法:把 header 从 StreamBuilder 改成读 `_currentDate`,统一只保留
  // initState 里那一次 `.listen()`,在 `_refreshStreamOnDateRollover` 里
  // setState 同时刷新三个数据流 + 这个字段。
  DateTime _currentDate = DateTime.now();

  // Dedupe key per (stream name, error). The storage backend may emit a new
  // error instance per tick — string fingerprint survives that. Different
  // streams with different errors each get logged once independently.
  String? _lastLoggedFingerprint;

  @override
  void initState() {
    super.initState();
    _daysLearnt = context.read<PreferencesRepository>().daysLearnt();
    _db = context.read<AppDatabase>();
    _expiredStream = _db.watchExpiredWords();
    _reviewedTodayStream = _db.watchReviewedToday();
    _recentStream = _db.watchRecentlyReviewed();
    _rolloverNotifier = dayRolloverNotifier();
    _rolloverSubscription = _rolloverNotifier.stream.listen(
      _refreshOnDateRollover,
    );
    // FIXME(review#7): AppLifecycleListener.onResume 只在 OS 派发窗口生命周期
    // 事件(激活、最小化恢复)时触发。Windows 在前台聚焦状态下穿过午夜不会
    // 触发 onResume(OS 不知道 wall-clock)。所以跨午夜后唯一兜底是
    // day_rollover_stream 的 1 分钟周期 timer,最多 ~60s 的 watchReviewedToday
    // 窗口错位。
    //
    // 修复方案:把 timer 周期从 1 分钟降到 10~30 秒,把窗口错位压到不可感知;
    // 或者在 initState 里算一次 "下次 midnight 的 Duration",挂一次性 Timer
    // 而不是周期 timer,精度更高、wakeup 更少。
    _lifecycleListener = AppLifecycleListener(onResume: _handleLifecycleResume);
  }

  @override
  void dispose() {
    _rolloverSubscription.cancel();
    _lifecycleListener.dispose();
    super.dispose();
  }

  Future<void> _refreshOnDateRollover(DateTime date) async {
    final prefs = context.read<PreferencesRepository>();
    await prefs.checkDaysLearnt();
    if (!mounted) return;
    setState(() {
      _currentDate = date;
      _expiredStream = _db.watchExpiredWords();
      _reviewedTodayStream = _db.watchReviewedToday();
      _recentStream = _db.watchRecentlyReviewed();
      _daysLearnt = prefs.daysLearnt();
    });
  }

  void _handleLifecycleResume() {
    _rolloverNotifier.triggerCheck();
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
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
        children: [
          // _currentDate 由 _refreshStreamOnDateRollover 在 midnight 时 setState
          // 更新。无需 StreamBuilder(每天最多更新一次,StreamBuilder 是 overkill)。
          // BUG FIX (review#1): 之前的 StreamBuilder + initState `.listen()` 双订阅
          // 单订阅流导致首次 build 崩溃。已重构为本字段 + 单一 listener。
          _Header(date: formatAbsoluteDate(_currentDate), days: _daysLearnt),
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
      ),
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
                    child: DashboardWordCard(
                      word: w,
                      onTap: () => context.pushRoute(WordDetailRoute(word: w)),
                    ),
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
