// 日期格式化工具。
//
// 与 `dashboard_page.dart` 内私有的 `_formatDate` 输出格式一致
// (`YYYY/MM/DD`,UTC 转为本地时区,月日补零),便于在详情页等位置复用。

/// 将 UTC [DateTime] 转为本地时区并格式化为 `YYYY/MM/DD`。
String formatAbsoluteDate(DateTime utc) {
  final l = utc.toLocal();
  final m = l.month.toString().padLeft(2, '0');
  final d = l.day.toString().padLeft(2, '0');
  return '${l.year}/$m/$d';
}

/// 将 UTC [DateTime] 渲染为相对时间描述。
///
/// - 同一分钟内 → `'now'`
/// - 同一天 → `'just now'`
/// - 未来 → `'in N day(s)'`
/// - 过去 → `'overdue by N day(s)'`
///
/// [now] 参数仅用于测试入口;生产代码不传,默认取 `DateTime.now()`。
String formatRelative(DateTime utc, {DateTime? now}) {
  final n = (now ?? DateTime.now()).toUtc();
  final diff = utc.difference(n);
  if (diff.inSeconds.abs() < 60) return 'now';
  // FIXME(review#6): Duration.inDays 只返回整天数。duration 落在 (−24h, 0)
  // 或 (0, +24h) 时都被折叠成 days == 0 → 'just now'。结果:一张 23h overdue
  // 的卡片显示 "just now" 而不是 "overdue by 1 day",23h 后的新 due 也只
  // 显示 "just now" 而不是 "in 1 day"。FSRS 调度可视化的 overdue 信号被吞掉。
  //
  // 修复方案:把 "just now" 的语义收紧到 <1h,大于 1h 的 sub-day 部分
  // 应该显示 "in N hours" / "overdue by N hours";或者把 cutoff 从
  // 24h 改为 (24h − 1min) 让 23h59m 算 1 day。语义取决于你想表达什么
  // —— "just now" 应该非常短(< 几小时),还是"同日"(< 24h)。
  final days = diff.inDays;
  if (days == 0) return 'just now';
  if (days > 0) return 'in $days day${days == 1 ? '' : 's'}';
  final overdue = -days;
  return 'overdue by $overdue day${overdue == 1 ? '' : 's'}';
}
