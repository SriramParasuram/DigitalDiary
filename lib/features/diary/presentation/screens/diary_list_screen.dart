import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../providers/diary_providers.dart';

class DiaryListScreen extends ConsumerStatefulWidget {
  const DiaryListScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<DiaryListScreen> createState() => _DiaryListScreenState();
}

class _DiaryListScreenState extends ConsumerState<DiaryListScreen> {
  String _formatDate(DateTime date) {
    return DateFormat('MMMM dd, yyyy – EEEE, hh:mm a').format(date);
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, int index) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Entry'),
        content: const Text('Are you sure you want to delete this diary entry?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final entry = ref.read(diaryNotifierProvider)[index];
              ref.read(diaryNotifierProvider.notifier).deleteExistingEntry(entry.id);
              Navigator.of(context).pop();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final diaryEntries = ref.watch(diaryNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Digital Notes')),
      body: diaryEntries.isEmpty
          ? const Center(child: Text("No entries yet. Tap + to add one!"))
          : ListView.separated(
        itemCount: diaryEntries.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final entry = diaryEntries[index];
          return ListTile(
            title: Text(entry.title),
            subtitle: Text(_formatDate(entry.createdAt)),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              onPressed: () => _confirmDelete(context, ref, index),
            ),
            // onTap: () => context.pushNamed('detail', extra: entry),
            onTap: () => context.pushNamed('detail', extra: entry),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.pushNamed('add'),
        child: const Icon(Icons.add),
      ),
    );
  }
}