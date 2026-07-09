// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'routing.dart';

/// generated route for
/// [AddWordPage]
class AddWordRoute extends PageRouteInfo<void> {
  const AddWordRoute({List<PageRouteInfo>? children})
    : super(AddWordRoute.name, initialChildren: children);

  static const String name = 'AddWordRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const AddWordPage();
    },
  );
}

/// generated route for
/// [DashboardPage]
class DashboardRoute extends PageRouteInfo<void> {
  const DashboardRoute({List<PageRouteInfo>? children})
    : super(DashboardRoute.name, initialChildren: children);

  static const String name = 'DashboardRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const DashboardPage();
    },
  );
}

/// generated route for
/// [HomePage]
class HomeRoute extends PageRouteInfo<void> {
  const HomeRoute({List<PageRouteInfo>? children})
    : super(HomeRoute.name, initialChildren: children);

  static const String name = 'HomeRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const HomePage();
    },
  );
}

/// generated route for
/// [LearnReviewFinishPage]
class LearnReviewFinishRoute extends PageRouteInfo<LearnReviewFinishRouteArgs> {
  LearnReviewFinishRoute({
    Key? key,
    required int reviewedCount,
    List<PageRouteInfo>? children,
  }) : super(
         LearnReviewFinishRoute.name,
         args: LearnReviewFinishRouteArgs(
           key: key,
           reviewedCount: reviewedCount,
         ),
         initialChildren: children,
       );

  static const String name = 'LearnReviewFinishRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<LearnReviewFinishRouteArgs>();
      return LearnReviewFinishPage(
        key: args.key,
        reviewedCount: args.reviewedCount,
      );
    },
  );
}

class LearnReviewFinishRouteArgs {
  const LearnReviewFinishRouteArgs({this.key, required this.reviewedCount});

  final Key? key;

  final int reviewedCount;

  @override
  String toString() {
    return 'LearnReviewFinishRouteArgs{key: $key, reviewedCount: $reviewedCount}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! LearnReviewFinishRouteArgs) return false;
    return key == other.key && reviewedCount == other.reviewedCount;
  }

  @override
  int get hashCode => key.hashCode ^ reviewedCount.hashCode;
}

/// generated route for
/// [LearnReviewPage]
class LearnReviewRoute extends PageRouteInfo<LearnReviewRouteArgs> {
  LearnReviewRoute({
    Key? key,
    required List<WordModel> words,
    List<PageRouteInfo>? children,
  }) : super(
         LearnReviewRoute.name,
         args: LearnReviewRouteArgs(key: key, words: words),
         initialChildren: children,
       );

  static const String name = 'LearnReviewRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<LearnReviewRouteArgs>();
      return LearnReviewPage(key: args.key, words: args.words);
    },
  );
}

class LearnReviewRouteArgs {
  const LearnReviewRouteArgs({this.key, required this.words});

  final Key? key;

  final List<WordModel> words;

  @override
  String toString() {
    return 'LearnReviewRouteArgs{key: $key, words: $words}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! LearnReviewRouteArgs) return false;
    return key == other.key &&
        const ListEquality<WordModel>().equals(words, other.words);
  }

  @override
  int get hashCode =>
      key.hashCode ^ const ListEquality<WordModel>().hash(words);
}

/// generated route for
/// [LibraryPage]
class LibraryRoute extends PageRouteInfo<void> {
  const LibraryRoute({List<PageRouteInfo>? children})
    : super(LibraryRoute.name, initialChildren: children);

  static const String name = 'LibraryRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const LibraryPage();
    },
  );
}

/// generated route for
/// [SettingsPage]
class SettingsRoute extends PageRouteInfo<void> {
  const SettingsRoute({List<PageRouteInfo>? children})
    : super(SettingsRoute.name, initialChildren: children);

  static const String name = 'SettingsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const SettingsPage();
    },
  );
}

/// generated route for
/// [SplashPage]
class SplashRoute extends PageRouteInfo<void> {
  const SplashRoute({List<PageRouteInfo>? children})
    : super(SplashRoute.name, initialChildren: children);

  static const String name = 'SplashRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const SplashPage();
    },
  );
}

/// generated route for
/// [WordDetailPage]
class WordDetailRoute extends PageRouteInfo<WordDetailRouteArgs> {
  WordDetailRoute({
    Key? key,
    required WordModel word,
    required WordDetailSource source,
    List<PageRouteInfo>? children,
  }) : super(
         WordDetailRoute.name,
         args: WordDetailRouteArgs(key: key, word: word, source: source),
         initialChildren: children,
       );

  static const String name = 'WordDetailRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<WordDetailRouteArgs>();
      return WordDetailPage(
        key: args.key,
        word: args.word,
        source: args.source,
      );
    },
  );
}

class WordDetailRouteArgs {
  const WordDetailRouteArgs({
    this.key,
    required this.word,
    required this.source,
  });

  final Key? key;

  final WordModel word;

  final WordDetailSource source;

  @override
  String toString() {
    return 'WordDetailRouteArgs{key: $key, word: $word, source: $source}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! WordDetailRouteArgs) return false;
    return key == other.key && word == other.word && source == other.source;
  }

  @override
  int get hashCode => key.hashCode ^ word.hashCode ^ source.hashCode;
}
