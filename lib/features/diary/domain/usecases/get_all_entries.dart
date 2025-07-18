import '../entities/diary_entry.dart';
import '../repositories/diary_respository.dart';

class GetAllEntries {
  final DiaryRepository repository;

  GetAllEntries(this.repository);

  Future<List<DiaryEntry>> call() {
    return repository.getAllEntries();
  }
}
