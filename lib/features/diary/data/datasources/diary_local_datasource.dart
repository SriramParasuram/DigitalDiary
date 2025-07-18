import 'package:hive/hive.dart';
import '../../domain/entities/diary_entry.dart';
import '../models/diary_entry_model.dart';

abstract class DiaryLocalDataSource {
  Future<void> addEntry(DiaryEntry entry);
  Future<List<DiaryEntry>> getAllEntries();
  Future<void> deleteEntry(String id);
  Future<void> updateEntry(DiaryEntry entry);
}

class DiaryLocalDataSourceImpl implements DiaryLocalDataSource {
  static const String _boxName = 'diary_entries';

  Future<Box<DiaryEntryModel>> _openBox() async {
    return await Hive.openBox<DiaryEntryModel>(_boxName);
  }

  @override
  Future<void> addEntry(DiaryEntry entry) async {
    final box = await _openBox();
    final model = DiaryEntryModel.fromEntity(entry);
    await box.put(model.id, model);
  }

  @override
  Future<List<DiaryEntry>> getAllEntries() async {
    final box = await _openBox();
    return box.values.map((e) => e.toEntity()).toList();
  }

  @override
  Future<void> deleteEntry(String id) async {
    final box = await _openBox();
    await box.delete(id);
  }

  @override
  Future<void> updateEntry(DiaryEntry entry) async {
    final box = await _openBox();
    final model = DiaryEntryModel.fromEntity(entry);
    await box.put(model.id, model); // Same as addEntry but overwrites existing
  }
}