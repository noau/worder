import 'dart:async';
import 'dart:ui';

// FIXME(review#8): 这个 _todayLocalMidnight 与 lib/database.dart:15 字节级
// 重复。两份独立副本,任何时区/语义改动需同步两处。
//
// 修复方案:把 todayLocalMidnight() 暴露为 lib/util/date_format.dart 的 public
// helper,database.dart 和 day_rollover_stream.dart 都改为 import 公共版本。
DateTime _todayLocalMidnight() {
  final n = DateTime.now();
  return DateTime(n.year, n.month, n.day);
}

class DayRolloverNotifier {
  final Stream<DateTime> stream;
  final VoidCallback triggerCheck;

  DayRolloverNotifier({required this.stream, required this.triggerCheck});
}

DayRolloverNotifier dayRolloverNotifier({
  Duration tick = const Duration(minutes: 1),
}) {
  late StreamController<DateTime> controller;
  StreamSubscription<DateTime>? sub;

  void pushCurrentDate() {
    if (!controller.isClosed) {
      controller.add(_todayLocalMidnight());
    }
  }

  controller = StreamController<DateTime>(
    onListen: () {
      controller.add(_todayLocalMidnight());
      // 使用 distinct() 过滤掉相同的日期
      sub = Stream<DateTime>.periodic(
        tick,
        (_) => _todayLocalMidnight(),
      ).distinct().listen(controller.add, onError: controller.addError);
    },
    onCancel: () async {
      await sub?.cancel();
      sub = null;
    },
  );

  return DayRolloverNotifier(
    // 关键：在总输出流上也加上 distinct，因为定时器和手动触发可能会产生重复的当天日期
    stream: controller.stream.distinct(),
    triggerCheck: pushCurrentDate, // 暴露给外部的手动触发函数
  );
}
