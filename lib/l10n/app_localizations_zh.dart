// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => '缀字';

  @override
  String get appSlogan => '每字一步，更近一步。';

  @override
  String get navDashboard => '主页';

  @override
  String get navLibrary => '词库';

  @override
  String get navSettings => '设置';

  @override
  String get navNewWordTooltip => '新建单词';

  @override
  String get dashboardSlogan => '每字一步，更近一步。';

  @override
  String dashboardDayCounter(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '第 $days 天',
      one: '第一天',
      zero: '刚开始',
    );
    return '$_temp0';
  }

  @override
  String get dashboardStatNeedToReview => '待复习';

  @override
  String get dashboardStatReviewedToday => '今日已复习';

  @override
  String get dashboardReviewButton => '复习';

  @override
  String get dashboardLearnButton => '学习';

  @override
  String get dashboardRecentlyReviewed => '最近复习';

  @override
  String get dashboardErrorCouldNotLoadReviewStatus => '无法加载复习状态';

  @override
  String get dashboardErrorCouldNotLoadLearningWords => '无法加载待学习单词';

  @override
  String get dashboardErrorCouldNotLoadReviewWords => '无法加载待复习单词';

  @override
  String get dashboardErrorCouldNotLoadRecentReviews => '无法加载最近复习记录。';

  @override
  String get dashboardEmptyNoReviewedYet => '还没有复习过的单词。';

  @override
  String get dashboardDialogReviewFirstTitle => '还有单词待复习';

  @override
  String dashboardDialogReviewFirstMessage(int dueCount) {
    String _temp0 = intl.Intl.pluralLogic(
      dueCount,
      locale: localeName,
      other: '个单词待复习',
      one: '个单词待复习',
    );
    return '$dueCount $_temp0。先复习，还是继续学习？';
  }

  @override
  String get dashboardDialogReviewFirstOk => '去复习';

  @override
  String get dashboardDialogReviewFirstCancel => '继续学习';

  @override
  String get dashboardDialogNoNewWordsTitle => '暂无新单词';

  @override
  String get dashboardDialogNoNewWordsMessage => '现在没有可学习的新单词。先去添加几个吧！';

  @override
  String get dashboardDialogAllCaughtUpTitle => '全部复习完啦！';

  @override
  String get dashboardDialogAllCaughtUpMessage => '现在没有需要复习的单词。去学几个新词吧！';

  @override
  String get addWordAppBarTitle => '新建单词';

  @override
  String get addWordFieldWord => '单词';

  @override
  String get addWordFieldPinyin => '拼音';

  @override
  String get addWordFieldMeaning => '释义';

  @override
  String get addWordFieldNote => '备注（选填）';

  @override
  String get addWordAiEnhanceButton => 'AI 增强';

  @override
  String get addWordConfirmButton => '确认';

  @override
  String get addWordSaveDialogTitle => '保存这个单词？';

  @override
  String get addWordSaveDialogMessage => '将创建一个新单词条目。';

  @override
  String get addWordSaveDialogOk => '保存';

  @override
  String get addWordSaveDialogCancel => '取消';

  @override
  String get addWordToastSaveSuccess => '已保存';

  @override
  String get addWordToastSaveError => '保存失败';

  @override
  String get addWordDuplicateWarning => 'This word is already in your library';

  @override
  String get addWordDuplicateDialogTitle => 'Duplicate Word';

  @override
  String addWordDuplicateDialogMessage(String word) {
    return 'The word \"$word\" is already in your library. Do you want to add it again?';
  }

  @override
  String get addWordDuplicateDialogOk => 'Add anyway';

  @override
  String get addWordDuplicateDialogCancel => 'Cancel';

  @override
  String get addWordEnhanceLoading => 'AI 正在增强单词信息…';

  @override
  String get addWordEnhanceErrorClose => '关闭';

  @override
  String get addWordEnhanceRegenerateTooltip => '重新生成';

  @override
  String get addWordEnhanceRestoreTooltip => '恢复原值';

  @override
  String get addWordEnhanceRegenerateAll => '全部重新生成';

  @override
  String get addWordEnhanceCancel => '取消';

  @override
  String get addWordEnhanceConfirm => '确认';

  @override
  String get libraryToastDeleteSuccess => '已删除';

  @override
  String get libraryToastDeleteError => '删除失败';

  @override
  String get libraryDialogDeleteTitle => '删除这个单词？';

  @override
  String libraryDialogDeleteMessage(String word) {
    return '「$word」将从你的词库中移除，且无法撤销。';
  }

  @override
  String get libraryDialogDeleteOk => '删除';

  @override
  String get libraryDialogDeleteCancel => '取消';

  @override
  String get libraryErrorLoadTitle => '词库加载失败';

  @override
  String get libraryErrorRetry => '重试';

  @override
  String get libraryEmptyTitle => '词库空空如也';

  @override
  String get libraryEmptyMessage => '添加第一个单词，开始你的收藏';

  @override
  String get libraryEmptyAddButton => '添加单词';

  @override
  String get libraryActionsDelete => '删除';

  @override
  String get settingsSectionTheme => '主题';

  @override
  String get settingsThemeLight => '浅色';

  @override
  String get settingsThemeDark => '深色';

  @override
  String get settingsThemeSystem => '跟随系统';

  @override
  String get settingsSectionAiConfig => 'AI 配置';

  @override
  String get settingsAiConfigDescription => '仅支持 OpenAI 兼容接口。';

  @override
  String get settingsFieldBaseUrl => 'Base URL';

  @override
  String get settingsFieldApiKey => 'API Key';

  @override
  String get settingsFieldApiKeyHelper => '已隐藏以保护隐私';

  @override
  String get settingsFieldModel => '模型';

  @override
  String get settingsTestButton => '测试';

  @override
  String get settingsToastSaveError => '保存设置失败';

  @override
  String get settingsToastTestSuccess => '连接成功';

  @override
  String get settingsToastTestUnexpectedError => '测试失败：发生未知错误';

  @override
  String learnHeaderProgressCounter(int reviewed, int total) {
    return '$reviewed / $total';
  }

  @override
  String get learnBackTooltip => '退出本轮';

  @override
  String get learnRevealButton => '揭晓';

  @override
  String get learnRatingAgain => '重来';

  @override
  String get learnRatingHard => '困难';

  @override
  String get learnRatingGood => '良好';

  @override
  String get learnRatingEasy => '简单';

  @override
  String get learnToastRateError => '评分记录失败';

  @override
  String get learnDialogQuitTitle => '退出本轮？';

  @override
  String get learnDialogQuitMessage => '已复习的单词已保存。剩余队列将丢失。';

  @override
  String get learnDialogQuitOk => '退出';

  @override
  String get learnDialogQuitCancel => '继续';

  @override
  String get sessionCompleteTitle => '本轮完成！';

  @override
  String sessionCompleteCounter(int reviewedCount) {
    String _temp0 = intl.Intl.pluralLogic(
      reviewedCount,
      locale: localeName,
      other: '个单词已复习。',
      one: '个单词已复习。',
    );
    return '$reviewedCount $_temp0';
  }

  @override
  String get sessionCompleteBack => '返回主页';

  @override
  String get wordDetailSectionStats => '记忆数据';

  @override
  String get wordDetailSectionNotes => '笔记';

  @override
  String get wordDetailFabTooltip => '新建笔记';

  @override
  String get wordDetailTimelineCreated => '创建时间';

  @override
  String get wordDetailTimelineLastReview => '上次复习';

  @override
  String get wordDetailTimelineLastReviewNever => '从未复习';

  @override
  String get wordDetailTimelineNextDue => '下次复习';

  @override
  String get wordDetailMemoryRecall => '回忆概率';

  @override
  String get wordDetailMemoryDifficulty => '难度';

  @override
  String get wordDetailMemoryStability => '稳定性';

  @override
  String get wordDetailMemoryPlaceholder => '评分后即可查看记忆数据';

  @override
  String get wordDetailNotesEmpty => '暂无笔记';

  @override
  String get wordDetailNoteEdit => '编辑';

  @override
  String get wordDetailNoteMoveToTop => '置顶';

  @override
  String get wordDetailNoteDelete => '删除';

  @override
  String get wordDetailNoteEditorHint => '写下你的笔记...';

  @override
  String get wordDetailNoteEditorCancel => '取消';

  @override
  String get wordDetailNoteEditorSave => '保存';

  @override
  String get wordDetailNoteSaveError => '保存笔记失败';

  @override
  String get aiErrorNotConfigured => 'AI 尚未配置。请先填写 Base URL、Model、API Key。';

  @override
  String get aiErrorInvalidKey => 'API Key 无效（401）。请检查密钥是否正确。';

  @override
  String aiErrorModelNotFound(String baseURL, String message) {
    return '模型不存在（404）。请检查模型名称，并确认 $baseURL 提供的是 OpenAI 兼容接口。（服务端信息：$message）';
  }

  @override
  String aiErrorRequestTimeout(int minutes) {
    return '请求超时（$minutes 分钟）。请检查 Base URL 是否可达。';
  }

  @override
  String aiErrorCannotReach(String baseURL) {
    return '无法连接 $baseURL。请检查地址和网络。';
  }

  @override
  String aiErrorGeneric(String message) {
    return 'AI 出错：$message';
  }

  @override
  String get aiErrorUnexpectedFormat => 'AI 返回的格式异常，请重试。';

  @override
  String aiErrorUnknown(String message) {
    return 'AI 未知错误：$message';
  }

  @override
  String get relativeNow => '刚刚';

  @override
  String get relativeJustNow => '今天早些时候';

  @override
  String relativeInDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '天后',
      one: '天后',
    );
    return '$days $_temp0';
  }

  @override
  String relativeOverdueDays(int overdue) {
    String _temp0 = intl.Intl.pluralLogic(
      overdue,
      locale: localeName,
      other: '天',
      one: '天',
    );
    return '已逾期 $overdue $_temp0';
  }
}

