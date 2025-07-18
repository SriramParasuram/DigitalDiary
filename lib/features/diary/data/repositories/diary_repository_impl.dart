import '../../domain/entities/diary_entry.dart';
import '../../domain/repositories/diary_respository.dart';
import '../datasources/diary_local_datasource.dart';

class DiaryRepositoryImpl implements DiaryRepository {
  final DiaryLocalDataSource localDataSource;

  DiaryRepositoryImpl(this.localDataSource);

  @override
  Future<void> addEntry(DiaryEntry entry) async {
    await localDataSource.addEntry(entry);
  }

  @override
  Future<void> deleteEntry(String id) async {
    await localDataSource.deleteEntry(id);
  }

  @override
  Future<List<DiaryEntry>> getAllEntries() async {
    return await localDataSource.getAllEntries();
  }

  @override
  Future<void> updateEntry(DiaryEntry entry) async {
    await localDataSource.updateEntry(entry);
  }
}