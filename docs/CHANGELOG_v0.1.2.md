## [0.1.2] - 2026-07-09

> 本次发布涵盖自 `v0.1.1` (2026-07-03) 以来的所有变更。
> This release covers all changes since `v0.1.1` (2026-07-03).

### TL;DR

本次更新新增「数据备份与恢复」功能，可在更新前导出数据库以防丢失；单词卡片新增飞入详情页的转场动画，并修复了长词长拼音下标题的拥挤问题；重复词条提示与备份界面补充了中文翻译。

*Adds backup & restore (export before updating to guard against data loss), a Hero animation from word cards into the detail page with a detail-title crowding fix on long words / pinyin, and Chinese translations for the duplicate-word prompt and backup UI.*

### 新增 / Added

- **数据备份与恢复（Backup）**：新增 zip 备份导出与恢复功能，集成在「设置」页中。导出时将整个数据库打包为 zip；恢复时会自动生成一份「恢复前安全备份」再执行还原，避免误操作导致数据丢失。新增 `lib/manager/backup_manager.dart` 与 `lib/manager/backup_exception.dart`、配套 `lib/util/backup_error_localizer.dart`，错误信息走结构化 `BackupException` → 边缘 `localizeBackupException(context, e)` 的本地化路径，与现有 `LLMException` 模式一致。
  *Added data backup and restore (Backup).* The full database can now be exported as a zip archive from the Settings page. When restoring, a pre-restore safety backup is automatically created first to prevent data loss from a misclicked restore. New `lib/manager/backup_manager.dart` + `lib/manager/backup_exception.dart` with a `lib/util/backup_error_localizer.dart` helper — errors follow a structured `BackupException` → edge `localizeBackupException(context, e)` localization path mirroring the existing `LLMException` pattern.

- **单词卡 → 详情页 Hero 转场动画（WordDetail）**：在 `LibraryWordCard` / `DashboardWordCard` 与 `WordDetailPage` 之间加入 Hero 转场动画，列表卡上的词文本会「飞入」详情页头部。新增 `lib/util/word_hero_source.dart` 中的 `WordDetailSource` 枚举与 `wordHeroTag(source, wordId)` 工具，把 Hero tag 按 push 来源 tab 做命名空间隔离——`AutoTabsScaffold` 的 IndexedStack 会同时保留 Library / Dashboard 两份 Hero 源，按 wordId 单独命名会触发 `There are multiple heroes that share the same tag within a subtree` 断言。
  *Added Hero animation from word card to detail page (WordDetail).* The word text on `LibraryWordCard` / `DashboardWordCard` now flies into the detail page header. A new `WordDetailSource` enum + `wordHeroTag(source, wordId)` helper in `lib/util/word_hero_source.dart` namespace the Hero tag by the source tab — `AutoTabsScaffold`'s IndexedStack keeps both Library and Dashboard Hero sources mounted, so a bare wordId tag would trigger a `There are multiple heroes that share the same tag within a subtree` assertion.

- **完善中英文本地化文案（l10n）**：为「重复词条提示」与「备份/恢复」相关界面补充中英文翻译，覆盖 `intl_zh.arb` / `intl_zh_Hans_CN.arb` / `intl_zh_Hant_TW.arb` / `intl_zh_Hant_HK.arb`。`intl_en.arb` 已在前述两个 feature 提交中先行补齐，本版本完成中文侧回填。
  *Added localization strings (l10n).* Translations for the duplicate-word prompt and the backup/restore UI across all Chinese ARB variants (`intl_zh.arb` / `intl_zh_Hans_CN.arb` / `intl_zh_Hant_TW.arb` / `intl_zh_Hant_HK.arb`). `intl_en.arb` was already populated by the two feature commits above; this release fills in the Chinese side.

### 修复 / Fixed

- **单词详情页头部布局对称化（WordDetail）**：在 `lib/page/word_detail_page.dart` 的 `_WordHeadline` 中将拼音置于单词之上，并对单词与拼音两侧使用对称的 `FittedBox.scaleDown` 兜底，避免之前仅单词侧降级时两侧视觉权重失衡的问题。
  *Symmetrized word detail header layout (WordDetail).* `_WordHeadline` in `lib/page/word_detail_page.dart` now places pinyin above the word and applies a symmetric `FittedBox.scaleDown` fallback to both sides — previously only the word side down-scaled, leaving the visual weight lopsided when the word was long.

### 变更 / Changed

- **新增 PR / push 构建验证流水线（CI）**：新增 `.github/workflows/ci.yml`，在每次 PR 或 push 到 `main` 时自动运行 `flutter pub get` → `dart run build_runner build` → `flutter analyze --fatal-infos` → `dart format --set-exit-if-changed lib/` 静态检查，并行触发 Android / Windows debug 构建验证，提前拦截合入前的回归与格式漂移。该 workflow 与现有的发布流水线 `build.yml`（`v*` 标签触发，产出 Release 资源）解耦，分别负责「合入前验证」与「发版打包」。
  *Added PR/push build verification pipeline (CI).* A new `.github/workflows/ci.yml` runs `flutter pub get` → `dart run build_runner build` → `flutter analyze --fatal-infos` → `dart format --set-exit-if-changed lib/` static checks plus parallel Android / Windows debug builds on every PR and push to `main`, catching regressions and formatting drift before merge. This workflow is decoupled from the existing `build.yml` release pipeline (triggered by `v*` tags, uploads Release assets) — one enforces "safe to merge", the other "safe to ship".

- **版本号提升至 `0.1.2`**：
  *App version bumped to `0.1.2`.*

### 废弃 / Deprecated

无 / None.

### 安全 / Security

无 / None.