/// The translations for Chinese, as used in China, using the Han script (`zh_Hans_CN`).
class AppLocalizationsZhHansCn extends AppLocalizationsZh {
  AppLocalizationsZhHansCn() : super('zh_Hans_CN');

  @override
  String get appTitle => '缀字';

  @override
  String get appSlogan => '每字一步，更近一步。';

  @override
  String get navDashboard => '主页';

  @override
  String get navLibrary => '词库';

  @override
  String get navSettings => '设置';

  @override
  String get navNewWordTooltip => '新建单词';

  @override
  String get dashboardSlogan => '每字一步，更近一步。';

  @override
  String dashboardDayCounter(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '第 $days 天',
      one: '第一天',
      zero: '刚开始',
    );
    return '$_temp0';
  }

  @override
  String get dashboardStatNeedToReview => '待复习';

  @override
  String get dashboardStatReviewedToday => '今日已复习';

  @override
  String get dashboardReviewButton => '复习';

  @override
  String get dashboardLearnButton => '学习';

  @override
  String get dashboardRecentlyReviewed => '最近复习';

  @override
  String get dashboardErrorCouldNotLoadReviewStatus => '无法加载复习状态';

  @override
  String get dashboardErrorCouldNotLoadLearningWords => '无法加载待学习单词';

  @override
  String get dashboardErrorCouldNotLoadReviewWords => '无法加载待复习单词';

  @override
  String get dashboardErrorCouldNotLoadRecentReviews => '无法加载最近复习记录。';

  @override
  String get dashboardEmptyNoReviewedYet => '还没有复习过的单词。';

  @override
  String get dashboardDialogReviewFirstTitle => '还有单词待复习';

  @override
  String dashboardDialogReviewFirstMessage(int dueCount) {
    String _temp0 = intl.Intl.pluralLogic(
      dueCount,
      locale: localeName,
      other: '个单词待复习',
      one: '个单词待复习',
    );
    return '$dueCount $_temp0。先复习，还是继续学习？';
  }

  @override
  String get dashboardDialogReviewFirstOk => '去复习';

  @override
  String get dashboardDialogReviewFirstCancel => '继续学习';

  @override
  String get dashboardDialogNoNewWordsTitle => '暂无新单词';

  @override
  String get dashboardDialogNoNewWordsMessage => '现在没有可学习的新单词。先去添加几个吧！';

  @override
  String get dashboardDialogAllCaughtUpTitle => '全部复习完啦！';

  @override
  String get dashboardDialogAllCaughtUpMessage => '现在没有需要复习的单词。去学几个新词吧！';

  @override
  String get addWordAppBarTitle => '新建单词';

  @override
  String get addWordFieldWord => '单词';

  @override
  String get addWordFieldPinyin => '拼音';

  @override
  String get addWordFieldMeaning => '释义';

  @override
  String get addWordFieldNote => '备注（选填）';

  @override
  String get addWordAiEnhanceButton => 'AI 增强';

  @override
  String get addWordConfirmButton => '确认';

  @override
  String get addWordSaveDialogTitle => '保存这个单词？';

  @override
  String get addWordSaveDialogMessage => '将创建一个新单词条目。';

  @override
  String get addWordSaveDialogOk => '保存';

  @override
  String get addWordSaveDialogCancel => '取消';

  @override
  String get addWordToastSaveSuccess => '已保存';

  @override
  String get addWordToastSaveError => '保存失败';

  @override
  String get addWordEnhanceLoading => 'AI 正在增强单词信息…';

  @override
  String get addWordEnhanceErrorClose => '关闭';

  @override
  String get addWordEnhanceRegenerateTooltip => '重新生成';

  @override
  String get addWordEnhanceRestoreTooltip => '恢复原值';

  @override
  String get addWordEnhanceRegenerateAll => '全部重新生成';

  @override
  String get addWordEnhanceCancel => '取消';

  @override
  String get addWordEnhanceConfirm => '确认';

  @override
  String get libraryToastDeleteSuccess => '已删除';

  @override
  String get libraryToastDeleteError => '删除失败';

  @override
  String get libraryDialogDeleteTitle => '删除这个单词？';

  @override
  String libraryDialogDeleteMessage(String word) {
    return '「$word」将从你的词库中移除，且无法撤销。';
  }

  @override
  String get libraryDialogDeleteOk => '删除';

  @override
  String get libraryDialogDeleteCancel => '取消';

  @override
  String get libraryErrorLoadTitle => '词库加载失败';

  @override
  String get libraryErrorRetry => '重试';

  @override
  String get libraryEmptyTitle => '词库空空如也';

  @override
  String get libraryEmptyMessage => '添加第一个单词，开始你的收藏';

  @override
  String get libraryEmptyAddButton => '添加单词';

  @override
  String get libraryActionsDelete => '删除';

  @override
  String get settingsSectionTheme => '主题';

  @override
  String get settingsThemeLight => '浅色';

  @override
  String get settingsThemeDark => '深色';

  @override
  String get settingsThemeSystem => '跟随系统';

  @override
  String get settingsSectionAiConfig => 'AI 配置';

  @override
  String get settingsAiConfigDescription => '仅支持 OpenAI 兼容接口。';

  @override
  String get settingsFieldBaseUrl => 'Base URL';

  @override
  String get settingsFieldApiKey => 'API Key';

  @override
  String get settingsFieldApiKeyHelper => '已隐藏以保护隐私';

  @override
  String get settingsFieldModel => '模型';

  @override
  String get settingsTestButton => '测试';

  @override
  String get settingsToastSaveError => '保存设置失败';

  @override
  String get settingsToastTestSuccess => '连接成功';

  @override
  String get settingsToastTestUnexpectedError => '测试失败：发生未知错误';

  @override
  String learnHeaderProgressCounter(int reviewed, int total) {
    return '$reviewed / $total';
  }

  @override
  String get learnBackTooltip => '退出本轮';

  @override
  String get learnRevealButton => '揭晓';

  @override
  String get learnRatingAgain => '重来';

  @override
  String get learnRatingHard => '困难';

  @override
  String get learnRatingGood => '良好';

  @override
  String get learnRatingEasy => '简单';

  @override
  String get learnToastRateError => '评分记录失败';

  @override
  String get learnDialogQuitTitle => '退出本轮？';

  @override
  String get learnDialogQuitMessage => '已复习的单词已保存。剩余队列将丢失。';

  @override
  String get learnDialogQuitOk => '退出';

  @override
  String get learnDialogQuitCancel => '继续';

  @override
  String get sessionCompleteTitle => '本轮完成！';

  @override
  String sessionCompleteCounter(int reviewedCount) {
    String _temp0 = intl.Intl.pluralLogic(
      reviewedCount,
      locale: localeName,
      other: '个单词已复习。',
      one: '个单词已复习。',
    );
    return '$reviewedCount $_temp0';
  }

  @override
  String get sessionCompleteBack => '返回主页';

  @override
  String get wordDetailSectionStats => '记忆数据';

  @override
  String get wordDetailSectionNotes => '笔记';

  @override
  String get wordDetailFabTooltip => '新建笔记';

  @override
  String get wordDetailTimelineCreated => '创建时间';

  @override
  String get wordDetailTimelineLastReview => '上次复习';

  @override
  String get wordDetailTimelineLastReviewNever => '从未复习';

  @override
  String get wordDetailTimelineNextDue => '下次复习';

  @override
  String get wordDetailMemoryRecall => '回忆概率';

  @override
  String get wordDetailMemoryDifficulty => '难度';

  @override
  String get wordDetailMemoryStability => '稳定性';

  @override
  String get wordDetailMemoryPlaceholder => '评分后即可查看记忆数据';

  @override
  String get wordDetailNotesEmpty => '暂无笔记';

  @override
  String get wordDetailNoteEdit => '编辑';

  @override
  String get wordDetailNoteMoveToTop => '置顶';

  @override
  String get wordDetailNoteDelete => '删除';

  @override
  String get wordDetailNoteEditorHint => '写下你的笔记...';

  @override
  String get wordDetailNoteEditorCancel => '取消';

  @override
  String get wordDetailNoteEditorSave => '保存';

  @override
  String get wordDetailNoteSaveError => '保存笔记失败';

  @override
  String get aiErrorNotConfigured => 'AI 尚未配置。请先填写 Base URL、Model、API Key。';

  @override
  String get aiErrorInvalidKey => 'API Key 无效（401）。请检查密钥是否正确。';

  @override
  String aiErrorModelNotFound(String baseURL, String message) {
    return '模型不存在（404）。请检查模型名称，并确认 $baseURL 提供的是 OpenAI 兼容接口。（服务端信息：$message）';
  }

  @override
  String aiErrorRequestTimeout(int minutes) {
    return '请求超时（$minutes 分钟）。请检查 Base URL 是否可达。';
  }

  @override
  String aiErrorCannotReach(String baseURL) {
    return '无法连接 $baseURL。请检查地址和网络。';
  }

  @override
  String aiErrorGeneric(String message) {
    return 'AI 出错：$message';
  }

  @override
  String get aiErrorUnexpectedFormat => 'AI 返回的格式异常，请重试。';

  @override
  String aiErrorUnknown(String message) {
    return 'AI 未知错误：$message';
  }

  @override
  String get relativeNow => '刚刚';

  @override
  String get relativeJustNow => '今天早些时候';

  @override
  String relativeInDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '天后',
      one: '天后',
    );
    return '$days $_temp0';
  }

  @override
  String relativeOverdueDays(int overdue) {
    String _temp0 = intl.Intl.pluralLogic(
      overdue,
      locale: localeName,
      other: '天',
      one: '天',
    );
    return '已逾期 $overdue $_temp0';
  }
}

