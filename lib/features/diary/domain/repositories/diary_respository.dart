import '../entities/diary_entry.dart';

abstract class DiaryRepository {
  Future<void> addEntry(DiaryEntry entry);
  Future<void> deleteEntry(String id);
  Future<void> updateEntry(DiaryEntry entry);
  Future<List<DiaryEntry>> getAllEntries();
}