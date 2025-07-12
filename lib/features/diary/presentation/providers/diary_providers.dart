// lib/diary/presentation/providers/diary_providers.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/diary_local_datasource.dart';
import '../../data/repositories/diary_repository_impl.dart';
import '../../data/services/speech_to_text_service.dart';
import '../../data/services/text_to_speech_service.dart';
import '../../domain/entities/diary_entry.dart';
import '../../domain/repositories/diary_respository.dart';
import '../../domain/usecases/add_entry.dart';
import '../../domain/usecases/delete_entry.dart';
import '../../domain/usecases/get_all_entries.dart';
import '../../domain/usecases/update_entry.dart';
import 'diary_notifier.dart';

final titleInputProvider = StateProvider<String>((ref) => '');
final contentInputProvider = StateProvider<String>((ref) => '');
final isEditingProvider = StateProvider<bool>((ref) => false);

final titleControllerProvider = Provider.autoDispose<TextEditingController>((
  ref,
) {
  final controller = TextEditingController(text: ref.watch(titleInputProvider));
  ref.listen<String>(titleInputProvider, (prev, next) {
    if (controller.text != next) controller.text = next;
  });
  return controller;
});

final contentControllerProvider = Provider.autoDispose<TextEditingController>((
  ref,
) {
  final controller = TextEditingController(
    text: ref.watch(contentInputProvider),
  );
  ref.listen<String>(contentInputProvider, (prev, next) {
    if (controller.text != next) controller.text = next;
  });
  return controller;
});

final activeMicProvider = StateProvider<String?>((ref) => null);
// final isListeningProvider = StateProvider<bool>((ref) => false);


final isListeningProvider = StateProvider<bool>((_) => false);

final diaryLocalDataSourceProvider = Provider(
  (ref) => DiaryLocalDataSourceImpl(),
);

final diaryRepositoryProvider = Provider<DiaryRepository>((ref) {
  final localDataSource = ref.read(diaryLocalDataSourceProvider);
  return DiaryRepositoryImpl(localDataSource);
});

final addEntryProvider = Provider((ref) {
  final repo = ref.read(diaryRepositoryProvider);
  return AddEntry(repo);
});

final deleteEntryProvider = Provider((ref) {
  final repo = ref.read(diaryRepositoryProvider);
  return DeleteEntry(repo);
});

final getAllEntriesProvider = Provider((ref) {
  final repo = ref.read(diaryRepositoryProvider);
  return GetAllEntries(repo);
});

final updateEntryProvider = Provider((ref) {
  final repo = ref.read(diaryRepositoryProvider);
  return UpdateEntry(repo);
});

final diaryNotifierProvider =
    StateNotifierProvider<DiaryNotifier, List<DiaryEntry>>((ref) {
      final add = ref.read(addEntryProvider);
      final del = ref.read(deleteEntryProvider);
      final get = ref.read(getAllEntriesProvider);
      final update = ref.read(updateEntryProvider);

      return DiaryNotifier(
        addEntry: add,
        deleteEntry: del,
        getAllEntries: get,
        updateEntry: update,
      );
    });

final ttsServiceProvider = Provider((ref) => TextToSpeechService());
final speechToTextServiceProvider = Provider<SpeechToTextService>((ref) {
  return SpeechToTextService();
});