/// The translations for Chinese, as used in Hong Kong, using the Han script (`zh_Hant_HK`).
class AppLocalizationsZhHantHk extends AppLocalizationsZh {
  AppLocalizationsZhHantHk() : super('zh_Hant_HK');

  @override
  String get appTitle => '綴字';

  @override
  String get appSlogan => '每字一步，更近一步。';

  @override
  String get navDashboard => '主頁';

  @override
  String get navLibrary => '詞庫';

  @override
  String get navSettings => '設定';

  @override
  String get navNewWordTooltip => '新增單詞';

  @override
  String get dashboardSlogan => '每字一步，更近一步。';

  @override
  String dashboardDayCounter(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '第 $days 天',
      one: '第一天',
      zero: '剛開始',
    );
    return '$_temp0';
  }

  @override
  String get dashboardStatNeedToReview => '待複習';

  @override
  String get dashboardStatReviewedToday => '今日已複習';

  @override
  String get dashboardReviewButton => '複習';

  @override
  String get dashboardLearnButton => '學習';

  @override
  String get dashboardRecentlyReviewed => '最近複習';

  @override
  String get dashboardErrorCouldNotLoadReviewStatus => '無法載入複習狀態';

  @override
  String get dashboardErrorCouldNotLoadLearningWords => '無法載入待學習單詞';

  @override
  String get dashboardErrorCouldNotLoadReviewWords => '無法載入待複習單詞';

  @override
  String get dashboardErrorCouldNotLoadRecentReviews => '無法載入最近複習記錄。';

  @override
  String get dashboardEmptyNoReviewedYet => '還沒有複習過的單詞。';

  @override
  String get dashboardDialogReviewFirstTitle => '還有單詞待複習';

  @override
  String dashboardDialogReviewFirstMessage(int dueCount) {
    String _temp0 = intl.Intl.pluralLogic(
      dueCount,
      locale: localeName,
      other: '個單詞待複習',
      one: '個單詞待複習',
    );
    return '$dueCount $_temp0。先複習，還是繼續學習？';
  }

  @override
  String get dashboardDialogReviewFirstOk => '去複習';

  @override
  String get dashboardDialogReviewFirstCancel => '繼續學習';

  @override
  String get dashboardDialogNoNewWordsTitle => '暫無新單詞';

  @override
  String get dashboardDialogNoNewWordsMessage => '現在沒有可學習的新單詞。先去新增幾個吧！';

  @override
  String get dashboardDialogAllCaughtUpTitle => '全部複習完啦！';

  @override
  String get dashboardDialogAllCaughtUpMessage => '現在沒有需要複習的單詞。去學幾個新詞吧！';

  @override
  String get addWordAppBarTitle => '新增單詞';

  @override
  String get addWordFieldWord => '單詞';

  @override
  String get addWordFieldPinyin => '拼音';

  @override
  String get addWordFieldMeaning => '釋義';

  @override
  String get addWordFieldNote => '備註（選填）';

  @override
  String get addWordAiEnhanceButton => 'AI 增強';

  @override
  String get addWordConfirmButton => '確認';

  @override
  String get addWordSaveDialogTitle => '儲存這個單詞？';

  @override
  String get addWordSaveDialogMessage => '將建立一個新單詞條目。';

  @override
  String get addWordSaveDialogOk => '儲存';

  @override
  String get addWordSaveDialogCancel => '取消';

  @override
  String get addWordToastSaveSuccess => '已儲存';

  @override
  String get addWordToastSaveError => '儲存失敗';

  @override
  String get addWordEnhanceLoading => 'AI 正在增強單詞資訊…';

  @override
  String get addWordEnhanceErrorClose => '關閉';

  @override
  String get addWordEnhanceRegenerateTooltip => '重新產生';

  @override
  String get addWordEnhanceRestoreTooltip => '恢復原值';

  @override
  String get addWordEnhanceRegenerateAll => '全部重新產生';

  @override
  String get addWordEnhanceCancel => '取消';

  @override
  String get addWordEnhanceConfirm => '確認';

  @override
  String get libraryToastDeleteSuccess => '已刪除';

  @override
  String get libraryToastDeleteError => '刪除失敗';

  @override
  String get libraryDialogDeleteTitle => '刪除這個單詞？';

  @override
  String libraryDialogDeleteMessage(String word) {
    return '「$word」將從你的詞庫中移除，且無法撤銷。';
  }

  @override
  String get libraryDialogDeleteOk => '刪除';

  @override
  String get libraryDialogDeleteCancel => '取消';

  @override
  String get libraryErrorLoadTitle => '詞庫載入失敗';

  @override
  String get libraryErrorRetry => '重試';

  @override
  String get libraryEmptyTitle => '詞庫空空如也';

  @override
  String get libraryEmptyMessage => '新增第一個單詞，開始你的收藏';

  @override
  String get libraryEmptyAddButton => '新增單詞';

  @override
  String get libraryActionsDelete => '刪除';

  @override
  String get settingsSectionTheme => '主題';

  @override
  String get settingsThemeLight => '淺色';

  @override
  String get settingsThemeDark => '深色';

  @override
  String get settingsThemeSystem => '跟隨系統';

  @override
  String get settingsSectionAiConfig => 'AI 設定';

  @override
  String get settingsAiConfigDescription => '僅支援 OpenAI 兼容介面。';

  @override
  String get settingsFieldBaseUrl => 'Base URL';

  @override
  String get settingsFieldApiKey => 'API Key';

  @override
  String get settingsFieldApiKeyHelper => '已隱藏以保護隱私';

  @override
  String get settingsFieldModel => '模型';

  @override
  String get settingsTestButton => '測試';

  @override
  String get settingsToastSaveError => '儲存設定失敗';

  @override
  String get settingsToastTestSuccess => '連線成功';

  @override
  String get settingsToastTestUnexpectedError => '測試失敗：發生未知錯誤';

  @override
  String learnHeaderProgressCounter(int reviewed, int total) {
    return '$reviewed / $total';
  }

  @override
  String get learnBackTooltip => '退出本輪';

  @override
  String get learnRevealButton => '揭曉';

  @override
  String get learnRatingAgain => '重來';

  @override
  String get learnRatingHard => '困難';

  @override
  String get learnRatingGood => '良好';

  @override
  String get learnRatingEasy => '簡單';

  @override
  String get learnToastRateError => '評分記錄失敗';

  @override
  String get learnDialogQuitTitle => '退出本輪？';

  @override
  String get learnDialogQuitMessage => '已複習的單詞已儲存。剩餘佇列將遺失。';

  @override
  String get learnDialogQuitOk => '退出';

  @override
  String get learnDialogQuitCancel => '繼續';

  @override
  String get sessionCompleteTitle => '本輪完成！';

  @override
  String sessionCompleteCounter(int reviewedCount) {
    String _temp0 = intl.Intl.pluralLogic(
      reviewedCount,
      locale: localeName,
      other: '個單詞已複習。',
      one: '個單詞已複習。',
    );
    return '$reviewedCount $_temp0';
  }

  @override
  String get sessionCompleteBack => '返回主頁';

  @override
  String get wordDetailSectionStats => '記憶資料';

  @override
  String get wordDetailSectionNotes => '筆記';

  @override
  String get wordDetailFabTooltip => '新增筆記';

  @override
  String get wordDetailTimelineCreated => '建立時間';

  @override
  String get wordDetailTimelineLastReview => '上次複習';

  @override
  String get wordDetailTimelineLastReviewNever => '從未複習';

  @override
  String get wordDetailTimelineNextDue => '下次複習';

  @override
  String get wordDetailMemoryRecall => '回憶機率';

  @override
  String get wordDetailMemoryDifficulty => '難度';

  @override
  String get wordDetailMemoryStability => '穩定性';

  @override
  String get wordDetailMemoryPlaceholder => '評分後即可查看記憶資料';

  @override
  String get wordDetailNotesEmpty => '暫無筆記';

  @override
  String get wordDetailNoteEdit => '編輯';

  @override
  String get wordDetailNoteMoveToTop => '置頂';

  @override
  String get wordDetailNoteDelete => '刪除';

  @override
  String get wordDetailNoteEditorHint => '寫下你的筆記...';

  @override
  String get wordDetailNoteEditorCancel => '取消';

  @override
  String get wordDetailNoteEditorSave => '儲存';

  @override
  String get wordDetailNoteSaveError => '儲存筆記失敗';

  @override
  String get aiErrorNotConfigured => 'AI 尚未設定。請先填寫 Base URL、Model、API Key。';

  @override
  String get aiErrorInvalidKey => 'API Key 無效（401）。請檢查密鑰是否正確。';

  @override
  String aiErrorModelNotFound(String baseURL, String message) {
    return '模型不存在（404）。請檢查模型名稱，並確認 $baseURL 提供的是 OpenAI 兼容介面。（伺服端資訊：$message）';
  }

  @override
  String aiErrorRequestTimeout(int minutes) {
    return '請求逾時（$minutes 分鐘）。請檢查 Base URL 是否可達。';
  }

  @override
  String aiErrorCannotReach(String baseURL) {
    return '無法連線至 $baseURL。請檢查地址和網絡。';
  }

  @override
  String aiErrorGeneric(String message) {
    return 'AI 出錯：$message';
  }

  @override
  String get aiErrorUnexpectedFormat => 'AI 回傳的格式異常，請重試。';

  @override
  String aiErrorUnknown(String message) {
    return 'AI 未知錯誤：$message';
  }

  @override
  String get relativeNow => '剛剛';

  @override
  String get relativeJustNow => '今天稍早';

  @override
  String relativeInDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '天後',
      one: '天後',
    );
    return '$days $_temp0';
  }

  @override
  String relativeOverdueDays(int overdue) {
    String _temp0 = intl.Intl.pluralLogic(
      overdue,
      locale: localeName,
      other: '天',
      one: '天',
    );
    return '已逾期 $overdue $_temp0';
  }
}

