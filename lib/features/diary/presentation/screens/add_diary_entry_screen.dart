import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../../domain/entities/diary_entry.dart';
import '../providers/diary_providers.dart';

class AddDiaryEntryScreen extends ConsumerStatefulWidget {
  final DiaryEntry? entry;

  const AddDiaryEntryScreen({Key? key, this.entry}) : super(key: key);

  @override
  ConsumerState<AddDiaryEntryScreen> createState() => _AddDiaryEntryScreenState();
}

class _AddDiaryEntryScreenState extends ConsumerState<AddDiaryEntryScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late stt.SpeechToText _speech;
  String? _activeMic; // 'title' or 'content' or null

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.entry?.title ?? '');
    _contentController = TextEditingController(text: widget.entry?.content ?? '');
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
      // Stop if already listening to this field
      _speech.stop();
      setState(() => _activeMic = null);
    } else {
      // Stop any current listening
      await _speech.stop();
      final available = await _speech.initialize(
        onStatus: (status) => debugPrint('[STT] Status: $status'),
        onError: (error) => debugPrint('[STT] Error: ${error.errorMsg}'),
      );

      if (!available) return;

      setState(() => _activeMic = fieldKey);

      _speech.listen(
        pauseFor: Duration(minutes: 2),
        listenFor: Duration(minutes: 5),
        onResult: (result) {
          setState(() {
            final spoken = result.recognizedWords.trim();
            if (fieldKey == 'title') {
              _titleController.text = spoken;
            } else {
              _contentController.text = spoken;
            }
          });
        },
      );
    }
  }

  void _saveEntry() async {
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
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Entry' : 'Add Entry'),
      ),
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