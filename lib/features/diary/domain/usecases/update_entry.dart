import '../entities/diary_entry.dart';
import '../repositories/diary_respository.dart';


class UpdateEntry {
  final DiaryRepository repository;

  UpdateEntry(this.repository);

  Future<void> call(DiaryEntry entry) {
    return repository.updateEntry(entry);
  }
}