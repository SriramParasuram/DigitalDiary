// lib/diary/application/controllers/mic_controller.dart

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/speech_to_text_service.dart';


class MicControllerNotifier extends StateNotifier<String?> {
  final Ref ref;
  final SpeechToTextService _speechService;

  MicControllerNotifier(this.ref, this._speechService) : super(null);

  Future<void> toggleMic({
    required String fieldKey,
    required String baseText,
    required void Function(String updatedText) onTextUpdate,
  }) async {
    final isSameMic = state == fieldKey;

    if (isSameMic) {
      _speechService.stop();
      state = null;
      ref.read(isListeningProvider.notifier).state = false;
      return;
    }

    final available = await _speechService.initialize();
    if (!available) return;

    state = fieldKey;
    ref.read(isListeningProvider.notifier).state = true;

    _speechService.listen(
      onResult: (words) {
        final newText = (baseText + ' ' + words).trim();
        onTextUpdate(newText);
      },
      onStatus: (status) {
        debugPrint('[STT] Status: $status');
        if (status == 'done' || status == 'notListening') {
          state = null;
          ref.read(isListeningProvider.notifier).state = false;
        }
      },
      onError: (error) {
        debugPrint('[STT] Error: ${error.errorMsg}');
        state = null;
        ref.read(isListeningProvider.notifier).state = false;
      },
    );
  }

  void stop() {
    _speechService.stop();
    state = null;
    ref.read(isListeningProvider.notifier).state = false;
  }
}