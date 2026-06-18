> 本项目含有使用 LLM 生成的代码或文档等内容。

# 缀字 (Worder)

> 为写作者打造的生词收藏工具。

一款面向写作者的生词收藏与复习应用。基于 FSRS 间隔重复算法帮助记忆,支持 AI 增强释义,并可对接任意 OpenAI 兼容端点(包括本地 Ollama 等模型)。所有数据本地保存,离线可用。

## 主要功能

- 📝 **添加生词**:记录词条、拼音、释义、笔记四类字段
- 🔄 **FSRS 间隔重复复习**:基于 `fsrs` 库的智能调度,到期卡片自动浮现
- 📖 **学习模式**:渐进式引入新词,与复习任务协同编排
- 📚 **词库浏览与管理**:统一列表,支持详情查看与笔记维护
- 🤖 **AI 增强释义**:可配置 OpenAI 兼容端点,支持 Ollama 等本地模型
- 🌙 **深色模式 + 多语言**:zh-Hans-CN / zh-Hant-TW / zh-Hant-HK / en 四套语言

## 支持平台

| 平台 | 状态 | 说明 |
|------|------|------|
| Android | ✅ 支持 | API 21+ |
| Windows | ✅ 支持 | x64 |

> ⚠️ 当前**不**支持 iOS / macOS / Linux / Web。

## 技术栈

| 类别 | 选型 |
|------|------|
| 框架 | Flutter (Dart ^3.10.4) |
| 本地存储 | Drift (SQLite) |
| 调度算法 | fsrs |
| LLM 客户端 | openai_dart (OpenAI 兼容) |
| 路由 | auto_route |
| 依赖注入 | provider |
| 主题 | adaptive_theme |
| Toast | bot_toast |
| 响应式布局 | responsive_framework |
| 国际化 | flutter gen-l10n |

## 构建与运行

环境要求:FluSdk ≥ 3.10.4,Dart SDK 与之匹配。

```bash
# 1. 拉取依赖
flutter pub get

# 2. 代码生成(auto_route / drift / json_serializable)
dart run build_runner build --delete-conflicting-outputs

# 3. 运行
flutter run                # 默认设备
flutter run -d windows     # Windows 桌面

# 4. 构建发布包
flutter build windows      # Windows x64
flutter build apk          # Android APK
```

开发期常用命令:

```bash
flutter analyze            # 静态分析(flutter_lints)
flutter format .           # 格式化
flutter test               # 单元测试(尚无 test/ 目录)
```

> 完整命令清单参见 [CLAUDE.md](./CLAUDE.md)。

## 国际化

本项目使用 Flutter 标准的 `flutter gen-l10n`,字符串源文件位于 `lib/l10n/`。

| Locale | 说明 | ARB 文件 |
|--------|------|---------|
| `en` | 英语(模板 / 默认回退) | `intl_en.arb` |
| `zh-Hans-CN` | 简体中文(中国大陆) | `intl_zh_Hans_CN.arb` |
| `zh-Hant-TW` | 繁体中文(台湾) | `intl_zh_Hant_TW.arb` |
| `zh-Hant-HK` | 繁体中文(香港) | `intl_zh_Hant_HK.arb` |

`intl_zh.arb` 作为通用中文兜底,目前仅覆盖 `appTitle`;未匹配到具体地区时优先使用具体变体,缺失 key 回退到英文。

**添加新语言的步骤:**

1. 在 `lib/l10n/` 下新增 `intl_<locale>.arb`(从 `intl_en.arb` 复制,只翻译 value 侧)
2. 在 `lib/main.dart` 的 `supportedLocales` 中追加对应 `Locale(...)`
3. 若该语言 `intl.DateFormat` 不内置,在 `main()` 中调用 `initializeDateFormatting(...)`
4. 运行 `flutter gen-l10n`(或 `flutter pub get` 触发)
5. 若需要本地化 Android 启动器名称,在 `android/app/src/main/res/values-<lang>/` 下添加 `strings.xml`

## AI 配置

应用使用可配置的 LLM 端点。在 **设置** 页面填写以下三项:

| 字段 | 说明 | 示例 |
|------|------|------|
| Base URL | OpenAI 兼容服务的地址 | `https://api.openai.com/v1`、`http://localhost:11434/v1`(Ollama) |
| API Key | 对应服务的密钥 | `sk-...` |
| Model Name | 模型标识 | `gpt-4o-mini`、`qwen2.5:7b` |

- 修改即时生效,300ms 防抖后自动写入 `SharedPreferences["LLM_CONFIG"]`
- 点击「测试连接」可发起最小化请求验证配置
- 服务层每次调用都重新读取最新配置(无静态缓存)

## 下载与发布

- **Windows**:维护者提供 x64 构建产物
- **Android**:维护者提供 APK;各架构(arm64-v8a / armeabi-v7a / x86_64)的支持情况以各版本 Release Notes 为准
- 其他平台或架构请按上文「构建与运行」自行构建

## 项目结构

```
lib/
├── main.dart              # 应用入口 + MultiProvider + Locale 装配
├── config.dart            # 调试标志 / 超时 / 防抖等常量
├── database.dart          # Drift AppDatabase (WordRows 表)
├── routing.dart           # auto_route 路由表
├── theme.dart             # 浅色 / 深色 / 多对比度主题
├── repository.dart        # PreferencesRepository / SchedulerRepository
├── constant/              # AI 提示词等常量
├── entity/                # 领域模型(WordModel / LLMConfig)
├── l10n/                  # gen-l10n 国际化资源
├── manager/               # 业务编排层(AIEnhancer / LearningSessionManager 等)
├── page/                  # 页面(Splash / Home / Dashboard / Library / Settings / AddWord / LearnReview ...)
├── service/               # 服务层(AIService)
├── util/                  # 工具方法(日期 / L10n / 错误本地化)
└── widget/                # 复用 UI 组件
```

## License

本项目采用 MIT 协议发布。

<!-- TODO: 待添加 LICENSE 文件后,在此处补充链接 -->