import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../../domain/entities/diary_entry.dart';
import '../providers/diary_providers.dart';

class AddDiaryEntryScreen extends ConsumerStatefulWidget {
  final DiaryEntry? entry;

  const AddDiaryEntryScreen({Key? key, this.entry}) : super(key: key);

  @override
  ConsumerState<AddDiaryEntryScreen> createState() =>
      _AddDiaryEntryScreenState();
}

class _AddDiaryEntryScreenState extends ConsumerState<AddDiaryEntryScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late stt.SpeechToText _speech;
  String? _activeMic;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.entry?.title ?? '');
    _contentController = TextEditingController(
      text: widget.entry?.content ?? '',
    );
    _speech = stt.SpeechToText();
    _activeMic = null;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _speech.stop();
    super.dispose();
  }

  Future<void> _toggleMic(String fieldKey) async {
    if (_activeMic == fieldKey) {
      await _speech.stop();
      if (mounted) setState(() => _activeMic = null);
    } else {
      await _speech.stop();
      await Future.delayed(const Duration(milliseconds: 200));

      final micStatus = await Permission.microphone.request();
      if (!micStatus.isGranted) return;

      final available = await _speech.initialize(
        onStatus: (status) {
          debugPrint('[STT] Status: $status');
          if (status == 'notListening' || status == 'done') {
            if (mounted) setState(() => _activeMic = null);
          }
        },
        onError: (error) {
          debugPrint('[STT] Error: ${error.errorMsg}');
          if (mounted) setState(() => _activeMic = null);
        },
      );

      if (!available) return;

      if (mounted) setState(() => _activeMic = fieldKey);

      final controller = fieldKey == 'title'
          ? _titleController
          : _contentController;

      final baseTextAtStart = controller.text.trim();

      // ✅ Clear any leftover buffer from previous mic session
      String lastSpoken = '';

      _speech.listen(
        pauseFor: const Duration(seconds: 4),
        listenFor: const Duration(seconds: 60),
        localeId: 'en_US',
        onResult: (result) {
          final spoken = result.recognizedWords.trim();

          if (spoken != lastSpoken &&
              spoken.isNotEmpty &&
              mounted &&
              _activeMic == fieldKey) {
            lastSpoken = spoken;
            final newText = '$baseTextAtStart $spoken'.trim();
            setState(() {
              controller.text = newText;
              controller.selection = TextSelection.collapsed(
                offset: newText.length,
              );
            });
          }
        },
      );
    }
  }

  Future<void> _saveEntry() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isEmpty || content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Title and content cannot be empty')),
      );
      return;
    }

    final isEdit = widget.entry != null;
    final entry = DiaryEntry(
      id: widget.entry?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      content: content,
      createdAt: widget.entry?.createdAt ?? DateTime.now(),
    );

    final notifier = ref.read(diaryNotifierProvider.notifier);
    if (isEdit) {
      await notifier.updateExistingEntry(entry);
    } else {
      await notifier.addNewEntry(entry);
    }

    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.entry != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Edit Entry' : 'Add Entry')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(labelText: 'Title'),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    _activeMic == 'title' ? Icons.mic : Icons.mic_none,
                    color: _activeMic == 'title' ? Colors.red : null,
                  ),
                  onPressed: () => _toggleMic('title'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextField(
                    controller: _contentController,
                    decoration: const InputDecoration(labelText: 'Content'),
                    maxLines: 8,
                  ),
                ),
                IconButton(
                  icon: Icon(
                    _activeMic == 'content' ? Icons.mic : Icons.mic_none,
                    color: _activeMic == 'content' ? Colors.red : null,
                  ),
                  onPressed: () => _toggleMic('content'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saveEntry,
              child: Text(isEdit ? 'Update' : 'Save'),
            ),
          ],
        ),
      ),
    );
  }
}