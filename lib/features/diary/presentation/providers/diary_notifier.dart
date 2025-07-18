import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/diary_entry.dart';
import '../../domain/usecases/add_entry.dart';
import '../../domain/usecases/delete_entry.dart';
import '../../domain/usecases/get_all_entries.dart';
import '../../domain/usecases/update_entry.dart';


class DiaryNotifier extends StateNotifier<List<DiaryEntry>> {
  final AddEntry addEntry;
  final DeleteEntry deleteEntry;
  final GetAllEntries getAllEntries;
  final UpdateEntry updateEntry;

  DiaryNotifier({
    required this.addEntry,
    required this.deleteEntry,
    required this.getAllEntries,
    required this.updateEntry,
  }) : super([]) {
    loadEntries();
  }

  Future<void> loadEntries() async {
    final entries = await getAllEntries();
    state = entries;
  }

  Future<void> addNewEntry(DiaryEntry entry) async {
    await addEntry(entry);
    loadEntries();
  }

  Future<void> deleteExistingEntry(String id) async {
    await deleteEntry(id);
    loadEntries();
  }

  Future<void> updateExistingEntry(DiaryEntry entry) async {
    await updateEntry(entry);
    loadEntries();
  }
}