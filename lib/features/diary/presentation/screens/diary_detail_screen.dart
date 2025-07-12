import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/diary_entry.dart';
import '../providers/diary_providers.dart';
import '../../data/services/speech_to_text_service.dart';

class DiaryDetailScreen extends ConsumerStatefulWidget {
  final DiaryEntry entry;
  const DiaryDetailScreen({super.key, required this.entry});

  @override
  ConsumerState<DiaryDetailScreen> createState() => _DiaryDetailScreenState();
}

class _DiaryDetailScreenState extends ConsumerState<DiaryDetailScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late SpeechToTextService _sttService;

  bool _isEditing = false;
  String? _activeMic;

  // 🔒 These store a snapshot of existing content for safe appending
  String _existingTitle = '';
  String _existingContent = '';

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.entry.title);
    _contentController = TextEditingController(text: widget.entry.content);
    _existingTitle = widget.entry.title;
    _existingContent = widget.entry.content;
    _sttService = SpeechToTextService();
    _activeMic = null;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _sttService.stop();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMMM dd, yyyy – EEEE, hh:mm a').format(date);
  }

  // Future<void> _toggleMic(String fieldKey) async {
  //   if (_activeMic == fieldKey) {
  //     _sttService.stop();
  //     setState(() => _activeMic = null);
  //   } else {
  //     final available = await _sttService.initialize();
  //     if (!available) return;
  //
  //     setState(() => _activeMic = fieldKey);
  //
  //     //  Cache existing content safely
  //     final String baseText = fieldKey == 'title' ? _titleController.text : _contentController.text;
  //
  //     _sttService.listen(onResult: (words) {
  //       setState(() {
  //         final newText = (baseText + ' ' + words).trim();
  //         if (fieldKey == 'title') {
  //           _titleController.text = newText;
  //         } else {
  //           _contentController.text = newText;
  //         }
  //       });
  //     });
  //   }
  // }

  Future<void> _toggleMic(String fieldKey) async {
    if (_activeMic == fieldKey) {
      _sttService.stop();
      setState(() => _activeMic = null);
    } else {
      final available = await _sttService.initialize();
      if (!available) return;

      setState(() => _activeMic = fieldKey);

      final String baseText = fieldKey == 'title'
          ? _titleController.text
          : _contentController.text;

      _sttService.listen(
        onResult: (words) {
          setState(() {
            final newText = (baseText + ' ' + words).trim();
            if (fieldKey == 'title') {
              _titleController.text = newText;
            } else {
              _contentController.text = newText;
            }
          });
        },
        onStatus: (status) {
          debugPrint('[STT] Status: $status');
          if (status == 'notListening' || status == 'done') {
            setState(() => _activeMic = null);
          }
        },
        onError: (error) {
          debugPrint('[STT] Error: ${error.errorMsg}');
          setState(() => _activeMic = null);
        },
      );
    }
  }

  Future<void> _toggleEditSave() async {
    if (_isEditing) {
      final updatedTitle = _titleController.text.trim();
      final updatedContent = _contentController.text.trim();

      if (updatedTitle.isEmpty || updatedContent.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Title and content cannot be empty')),
        );
        return;
      }

      final updatedEntry = DiaryEntry(
        id: widget.entry.id,
        title: updatedTitle,
        content: updatedContent,
        createdAt: widget.entry.createdAt,
      );

      await ref.read(diaryNotifierProvider.notifier).updateExistingEntry(updatedEntry);

      setState(() {
        _isEditing = false;
        _existingTitle = updatedTitle;
        _existingContent = updatedContent;
      });
    } else {
      setState(() => _isEditing = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ttsService = ref.read(ttsServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Entry Details'),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit),
            onPressed: _toggleEditSave,
          ),
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.volume_up),
              onPressed: () => ttsService.speak(_contentController.text),
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _isEditing
                ? Row(
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
            )
                : Text(
              _titleController.text,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            Text(
              _formatDate(widget.entry.createdAt),
              style: TextStyle(color: Colors.grey[600]),
            ),
            const Divider(height: 32),
            _isEditing
                ? Column(
              children: [
                TextField(
                  controller: _contentController,
                  decoration: const InputDecoration(labelText: 'Content'),
                  maxLines: 8,
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    icon: Icon(
                      _activeMic == 'content' ? Icons.mic : Icons.mic_none,
                      color: _activeMic == 'content' ? Colors.red : null,
                    ),
                    onPressed: () => _toggleMic('content'),
                  ),
                ),
              ],
            )
                : Text(
              _contentController.text,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}