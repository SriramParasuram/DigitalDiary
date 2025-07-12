import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../../domain/entities/diary_entry.dart';
import '../providers/diary_providers.dart';

class AddDiaryEntryScreen extends ConsumerStatefulWidget {
  final DiaryEntry? entry; // null = add, non-null = edit

  const AddDiaryEntryScreen({Key? key, this.entry}) : super(key: key);

  @override
  ConsumerState<AddDiaryEntryScreen> createState() => _AddDiaryEntryScreenState();
}

class _AddDiaryEntryScreenState extends ConsumerState<AddDiaryEntryScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late stt.SpeechToText _speech;
  bool _isListeningTitle = false;
  bool _isListeningContent = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.entry?.title ?? '');
    _contentController = TextEditingController(text: widget.entry?.content ?? '');
    _speech = stt.SpeechToText();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _startListening({required bool forTitle}) async {
    bool available = await _speech.initialize();
    if (available) {
      setState(() {
        if (forTitle) {
          _isListeningTitle = true;
        } else {
          _isListeningContent = true;
        }
      });

      _speech.listen(onResult: (result) {
        setState(() {
          if (forTitle) {
            _titleController.text = result.recognizedWords;
          } else {
            _contentController.text = result.recognizedWords;
          }
        });
      });
    }
  }

  void _stopListening() {
    _speech.stop();
    setState(() {
      _isListeningTitle = false;
      _isListeningContent = false;
    });
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

    if (mounted) context.pop(); // return to previous screen
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.entry != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Entry' : 'Add Entry'),
        actions: [
          IconButton(
            icon: Icon((_isListeningTitle || _isListeningContent) ? Icons.mic_off : Icons.mic),
            onPressed: () {
              if (_isListeningTitle || _isListeningContent) {
                _stopListening();
              }
            },
          )
        ],
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
                  icon: const Icon(Icons.mic_none),
                  onPressed: _isListeningTitle
                      ? _stopListening
                      : () => _startListening(forTitle: true),
                )
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
                  icon: const Icon(Icons.mic_none),
                  onPressed: _isListeningContent
                      ? _stopListening
                      : () => _startListening(forTitle: false),
                )
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