import 'package:flutter_riverpod/flutter_riverpod.dart';

final activeMicProvider = StateProvider<String?>((ref) => null);

final titleSpeechResultProvider = StateProvider<String>((ref) => '');

final contentSpeechResultProvider = StateProvider<String>((ref) => '');