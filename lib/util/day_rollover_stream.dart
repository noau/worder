import 'dart:async';
import 'dart:ui';

import 'package:worder/util/date_format.dart';

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
      controller.add(startOfLocalDay());
    }
  }

  controller = StreamController<DateTime>(
    onListen: () {
      controller.add(startOfLocalDay());
      // 使用 distinct() 过滤掉相同的日期
      sub = Stream<DateTime>.periodic(
        tick,
        (_) => startOfLocalDay(),
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
