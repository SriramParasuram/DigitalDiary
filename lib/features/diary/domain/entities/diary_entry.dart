class DiaryEntry {
  final String id;
  final String title;
  final String content;
  final DateTime createdAt;

  const DiaryEntry({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
  });
}