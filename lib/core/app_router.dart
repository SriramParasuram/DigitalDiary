import 'package:digital_diary/features/diary/presentation/screens/stt_test_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../features/diary/domain/entities/diary_entry.dart';
import '../features/diary/presentation/screens/add_diary_entry_screen.dart';
import '../features/diary/presentation/screens/diary_detail_screen.dart';
import '../features/diary/presentation/screens/diary_list_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const DiaryListScreen(),
        routes: [
          GoRoute(
            path: 'add',
            name: 'add',
            builder: (context, state) =>  AddDiaryEntryScreen(),
          ),
          GoRoute(
            name: 'detail',
            path: '/detail',
            pageBuilder: (context, state) {
              final entry = state.extra as DiaryEntry;
              return MaterialPage(child: DiaryDetailScreen( entry:entry ));
            },
          ),
          // GoRoute(
          //   path: 'detail',
          //   name: 'detail',
          //   builder: (context, state) {
          //     final entry = state.extra as DiaryEntry;
          //     return DiaryDetailScreen(entry: entry);
          //   },
          // ),
        ],
      ),
    ],
  );
});