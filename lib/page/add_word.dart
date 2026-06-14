import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:auto_route/annotations.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:worder/entity/word_model.dart';
import 'package:worder/service.dart';

@RoutePage()
class AddWordPage extends StatefulWidget {
  const AddWordPage({super.key});

  @override
  State<AddWordPage> createState() => _AddWordPageState();
}

class _AddWordPageState extends State<AddWordPage> {
  static const _saveErrorMessage = 'Failed to save the word';
  static const _savedMessage = 'Saved';

  late final TextEditingController _wordCtrl;
  late final TextEditingController _pinyinCtrl;
  late final TextEditingController _meaningCtrl;
  late final TextEditingController _noteCtrl;
  late final FocusNode _wordFocus;
  late final ValueNotifier<bool> _canConfirm;

  @override
  void initState() {
    super.initState();
    _wordCtrl = TextEditingController();
    _pinyinCtrl = TextEditingController();
    _meaningCtrl = TextEditingController();
    _noteCtrl = TextEditingController();
    _wordFocus = FocusNode();
    _canConfirm = ValueNotifier(false);
    _wordCtrl.addListener(_updateButtons);
    _pinyinCtrl.addListener(_updateButtons);
    _meaningCtrl.addListener(_updateButtons);
  }

  @override
  void dispose() {
    _wordCtrl.dispose();
    _pinyinCtrl.dispose();
    _meaningCtrl.dispose();
    _noteCtrl.dispose();
    _wordFocus.dispose();
    _canConfirm.dispose();
    super.dispose();
  }

  bool _isFilled(TextEditingController c) => c.text.trim().isNotEmpty;

  void _updateButtons() {
    _canConfirm.value =
        _isFilled(_wordCtrl) &&
        _isFilled(_pinyinCtrl) &&
        _isFilled(_meaningCtrl);
  }

  void _onEnhance() {
    BotToast.showText(text: 'AI Enhance unimpl: ${_wordCtrl.text.trim()}');
  }

  Future<void> _onConfirm() async {
    final dbService = context.read<WorderStorageService>();
    final result = await showOkCancelAlertDialog(
      context: context,
      title: 'Save this word?',
      message: 'A new word entry will be created.',
      okLabel: 'Save',
      cancelLabel: 'Cancel',
    );
    if (result != OkCancelResult.ok) return;
    final wordText = _wordCtrl.text.trim();
    final pinyinText = _pinyinCtrl.text.trim();
    final meaningText = _meaningCtrl.text.trim();
    final noteText = _noteCtrl.text.trim();
    final word = await WordModel.create(
      word: wordText,
      pinyin: pinyinText,
      meaning: meaningText,
      note: noteText,
    );
    try {
      await dbService.saveWord(word);
    } catch (_) {
      if (!mounted) return;
      BotToast.showText(text: _saveErrorMessage);
      return;
    }
    if (!mounted) return;
    _wordCtrl.clear();
    _pinyinCtrl.clear();
    _meaningCtrl.clear();
    _noteCtrl.clear();
    _wordFocus.requestFocus();
    BotToast.showText(text: _savedMessage);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Word')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 96, 16, 16),
        children: [
          TextField(
            controller: _wordCtrl,
            focusNode: _wordFocus,
            autofocus: true,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'Word',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _pinyinCtrl,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'Pinyin',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _meaningCtrl,
            minLines: 1,
            maxLines: null,
            textInputAction: TextInputAction.newline,
            decoration: const InputDecoration(
              labelText: 'Meaning',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _noteCtrl,
            minLines: 1,
            maxLines: null,
            textInputAction: TextInputAction.newline,
            decoration: const InputDecoration(
              labelText: 'Note (optional)',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
          child: Row(
            children: [
              Expanded(
                child: ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _wordCtrl,
                  builder: (_, value, _) => OutlinedButton.icon(
                    onPressed: value.text.trim().isNotEmpty ? _onEnhance : null,
                    icon: const Icon(Icons.auto_awesome),
                    label: const Text('AI Enhance'),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ValueListenableBuilder<bool>(
                  valueListenable: _canConfirm,
                  builder: (_, can, _) => FilledButton(
                    onPressed: can ? _onConfirm : null,
                    child: const Text('Confirm'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
