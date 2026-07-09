/// Hero 标签的来源 tab。
///
/// Worder 的 `AutoTabsScaffold`(见 `lib/page/home.dart`)把三个 tab
/// 的 widget tree 都留在 Navigator 栈里——切到 Dashboard 时 Library
/// 仍然在树中、State 保留。于是**同一 wordId 在 Library 和
/// Dashboard 两份 Hero 源会同时存在**,Flutter 的 HeroController
/// 会报 `There are multiple heroes that share the same tag within
/// a subtree` 断言。
///
/// 修法:把 Hero tag 按 push 来源的 tab 区分。卡片端硬编码各自的
/// `[WordDetailSource]`,详情页通过路由参数把同样的 `[WordDetailSource]`
/// 带到目的端,两端拼出**唯一**的 tag。
enum WordDetailSource {
  library,
  dashboard,
}

/// 构造 word 文本 Hero 标签。card 与 `_WordHeadline` 两端必须传
/// **同样的** `[source]` + `[wordId]`,否则 Hero 匹配不上。
String wordHeroTag(WordDetailSource source, String wordId) {
  return 'word-hero-${source.name}-$wordId';
}
