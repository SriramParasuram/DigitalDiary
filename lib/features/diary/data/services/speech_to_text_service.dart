import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart';

final isListeningProvider = StateProvider<bool>((ref) => false);

class SpeechToTextService {
  final SpeechToText _speech = SpeechToText();

  bool get isAvailable => _speech.isAvailable;

  // Future<bool> initialize() async {
  //   final available = await _speech.initialize(
  //     onError: (error) {
  //       debugPrint('[STT] Error: ${error.errorMsg}');
  //     },
  //     onStatus: (status) {
  //       debugPrint('[STT] Status: $status');
  //     },
  //   );
  //   debugPrint('[STT] Initialized: $available');
  //   return available;
  // }


  Future<bool> initialize() async {
    // ✅ Ask permission explicitly first
    final status = await Permission.microphone.request();

    if (!status.isGranted) {
      debugPrint('[STT] Mic permission denied.');
      return false;
    }

    final available = await _speech.initialize(
      onStatus: (status) => debugPrint('[STT] Status: $status'),
      onError: (error) => debugPrint('[STT] Error: ${error.errorMsg}'),
    );

    debugPrint('[STT] Initialized: $available');
    return available;
  }

  void listen({
    required void Function(String recognizedWords) onResult,
  }) {
    print("is listen function called??");
    _speech.listen(
      onResult: (result) {
        print("any result ? $result");
        debugPrint('[STT] Recognized: ${result.recognizedWords}');
        onResult(result.recognizedWords);
      },
      listenFor: const Duration(seconds: 60),  // Extended
      pauseFor: const Duration(seconds: 10),   // Extended pause between phrases
      localeId: 'en_US',

    );
  }

  void stop() {
    _speech.stop();
    debugPrint('[STT] Listening stopped.');
  }
}