/// The translations for Chinese, as used in Taiwan, using the Han script (`zh_Hant_TW`).
class AppLocalizationsZhHantTw extends AppLocalizationsZh {
  AppLocalizationsZhHantTw() : super('zh_Hant_TW');

  @override
  String get appTitle => '綴字';

  @override
  String get appSlogan => '每字一步，更近一步。';

  @override
  String get navDashboard => '主頁';

  @override
  String get navLibrary => '詞庫';

  @override
  String get navSettings => '設定';

  @override
  String get navNewWordTooltip => '新增單詞';

  @override
  String get dashboardSlogan => '每字一步，更近一步。';

  @override
  String dashboardDayCounter(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '第 $days 天',
      one: '第一天',
      zero: '剛開始',
    );
    return '$_temp0';
  }

  @override
  String get dashboardStatNeedToReview => '待複習';

  @override
  String get dashboardStatReviewedToday => '今日已複習';

  @override
  String get dashboardReviewButton => '複習';

  @override
  String get dashboardLearnButton => '學習';

  @override
  String get dashboardRecentlyReviewed => '最近複習';

  @override
  String get dashboardErrorCouldNotLoadReviewStatus => '無法載入複習狀態';

  @override
  String get dashboardErrorCouldNotLoadLearningWords => '無法載入待學習單詞';

  @override
  String get dashboardErrorCouldNotLoadReviewWords => '無法載入待複習單詞';

  @override
  String get dashboardErrorCouldNotLoadRecentReviews => '無法載入最近複習記錄。';

  @override
  String get dashboardEmptyNoReviewedYet => '還沒有複習過的單詞。';

  @override
  String get dashboardDialogReviewFirstTitle => '還有單詞待複習';

  @override
  String dashboardDialogReviewFirstMessage(int dueCount) {
    String _temp0 = intl.Intl.pluralLogic(
      dueCount,
      locale: localeName,
      other: '個單詞待複習',
      one: '個單詞待複習',
    );
    return '$dueCount $_temp0。先複習，還是繼續學習？';
  }

  @override
  String get dashboardDialogReviewFirstOk => '去複習';

  @override
  String get dashboardDialogReviewFirstCancel => '繼續學習';

  @override
  String get dashboardDialogNoNewWordsTitle => '暫無新單詞';

  @override
  String get dashboardDialogNoNewWordsMessage => '現在沒有可學習的新單詞。先去新增幾個吧！';

  @override
  String get dashboardDialogAllCaughtUpTitle => '全部複習完啦！';

  @override
  String get dashboardDialogAllCaughtUpMessage => '現在沒有需要複習的單詞。去學幾個新詞吧！';

  @override
  String get addWordAppBarTitle => '新增單詞';

  @override
  String get addWordFieldWord => '單詞';

  @override
  String get addWordFieldPinyin => '拼音';

  @override
  String get addWordFieldMeaning => '釋義';

  @override
  String get addWordFieldNote => '備註（選填）';

  @override
  String get addWordAiEnhanceButton => 'AI 增強';

  @override
  String get addWordConfirmButton => '確認';

  @override
  String get addWordSaveDialogTitle => '儲存這個單詞？';

  @override
  String get addWordSaveDialogMessage => '將建立一個新單詞條目。';

  @override
  String get addWordSaveDialogOk => '儲存';

  @override
  String get addWordSaveDialogCancel => '取消';

  @override
  String get addWordToastSaveSuccess => '已儲存';

  @override
  String get addWordToastSaveError => '儲存失敗';

  @override
  String get addWordEnhanceLoading => 'AI 正在增強單詞資訊…';

  @override
  String get addWordEnhanceErrorClose => '關閉';

  @override
  String get addWordEnhanceRegenerateTooltip => '重新產生';

  @override
  String get addWordEnhanceRestoreTooltip => '恢復原值';

  @override
  String get addWordEnhanceRegenerateAll => '全部重新產生';

  @override
  String get addWordEnhanceCancel => '取消';

  @override
  String get addWordEnhanceConfirm => '確認';

  @override
  String get libraryToastDeleteSuccess => '已刪除';

  @override
  String get libraryToastDeleteError => '刪除失敗';

  @override
  String get libraryDialogDeleteTitle => '刪除這個單詞？';

  @override
  String libraryDialogDeleteMessage(String word) {
    return '「$word」將從你的詞庫中移除，且無法撤銷。';
  }

  @override
  String get libraryDialogDeleteOk => '刪除';

  @override
  String get libraryDialogDeleteCancel => '取消';

  @override
  String get libraryErrorLoadTitle => '詞庫載入失敗';

  @override
  String get libraryErrorRetry => '重試';

  @override
  String get libraryEmptyTitle => '詞庫空空如也';

  @override
  String get libraryEmptyMessage => '新增第一個單詞，開始你的收藏';

  @override
  String get libraryEmptyAddButton => '新增單詞';

  @override
  String get libraryActionsDelete => '刪除';

  @override
  String get settingsSectionTheme => '主題';

  @override
  String get settingsThemeLight => '淺色';

  @override
  String get settingsThemeDark => '深色';

  @override
  String get settingsThemeSystem => '跟隨系統';

  @override
  String get settingsSectionAiConfig => 'AI 設定';

  @override
  String get settingsAiConfigDescription => '僅支援 OpenAI 相容介面。';

  @override
  String get settingsFieldBaseUrl => 'Base URL';

  @override
  String get settingsFieldApiKey => 'API Key';

  @override
  String get settingsFieldApiKeyHelper => '已隱藏以保護隱私';

  @override
  String get settingsFieldModel => '模型';

  @override
  String get settingsTestButton => '測試';

  @override
  String get settingsToastSaveError => '儲存設定失敗';

  @override
  String get settingsToastTestSuccess => '連線成功';

  @override
  String get settingsToastTestUnexpectedError => '測試失敗：發生未知錯誤';

  @override
  String learnHeaderProgressCounter(int reviewed, int total) {
    return '$reviewed / $total';
  }

  @override
  String get learnBackTooltip => '退出本輪';

  @override
  String get learnRevealButton => '揭曉';

  @override
  String get learnRatingAgain => '重來';

  @override
  String get learnRatingHard => '困難';

  @override
  String get learnRatingGood => '良好';

  @override
  String get learnRatingEasy => '簡單';

  @override
  String get learnToastRateError => '評分記錄失敗';

  @override
  String get learnDialogQuitTitle => '退出本輪？';

  @override
  String get learnDialogQuitMessage => '已複習的單詞已儲存。剩餘佇列將遺失。';

  @override
  String get learnDialogQuitOk => '退出';

  @override
  String get learnDialogQuitCancel => '繼續';

  @override
  String get sessionCompleteTitle => '本輪完成！';

  @override
  String sessionCompleteCounter(int reviewedCount) {
    String _temp0 = intl.Intl.pluralLogic(
      reviewedCount,
      locale: localeName,
      other: '個單詞已複習。',
      one: '個單詞已複習。',
    );
    return '$reviewedCount $_temp0';
  }

  @override
  String get sessionCompleteBack => '返回主頁';

  @override
  String get wordDetailSectionStats => '記憶資料';

  @override
  String get wordDetailSectionNotes => '筆記';

  @override
  String get wordDetailFabTooltip => '新增筆記';

  @override
  String get wordDetailTimelineCreated => '建立時間';

  @override
  String get wordDetailTimelineLastReview => '上次複習';

  @override
  String get wordDetailTimelineLastReviewNever => '從未複習';

  @override
  String get wordDetailTimelineNextDue => '下次複習';

  @override
  String get wordDetailMemoryRecall => '回憶機率';

  @override
  String get wordDetailMemoryDifficulty => '難度';

  @override
  String get wordDetailMemoryStability => '穩定性';

  @override
  String get wordDetailMemoryPlaceholder => '評分後即可查看記憶資料';

  @override
  String get wordDetailNotesEmpty => '暫無筆記';

  @override
  String get wordDetailNoteEdit => '編輯';

  @override
  String get wordDetailNoteMoveToTop => '置頂';

  @override
  String get wordDetailNoteDelete => '刪除';

  @override
  String get wordDetailNoteEditorHint => '寫下你的筆記...';

  @override
  String get wordDetailNoteEditorCancel => '取消';

  @override
  String get wordDetailNoteEditorSave => '儲存';

  @override
  String get wordDetailNoteSaveError => '儲存筆記失敗';

  @override
  String get aiErrorNotConfigured => 'AI 尚未設定。請先填寫 Base URL、Model、API Key。';

  @override
  String get aiErrorInvalidKey => 'API Key 無效（401）。請檢查密鑰是否正確。';

  @override
  String aiErrorModelNotFound(String baseURL, String message) {
    return '模型不存在（404）。請檢查模型名稱，並確認 $baseURL 提供的是 OpenAI 相容介面。（伺服端資訊：$message）';
  }

  @override
  String aiErrorRequestTimeout(int minutes) {
    return '請求逾時（$minutes 分鐘）。請檢查 Base URL 是否可達。';
  }

  @override
  String aiErrorCannotReach(String baseURL) {
    return '無法連線至 $baseURL。請檢查位址和網路。';
  }

  @override
  String aiErrorGeneric(String message) {
    return 'AI 出錯：$message';
  }

  @override
  String get aiErrorUnexpectedFormat => 'AI 回傳的格式異常，請重試。';

  @override
  String aiErrorUnknown(String message) {
    return 'AI 未知錯誤：$message';
  }

  @override
  String get relativeNow => '剛剛';

  @override
  String get relativeJustNow => '今天稍早';

  @override
  String relativeInDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '天後',
      one: '天後',
    );
    return '$days $_temp0';
  }

  @override
  String relativeOverdueDays(int overdue) {
    String _temp0 = intl.Intl.pluralLogic(
      overdue,
      locale: localeName,
      other: '天',
      one: '天',
    );
    return '已逾期 $overdue $_temp0';
  }
}
