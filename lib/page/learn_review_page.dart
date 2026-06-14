import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:worder/entity/word_model.dart';
import 'package:worder/widget/word_card.dart';

/// Placeholder page for Review / Learn sessions.
///
/// Receives a pre-fetched batch of [words] from the caller (Dashboard Review
/// or Learn button). The page itself is dumb — it does not know which kind of
/// session it's hosting, and it does not show any dialogs; the caller
/// (Dashboard) is responsible for handling empty batches.
///
/// The full session UI (card reveal, FSRS grade buttons, scheduler
/// integration) is a follow-up milestone — for now this page just renders the
/// batch so the navigation wiring is testable end-to-end.
@RoutePage()
class LearnReviewPage extends StatelessWidget {
  const LearnReviewPage({super.key, required this.words});

  final List<WordModel> words;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // TODO: pass title from caller once the real session UI lands.
      appBar: AppBar(title: const Text('Session')),
      body: words.isEmpty
          ? const Center(child: Text('No words.'))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: words.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (_, i) => WordCard(word: words[i]),
            ),
    );
  }
}