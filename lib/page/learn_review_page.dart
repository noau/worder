import 'dart:developer';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:animated_switcher_plus/animated_switcher_plus.dart';
import 'package:auto_route/auto_route.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:fsrs/fsrs.dart' as fsrs;
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:worder/database.dart';
import 'package:worder/entity/word_model.dart';
import 'package:worder/manager/learning_session_manager.dart';
import 'package:worder/repository.dart';
import 'package:worder/routing.dart';
import 'package:worder/util/context_l10n.dart';

/// Hosts one Review / Learn session.
///
/// Receives a pre-fetched batch of [words] from the caller (Dashboard's
/// Review or Learn button). The page itself drives the session loop:
///
/// 1. Show the front of a card (Word visible, pinyin/meaning/note
///    skeletonized via `Skeletonizer`).
/// 2. User taps **Reveal** — the card flips to the back, showing all four
///    fields in full, and the Reveal button is replaced by the four FSRS
///    rating buttons (Again/Hard/Good/Easy).
/// 3. User rates the card — the manager records the rating, persists the
///    updated word, and the page advances to the next word. When the queue
///    is empty, the page is replaced by [LearnReviewFinishRoute].
///
/// The page does NOT know which kind of session it's hosting (Review vs
/// Learn) and does NOT show an "empty batch" dialog — Dashboard handles
/// that. The page only handles session-internal concerns: the quit
/// confirmation, the in-flight rating guard, and the navigation to the
/// finish page.
@RoutePage()
class LearnReviewPage extends StatefulWidget {
  const LearnReviewPage({super.key, required this.words});

  final List<WordModel> words;

  @override
  State<LearnReviewPage> createState() => _LearnReviewPageState();
}

class _LearnReviewPageState extends State<LearnReviewPage> {
  late final LearningSessionManager manager;

  WordModel? _currentWord;
  bool _isFront = true;
  bool _isRating = false;

  @override
  void initState() {
    super.initState();
    manager = LearningSessionManager(
      initialWords: widget.words,
      storage: context.read<AppDatabase>(),
      scheduler: context.read<SchedulerRepository>().scheduler,
    );
    _loadNext();
  }

  void _loadNext() {
    final next = manager.nextWord();
    if (next == null) {
      _showFinish();
      return;
    }
    setState(() {
      _currentWord = next;
      _isFront = true;
      _isRating = false;
    });
  }

  void _onReveal() {
    if (!_isFront || _isRating || _currentWord == null) return;
    setState(() => _isFront = false);
  }

  Future<void> _onRate(fsrs.Rating rating) async {
    if (_isFront || _isRating || _currentWord == null) return;
    setState(() => _isRating = true);
    try {
      await manager.rateWord(_currentWord!, rating);
      if (!mounted) return;
      setState(() => _isRating = false);
      _loadNext();
    } catch (e) {
      if (!mounted) return;
      setState(() => _isRating = false);
      log('LearnReviewPage.rateWord error: $e', name: 'LearnReviewPage');
      BotToast.showText(text: context.l10n.learnToastRateError);
      // Stay on the same back card so the user can retry the same grade.
    }
  }

  Future<void> _confirmQuit() async {
    if (_currentWord == null) {
      // Session already ended; let the system back propagate.
      context.pop();
      return;
    }
    final result = await showOkCancelAlertDialog(
      context: context,
      title: context.l10n.learnDialogQuitTitle,
      message: context.l10n.learnDialogQuitMessage,
      okLabel: context.l10n.learnDialogQuitOk,
      cancelLabel: context.l10n.learnDialogQuitCancel,
    );
    if (!mounted) return;
    if (result == OkCancelResult.ok) {
      context.pop();
    }
  }

