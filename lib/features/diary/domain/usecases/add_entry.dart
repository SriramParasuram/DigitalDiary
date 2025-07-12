import '../entities/diary_entry.dart';
import '../repositories/diary_respository.dart';


class AddEntry {
  final DiaryRepository repository;

  AddEntry(this.repository);

  Future<void> call(DiaryEntry entry) {
    return repository.addEntry(entry);
  }
}