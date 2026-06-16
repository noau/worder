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
  final days = diff.inDays;
  if (days == 0) return 'just now';
  if (days > 0) return 'in $days day${days == 1 ? '' : 's'}';
  final overdue = -days;
  return 'overdue by $overdue day${overdue == 1 ? '' : 's'}';
}
