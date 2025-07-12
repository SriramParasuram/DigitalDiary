import 'package:hive/hive.dart';
import '../../domain/entities/diary_entry.dart';

part 'diary_entry_model.g.dart';

@HiveType(typeId: 0)
class DiaryEntryModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String content;

  @HiveField(3)
  final DateTime createdAt;

  DiaryEntryModel({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
  });

  factory DiaryEntryModel.fromEntity(DiaryEntry entry) {
    return DiaryEntryModel(
      id: entry.id,
      title: entry.title,
      content: entry.content,
      createdAt: entry.createdAt,
    );
  }

  DiaryEntry toEntity() {
    return DiaryEntry(
      id: id,
      title: title,
      content: content,
      createdAt: createdAt,
    );
  }
}