  void _showFinish() {
    if (!mounted) return;
    context.replaceRoute(
      LearnReviewFinishRoute(reviewedCount: manager.reviewedCount),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (!didPop) await _confirmQuit();
      },
      child: Scaffold(
        body: SafeArea(
          top: true,
          bottom: true,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              children: [
                _Header(
                  reviewed: manager.reviewedCount + 1,
                  total: manager.reviewedCount + manager.dueNowCount + 1,
                  onBack: _confirmQuit,
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: AnimatedSwitcherPlus.translationLeft(
                    duration: const Duration(milliseconds: 350),
                    child: Column(
                      key: Key('LearnReview-UI-${_currentWord?.id ?? "empty"}'),
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: 64),
                        _currentWord == null
                            ? const SizedBox(key: ValueKey('empty'))
                            : _WordCard(
                                word: _currentWord!,
                                revealed: !_isFront,
                              ),
                        Spacer(),
                        AnimatedSwitcherPlus.translationLeft(
                          duration: const Duration(milliseconds: 350),
                          child: _currentWord == null
                              ? const SizedBox(key: ValueKey('empty'))
                              : _isFront
                              ? _RevealButton(
                                  key: const ValueKey('reveal'),
                                  onTap: _onReveal,
                                  enabled: !_isRating,
                                )
                              : _RatingButtons(
                                  key: const ValueKey('rates'),
                                  onRate: _onRate,
                                  enabled: !_isRating,
                                ),
                        ),
                        SizedBox(height: 128),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.reviewed,
    required this.total,
    required this.onBack,
  });

  final int reviewed;
  final int total;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final progress = total == 0 ? 0.0 : (reviewed / total);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: onBack,
          tooltip: context.l10n.learnBackTooltip,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: colors.surfaceContainerHighest,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          context.l10n.learnHeaderProgressCounter(reviewed, total),
          style: theme.textTheme.titleSmall?.copyWith(
            color: colors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

/// Front side of a card: Word is real; Pinyin/Meaning/Note are skeletonized.
///
/// The whole column is wrapped in [Skeletonizer] (enabled) so the
/// non-[Skeleton.keep]'d children are painted as `Bone` skeletons. The Word
/// is wrapped in [Skeleton.keep] so it stays real. [enableSwitchAnimation]
/// is set for consistency with the package's recommended pattern — it does
/// not fire while the front widget is stable, but does no harm.
class _WordCard extends StatelessWidget {
  const _WordCard({required this.word, required this.revealed});

  final WordModel word;
  final bool revealed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Skeletonizer(
          key: Key("LearnReview-WordCard-Skeletonizer-${word.id}"),
          enabled: !revealed,
          enableSwitchAnimation: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                word.pinyin.isEmpty ? '   ' : word.pinyin,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Skeleton.keep(
                child: Text(
                  word.word,
                  style: theme.textTheme.displaySmall,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              Text(
                word.meaning.isEmpty ? '   ' : word.meaning,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                word.notes.isEmpty ? '   ' : word.notes.first,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RevealButton extends StatelessWidget {
  const _RevealButton({super.key, required this.onTap, required this.enabled});

  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.tonalIcon(
        onPressed: enabled ? onTap : null,
        icon: const Icon(Icons.visibility_outlined),
        label: Text(context.l10n.learnRevealButton),
      ),
    );
  }
}

class _RatingButtons extends StatelessWidget {
  const _RatingButtons({
    super.key,
    required this.onRate,
    required this.enabled,
  });

  final void Function(fsrs.Rating rating) onRate;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    // 2x2 grid keeps the layout consistent on narrow screens. Each entry
    // has the same `Expanded(child: FilledButton.tonalIcon(...))` shape.
    return Column(
      spacing: 8,
      children: [
        Row(
          spacing: 8,
          children: [
            Expanded(
              child: _RatingButton(
                icon: Icons.refresh,
                label: context.l10n.learnRatingAgain,
                rating: fsrs.Rating.again,
                onRate: onRate,
                enabled: enabled,
              ),
            ),
            Expanded(
              child: _RatingButton(
                icon: Icons.trending_down,
                label: context.l10n.learnRatingHard,
                rating: fsrs.Rating.hard,
                onRate: onRate,
                enabled: enabled,
              ),
            ),
          ],
        ),
        Row(
          spacing: 8,
          children: [
            Expanded(
              child: _RatingButton(
                icon: Icons.check,
                label: context.l10n.learnRatingGood,
                rating: fsrs.Rating.good,
                onRate: onRate,
                enabled: enabled,
              ),
            ),
            Expanded(
              child: _RatingButton(
                icon: Icons.trending_up,
                label: context.l10n.learnRatingEasy,
                rating: fsrs.Rating.easy,
                onRate: onRate,
                enabled: enabled,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _RatingButton extends StatelessWidget {
  const _RatingButton({
    required this.icon,
    required this.label,
    required this.rating,
    required this.onRate,
    required this.enabled,
  });

  final IconData icon;
  final String label;
  final fsrs.Rating rating;
  final void Function(fsrs.Rating rating) onRate;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return FilledButton.tonalIcon(
      onPressed: enabled ? () => onRate(rating) : null,
      icon: Icon(icon),
      label: Text(label),
    );
  }
}
