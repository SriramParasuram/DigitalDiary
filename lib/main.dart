
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import 'core/app_router.dart';
import 'features/diary/data/models/diary_entry_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final appDocumentDir = await getApplicationDocumentsDirectory();
  Hive.init(appDocumentDir.path);
  Hive.registerAdapter(DiaryEntryModelAdapter());
  await Hive.openBox<DiaryEntryModel>('diary_entries');



  runApp(const ProviderScope(child: MyApp()));
}

Future<void> ensureMicPermission() async {
  final status = await Permission.microphone.status;
  if (!status.isGranted) {
    final result = await Permission.microphone.request();
    if (!result.isGranted) {
      print('[STT] Microphone permission denied by user!');
    } else {
      print('[STT] Microphone permission granted at runtime.');
    }
  }
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Digital Diary',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white,
        ),
      ),
      routerConfig: ref.read(appRouterProvider), // <-- uses Riverpod for router
    );
  }
}