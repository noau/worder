## [0.1.1] - 2026-07-03

> 本次发布涵盖自 `v0.1.0` (2026-06-18) 以来的所有变更。
> This release covers all changes since `v0.1.0` (2026-06-18).

### 新增 / Added

- **添加单词时检测重复词条（AddWord）**：输入"单词"字段时，应用会通过防抖查询数据库判断当前词条是否已存在；若已存在，输入框显示黄色提示文案与琥珀色警告图标，点击「AI Enhance」与「确认」时弹窗提示用户确认，避免意外重复入库。
  *Detect duplicate word entries when adding a word (AddWord).* While typing in the Word field, the app debounces a database lookup to check whether the entry already exists. If so, the field shows yellow helper text and an amber warning icon, and both **AI Enhance** and **Confirm** prompt the user for confirmation before proceeding — preventing accidental duplicates.

- **GitHub Actions 自动构建与发布流水线（CI）**：新增 `.github/workflows/build.yml`，在推送 `v*` 标签或手动触发时，自动构建 Android（按 ABI 拆分）与 Windows 发布产物，并将产物上传为 GitHub Release。
  *GitHub Actions build & release pipeline (CI).* A new workflow automatically builds Android (split-per-ABI) and Windows release artifacts on `v*` tag pushes or manual dispatch, uploads them as a GitHub Release with a per-ABI / per-platform asset layout.

- **项目添加 MIT 许可证**：仓库根目录新增 MIT License 文件，明确开源许可条款。
  *MIT License added to the project.* A MIT License file is now in the repository root, clarifying the open-source terms.

- **更新 Issue 模板**：完善 `.github/ISSUE_TEMPLATE/` 下的 Issue 模板，便于用户提交结构化的反馈与 Bug 报告。
  *Updated issue templates.* Issue templates under `.github/ISSUE_TEMPLATE/` have been refined to help users file structured feedback and bug reports.

### 修复 / Fixed

- **修复单词详情页在长词 / 长拼音下的横向溢出（WordDetail）**：在 `lib/page/word_detail_page.dart` 中引入新的 `_WordHeadline` 部件，当「词 + 拼音」在当前 `displayLarge` / `displayMedium` 字号下无法在一行内放下时，自动降级为纵向布局（词在上、拼音在下），并对单条仍超出可用宽度的拼音使用 `FittedBox.scaleDown` 兜底，彻底消除水平溢出。
  *Fixed horizontal overflow on the Word Detail page when the word or pinyin is long.* A new `_WordHeadline` widget in `lib/page/word_detail_page.dart` gracefully degrades from a single-row baseline layout to a vertical (word on top, pinyin below) layout when "word + pinyin" can't fit on one line at the current display sizes, with a `FittedBox.scaleDown` fallback for individual pieces that still overflow. No more horizontal clipping.

- **修复 Windows 构建路径检测（CI）**：兼容 `build/windows/x64/runner/Release` 与 `build/windows/runner/Release` 两种输出目录，使打包步骤在 Flutter 不同版本下都能找到产物。
  *Fixed Windows build path detection (CI).* The packaging step now correctly locates outputs under either `build/windows/x64/runner/Release` or `build/windows/runner/Release`, accommodating Flutter SDK variations.

### 变更 / Changed

- **CI 流水线重构（CI）**：移除对 `antinna/fa` Action 的引用，统一使用官方 `actions/checkout` / `actions/setup-java` / `subosito/flutter-action` / `softprops/action-gh-release`，并切换至 `main` 分支引用，降低外部依赖、提升可维护性。
  *CI pipeline refactor.* Replaced the third-party `antinna/fa` Action with first-party Actions (`actions/checkout`, `actions/setup-java`, `subosito/flutter-action`, `softprops/action-gh-release`) and switched references to `main`, reducing external dependencies and improving maintainability.

- **版本号提升至 `0.1.1`**：
  *App version bumped to `0.1.1`.*

### 废弃 / Deprecated

无 / None.

### 安全 / Security

- **添加 MIT License**：明确许可条款，便于下游使用与再分发。
  *MIT License added.* Licensing terms are now explicit, easing downstream use and redistribution.
