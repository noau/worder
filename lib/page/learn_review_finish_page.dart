import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:worder/routing.dart';

/// Placeholder for the end-of-session summary.
///
/// Reached via [LearnReviewFinishRoute] when [LearnReviewPage]'s
/// `LearningSessionManager.nextWord()` returns `null` (queue empty).
///
/// For now this is a stub: it shows a check icon, the count of words
/// reviewed in the just-finished session, and a single "Back to Dashboard"
/// button. A future milestone can replace the body with stats (e.g.,
/// breakdown by rating, accuracy, time spent) without changing the route
/// shape, because the only argument the page accepts is [reviewedCount].
@RoutePage()
class LearnReviewFinishPage extends StatelessWidget {
  const LearnReviewFinishPage({super.key, required this.reviewedCount});

  /// Number of ratings applied during the session that just ended. Always
  /// `>= 0`; may be `0` only if the user opened an empty session (Dashboard
  /// guards this but the page is defensive).
  final int reviewedCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Scaffold(
      appBar: AppBar(automaticallyImplyLeading: false),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 96,
                    color: colors.primary,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Session complete!',
                    style: theme.textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$reviewedCount ${reviewedCount == 1 ? "word" : "words"} reviewed.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  FilledButton.icon(
                    onPressed: () =>
                        context.router.replaceAll([const HomeRoute()]),
                    icon: const Icon(Icons.home_outlined),
                    label: const Text('Back to Dashboard'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
