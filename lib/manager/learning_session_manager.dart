import 'package:collection/collection.dart';
import 'package:fsrs/fsrs.dart' as fsrs;
import 'package:worder/entity/word_model.dart';
import 'package:worder/service.dart';

/// Owns one review/learn session's in-memory queue and FSRS scheduling.
///
/// Holds a [HeapPriorityQueue] of [WordModel]s sorted by [WordModel.fsrsCard]'s
/// `due` datetime (ascending — the earliest-due card is the head). The host
/// UI drives the session loop:
///
/// ```dart
/// final manager = LearningSessionManager(
///   initialWords: batch,
///   storage: storage,
///   scheduler: scheduler,
/// );
/// while (final word = manager.nextWord()) {
///   show(word);   // UI holds `word` itself
///   // Progress: reviewed = manager.reviewedCount, dueNow = manager.dueNowCount
///   await manager.rateWord(word, await userPicksRating());
/// }
/// // Session complete
/// ```
///
/// On each [rateWord] the manager:
///   1. Calls [fsrs.Scheduler.reviewCard] with the caller's `word.fsrsCard`
///      and the chosen [fsrs.Rating].
///   2. Persists the updated [WordModel] via [WorderStorageService.saveWord].
///   3. Adds the re-scheduled card back into the queue (where it lands
///      depends on its new `due`).
///
/// The manager does NOT track a "current" word — the caller does.
///
/// **Progress display.** Use [reviewedCount] (how many ratings applied) and
/// [dueNowCount] (how many cards are due right now). The session ends when
/// [nextWord] returns `null`, which happens when the queue is empty or the
/// head's `due` is in the future.
///
/// **Short-due re-presentation.** Re-queued cards with short future `due`
/// values (e.g. a learning card rescheduled 30 seconds out) will be surfaced
/// again on a later [nextWord] call once wall-clock time advances past their
/// `due`. The manager always uses real [DateTime.now] — never a frozen clock.
///
/// **Error policy.** [rateWord] throws [StateError] if a previous [rateWord]
/// is still in flight. `saveWord` failures propagate unchanged; the queue
/// and counter are not mutated until persistence succeeds, so the caller can
/// surface an error and retry the same grade.
class LearningSessionManager {
  LearningSessionManager({
    required List<WordModel> initialWords,
    required WorderStorageService storage,
    required fsrs.Scheduler scheduler,
  }) : _storage = storage,
       _scheduler = scheduler,
       _queue = HeapPriorityQueue<WordModel>(
         (a, b) => a.fsrsCard.due.compareTo(b.fsrsCard.due),
       ) {
    for (final w in initialWords) {
      _queue.add(w);
    }
  }

  final WorderStorageService _storage;
  final fsrs.Scheduler _scheduler;
  final HeapPriorityQueue<WordModel> _queue;

  int _reviewedCount = 0;
  bool _inFlight = false;

  /// Number of [rateWord] calls applied this session. Monotonically increases.
  int get reviewedCount => _reviewedCount;

  /// Number of cards in the queue whose `due <= DateTime.now()` — i.e., cards
  /// that are immediately available for review. This decreases as [nextWord]
  /// pops cards, and is not increased by [rateWord] because re-queued cards
  /// always receive a future `due` (>= now + learning step). Thus it serves
  /// as a meaningful "remaining tasks" counter for progress display.
  ///
  /// Complexity: O(n) over the current queue size (typically < 200).
  int get dueNowCount {
    if (_queue.isEmpty) return 0;
    final now = DateTime.now();
    // unorderedElements iterates over all elements; no order guarantee but
    // we need to check each anyway.
    return _queue.unorderedElements
        .where((w) => !w.fsrsCard.due.isAfter(now))
        .length;
  }

  /// Pop the queue head and return it, or return `null` when the session is
  /// over (queue empty, or head's `due` is in the future).
  ///
  /// On a non-null return, the word has been removed from the queue. On a
  /// null return, the queue is unchanged.
  WordModel? nextWord() {
    if (_queue.isEmpty) return null;
    if (_queue.first.fsrsCard.due.isAfter(DateTime.now())) return null;
    return _queue.removeFirst();
  }

  /// Apply [rating] to [word] via [fsrs.Scheduler.reviewCard], persist the
  /// updated card via [WorderStorageService.saveWord], then re-queue it.
  ///
  /// The caller passes the word it's currently showing — the manager does
  /// not remember which word is "current." Does not validate that [word]
  /// was previously returned by [nextWord]; the caller is trusted.
  ///
  /// Throws [StateError] if a previous [rateWord] is still in flight.
  /// `saveWord` failures propagate unchanged; the queue and counter are not
  /// mutated on persistence failure.
  Future<void> rateWord(WordModel word, fsrs.Rating rating) async {
    if (_inFlight) {
      throw StateError('LearningSessionManager.rateWord: already in flight');
    }

    _inFlight = true;
    try {
      final now = DateTime.now().toUtc();
      final result = _scheduler.reviewCard(
        word.fsrsCard,
        rating,
        reviewDateTime: now,
      );
      final updated = word.copyWith(fsrsCard: result.card);

      // Persist BEFORE mutating in-memory state. On save failure, throw
      // and leave the queue and counter untouched so the caller can
      // surface an error and retry the grade for the same word.
      await _storage.saveWord(updated);

      _queue.add(updated);
      _reviewedCount += 1;
    } finally {
      _inFlight = false;
    }
  }
}
