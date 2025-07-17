import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/diary_entry.dart';
import '../providers/diary_providers.dart';

class DiaryDetailScreen extends ConsumerStatefulWidget {
  final DiaryEntry entry;
  const DiaryDetailScreen({super.key, required this.entry});

  @override
  ConsumerState<DiaryDetailScreen> createState() => _DiaryDetailScreenState();
}

class _DiaryDetailScreenState extends ConsumerState<DiaryDetailScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.entry.title);
    _contentController = TextEditingController(text: widget.entry.content);
    Future.microtask(() {
      // // Sync initial values to state providers
      ref.read(titleInputProvider.notifier).state = widget.entry.title;
      ref.read(contentInputProvider.notifier).state = widget.entry.content;
    });

  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    // ref.read(micControllerProvider.notifier).stop();
    // micController.stop();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMMM dd, yyyy – EEEE, hh:mm a').format(date);
  }

  Future<void> _toggleMic(String fieldKey) async {
    final micController = ref.read(micControllerProvider.notifier);
    final baseText = fieldKey == 'title'
        ? ref.read(titleInputProvider)
        : ref.read(contentInputProvider);

    await micController.toggleMic(
      fieldKey: fieldKey,
      baseText: baseText,
      onTextUpdate: (text) {
        if (fieldKey == 'title') {
          ref.read(titleInputProvider.notifier).state = text;
        } else {
          ref.read(contentInputProvider.notifier).state = text;
        }
      },
    );
  }

  Future<void> _toggleEditSave() async {
    final isEditing = ref.read(isEditingProvider);
    final title = ref.read(titleInputProvider).trim();
    final content = ref.read(contentInputProvider).trim();

    if (isEditing) {
      if (title.isEmpty || content.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Title and content cannot be empty')),
        );
        return;
      }

      final updatedEntry = DiaryEntry(
        id: widget.entry.id,
        title: title,
        content: content,
        createdAt: widget.entry.createdAt,
      );

      await ref.read(diaryNotifierProvider.notifier).updateExistingEntry(updatedEntry);
      ref.read(isEditingProvider.notifier).state = false;
    } else {
      ref.read(isEditingProvider.notifier).state = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = ref.watch(isEditingProvider);
    final activeMic = ref.watch(micControllerProvider);
    final titleText = ref.watch(titleInputProvider);
    final contentText = ref.watch(contentInputProvider);
    final ttsService = ref.read(ttsServiceProvider);

    _titleController.value = TextEditingValue(text: titleText);
    _contentController.value = TextEditingValue(text: contentText);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Entry Details'),
        actions: [
          IconButton(
            icon: Icon(isEditing ? Icons.save : Icons.edit),
            onPressed: _toggleEditSave,
          ),
          // if (!isEditing)
          //   IconButton(
          //     icon: const Icon(Icons.volume_up),
          //     onPressed: () => ttsService.speak(contentText),
          //   ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            isEditing
                ? Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(labelText: 'Title'),
                    onChanged: (text) =>
                    ref.read(titleInputProvider.notifier).state = text,
                  ),
                ),
                IconButton(
                  icon: Icon(
                    activeMic == 'title' ? Icons.mic : Icons.mic_none,
                    color: activeMic == 'title' ? Colors.red : null,
                  ),
                  onPressed: () => _toggleMic('title'),
                ),
              ],
            )
                : Text(
              titleText,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            Text(
              _formatDate(widget.entry.createdAt),
              style: TextStyle(color: Colors.grey[600]),
            ),
            const Divider(height: 32),
            isEditing
                ? Column(
              children: [
                TextField(
                  controller: _contentController,
                  decoration: const InputDecoration(labelText: 'Content'),
                  maxLines: 8,
                  onChanged: (text) =>
                  ref.read(contentInputProvider.notifier).state = text,
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    icon: Icon(
                      activeMic == 'content'
                          ? Icons.mic
                          : Icons.mic_none,
                      color: activeMic == 'content' ? Colors.red : null,
                    ),
                    onPressed: () => _toggleMic('content'),
                  ),
                ),
              ],
            )
                : Text(
              contentText,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}