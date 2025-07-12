import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart';

class SimpleSttDemoScreen extends StatefulWidget {
  const SimpleSttDemoScreen({Key? key}) : super(key: key);

  @override
  State<SimpleSttDemoScreen> createState() => _SimpleSttDemoScreenState();
}

class _SimpleSttDemoScreenState extends State<SimpleSttDemoScreen> {
  final SpeechToText _speech = SpeechToText();
  bool _isListening = false;
  String _recognizedText = '';
  String _status = '';

  @override
  void initState() {
    super.initState();
    _initializeSTT();
  }

  Future<void> _initializeSTT() async {
    final micStatus = await Permission.microphone.request();
    if (!micStatus.isGranted) {
      setState(() {
        _status = 'Microphone permission denied.';
      });
      return;
    }

    final available = await _speech.initialize(
      onError: (error) {
        setState(() {
          _status = 'Error: ${error.errorMsg}';
        });
      },
      onStatus: (status) {
        debugPrint('[STT] Status: $status');
        setState(() {
          _status = status;
        });
      },
    );

    debugPrint('[STT] Initialized: $available');
    if (!available) {
      setState(() {
        _status = 'STT not available.';
      });
    }
  }

  void _toggleListening() async {
    if (_isListening) {
      _speech.stop();
      setState(() => _isListening = false);
    } else {
      _speech.listen(
        onResult: (result) {
          setState(() {
            _recognizedText = result.recognizedWords;
          });
        },
        onSoundLevelChange: (level) {
          debugPrint('[STT] Sound level: $level');
        },
        // config: SpeechConfig(
        //   localeId: 'en_US',
        //   listenMode: ListenMode.dictation,
        //   speechTimeoutMs: 60000,
        //   silenceTimeoutMs: 10000,
        // ),
      );

      setState(() => _isListening = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("STT Demo")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text("Status: $_status"),
            const SizedBox(height: 10),
            Text("Heard: $_recognizedText", style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: Icon(_isListening ? Icons.mic_off : Icons.mic),
              label: Text(_isListening ? "Stop" : "Start Listening"),
              onPressed: _toggleListening,
            ),
          ],
        ),
      ),
    );
  }
}