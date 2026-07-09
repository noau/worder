// 日期工具。
//
// 包含:
// - 日期格式化(formatAbsoluteDate / formatRelative)
// - local-time 的 "start of day" 算术(startOfLocalDay / startOfNextLocalDay)

import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import 'context_l10n.dart';

/// Convert a [BuildContext]'s [Locale] to the POSIX underscore form that
/// `intl.DateFormat` expects (e.g. `zh_CN`, `en_US`).
///
/// `Localizations.localeOf(context).toLanguageTag()` returns BCP47
/// (`zh-Hans-CN`); `intl.DateFormat` does NOT understand the script
/// segment, so a script-bearing tag like `zh-Hans-CN` falls back to
/// default formatting. Manual concat avoids that.
String _localeTag(BuildContext context) {
  final l = Localizations.localeOf(context);
  if (l.countryCode != null && l.countryCode!.isNotEmpty) {
    return '${l.languageCode}_${l.countryCode}';
  }
  return l.languageCode;
}

/// 将任意 [DateTime] 转为本地时区并按当前 locale 格式化为日期。
///
/// 对已经是 local time 的 [DateTime] 是 no-op;对 UTC [DateTime] 会先
/// 转换时区。参数名刻意不用 `utc`,因为函数对两种输入都正确 —— 调用方
/// 不需要先做时区分拣。
///
/// 注意:en 之外的 locale 需要在 `main()` 里先
/// `await initializeDateFormatting('<lang>_<country>')`,否则
/// `DateFormat.yMd` 会抛 / 兜底到 en 格式。0.1.0 仅 en,无需此调用。
String formatAbsoluteDate(BuildContext context, DateTime dt) {
  final l = dt.toLocal();
  return DateFormat.yMd(_localeTag(context)).format(l);
}

/// Returns the start of the local day for [source] (defaults to now).
///
/// 返回结果与时区无关:`DateTime(year, month, day)` 构造在 local time 下,
/// 等价于 "当地午夜 00:00:00" —— 命名上避免用 "midnight" 是因为跨夏令时
/// 切换日,实际时钟时刻可能不是 00:00:00(例如跳过 1 小时)。
///
/// 用于 drift 查询中"今天内"区间的下界。
DateTime startOfLocalDay([DateTime? source]) {
  final d = source ?? DateTime.now();
  return DateTime(d.year, d.month, d.day);
}

/// Returns the start of the local day after [source] (defaults to now).
///
/// 用作 drift 查询中"今天内"区间的上界 —— 与 [startOfLocalDay] 配对,
/// `isBetweenValues(start, end)` 的 half-open 区间即可覆盖整个本地日历日。
DateTime startOfNextLocalDay([DateTime? source]) {
  final d = source ?? DateTime.now();
  return DateTime(d.year, d.month, d.day + 1);
}

/// 将 UTC [DateTime] 渲染为相对时间描述,使用当前 locale 翻译。
///
/// - 同一分钟内 → `relativeNow`
/// - 同一天 → `relativeJustNow`
/// - 未来 → `relativeInDays`
/// - 过去 → `relativeOverdueDays`
///
/// [now] 参数仅用于测试入口;生产代码不传,默认取 `DateTime.now()`。
String formatRelative(BuildContext context, DateTime utc, {DateTime? now}) {
  final n = (now ?? DateTime.now()).toUtc();
  final diff = utc.difference(n);
  if (diff.inSeconds.abs() < 60) return context.l10n.relativeNow;
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
  if (days == 0) return context.l10n.relativeJustNow;
  if (days > 0) return context.l10n.relativeInDays(days);
  final overdue = -days;
  return context.l10n.relativeOverdueDays(overdue);
}
