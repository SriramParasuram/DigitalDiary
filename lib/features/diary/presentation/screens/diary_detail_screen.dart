// lib/diary/presentation/screens/diary_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/diary_entry.dart';
import '../providers/diary_providers.dart';

class DiaryDetailScreen extends ConsumerWidget {
  final DiaryEntry entry;
  const DiaryDetailScreen({super.key, required this.entry});

  String _formatDate(DateTime date) {
    return DateFormat('MMMM dd, yyyy – EEEE').format(date);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isEditing = ref.watch(isEditingProvider);
    final activeMic = ref.watch(activeMicProvider);
    final sttService = ref.read(speechToTextServiceProvider);
    final ttsService = ref.read(ttsServiceProvider);

    final titleController = ref.watch(titleControllerProvider);
    final contentController = ref.watch(contentControllerProvider);

    void toggleMic(String fieldKey, void Function(String) onResult) {
      final current = ref.read(activeMicProvider);
      if (current == fieldKey) {
        sttService.stop();
        ref.read(activeMicProvider.notifier).state = null;
      } else {
        ref.read(activeMicProvider.notifier).state = fieldKey;
        sttService.listen(onResult: onResult);
      }
    }

    Future<void> toggleEditSave() async {
      if (ref.read(isEditingProvider)) {
        final updatedTitle = titleController.text.trim();
        final updatedContent = contentController.text.trim();

        if (updatedTitle.isEmpty || updatedContent.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Title and content cannot be empty')),
          );
          return;
        }

        final updatedEntry = DiaryEntry(
          id: entry.id,
          title: updatedTitle,
          content: updatedContent,
          createdAt: entry.createdAt,
        );

        await ref.read(diaryNotifierProvider.notifier).updateExistingEntry(updatedEntry);
        ref.read(isEditingProvider.notifier).state = false;
      } else {
        ref.read(isEditingProvider.notifier).state = true;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Entry Details'),
        actions: [
          IconButton(
            icon: Icon(isEditing ? Icons.save : Icons.edit),
            onPressed: toggleEditSave,
          ),
          if (!isEditing)
            IconButton(
              icon: const Icon(Icons.volume_up),
              onPressed: () => ttsService.speak(entry.content),
            ),
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
                    controller: titleController,
                    decoration: const InputDecoration(labelText: 'Title'),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    activeMic == 'title' ? Icons.mic : Icons.mic_none,
                    color: activeMic == 'title' ? Colors.redAccent : null,
                  ),
                  onPressed: () => toggleMic('title', (words) {
                    titleController.text = words;
                  }),
                ),
              ],
            )
                : Text(
              entry.title,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            Text(
              _formatDate(entry.createdAt),
              style: TextStyle(color: Colors.grey[600]),
            ),
            const Divider(height: 32),
            isEditing
                ? Column(
              children: [
                TextField(
                  controller: contentController,
                  decoration: const InputDecoration(labelText: 'Content'),
                  maxLines: 8,
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    icon: Icon(
                      activeMic == 'content' ? Icons.mic : Icons.mic_none,
                      color: activeMic == 'content' ? Colors.redAccent : null,
                    ),
                    onPressed: () => toggleMic('content', (words) {
                      contentController.text = words;
                    }),
                  ),
                ),
              ],
            )
                : Text(
              entry.content,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}