

import '../repositories/diary_respository.dart';

class DeleteEntry {
  final DiaryRepository repository;

  DeleteEntry(this.repository);

  Future<void> call(String id) {
    return repository.deleteEntry(id);
  }
}