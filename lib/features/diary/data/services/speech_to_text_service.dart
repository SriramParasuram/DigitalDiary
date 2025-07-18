import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_to_text.dart';

final isListeningProvider = StateProvider<bool>((ref) => false);

class SpeechToTextService {
  final SpeechToText _speech = SpeechToText();

  bool get isAvailable => _speech.isAvailable;

  Future<bool> initialize() async {
    // ✅ Ask permission explicitly first
    final status = await Permission.microphone.request();

    if (!status.isGranted) {
      debugPrint('[STT] Mic permission denied.');
      return false;
    }

    final available = await _speech.initialize();
    debugPrint('[STT] Initialized: $available');
    return available;
  }

  void listen({
    required void Function(String recognizedWords) onResult,
    void Function(String status)? onStatus,
    void Function(SpeechRecognitionError error)? onError,
  }) {
    debugPrint("[STT] listen() called");

    // Assign global listeners before listening
    _speech.statusListener = onStatus;
    _speech.errorListener = onError;

    _speech.listen(
      onResult: (result) {
        debugPrint('[STT] Recognized: ${result.recognizedWords}');
        onResult(result.recognizedWords);
      },
      listenFor: const Duration(seconds: 60),
      pauseFor: const Duration(seconds: 10),
      localeId: 'en_US',
    );
  }

  void stop() {
    _speech.stop();
    debugPrint('[STT] Listening stopped.');
  }
}
