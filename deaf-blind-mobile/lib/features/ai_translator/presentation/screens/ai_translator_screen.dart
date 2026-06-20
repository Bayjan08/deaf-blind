import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import '../providers/ai_translator_provider.dart';

class AiTranslatorScreen extends ConsumerStatefulWidget {
  const AiTranslatorScreen({super.key});

  @override
  ConsumerState<AiTranslatorScreen> createState() => _AiTranslatorScreenState();
}

class _AiTranslatorScreenState extends ConsumerState<AiTranslatorScreen> {
  final _gestureController = TextEditingController();
  late final AudioRecorder _audioRecorder;
  bool _isRecording = false;

  @override
  void initState() {
    super.initState();
    _audioRecorder = AudioRecorder();
  }

  @override
  void dispose() {
    _gestureController.dispose();
    _audioRecorder.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        final dir = await getTemporaryDirectory();
        final path = '${dir.path}/speech.wav';
        await _audioRecorder.start(const RecordConfig(encoder: AudioEncoder.wav), path: path);
        setState(() {
          _isRecording = true;
        });
      }
    } catch (e) {
      debugPrint('Error starting record: $e');
    }
  }

  Future<void> _stopRecording() async {
    try {
      final path = await _audioRecorder.stop();
      setState(() {
        _isRecording = false;
      });
      if (path != null) {
        ref.read(aiTranslatorProvider.notifier).translateSpeech(path);
      }
    } catch (e) {
      debugPrint('Error stopping record: $e');
    }
  }

  void _translateGestures() {
    final text = _gestureController.text.trim();
    if (text.isEmpty) return;
    final gestures = text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    ref.read(aiTranslatorProvider.notifier).translateGestures(gestures);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(aiTranslatorProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('AI Translator')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Voice to Text', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            GestureDetector(
              onLongPressStart: (_) => _startRecording(),
              onLongPressEnd: (_) => _stopRecording(),
              child: CircleAvatar(
                radius: 40,
                backgroundColor: _isRecording ? Colors.red : Colors.blue,
                child: Icon(
                  _isRecording ? Icons.mic : Icons.mic_none,
                  size: 40,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Center(child: Text('Hold to record, release to translate')),
            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 32),
            const Text('Gestures to Text', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
              controller: _gestureController,
              decoration: const InputDecoration(
                labelText: 'Enter gestures (comma separated)',
                hintText: 'e.g., я, хотеть, кушать',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: state.isLoading ? null : _translateGestures,
              child: const Text('Translate Gestures'),
            ),
            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 32),
            const Text('Translation Result:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            if (state.isLoading)
              const Center(child: CircularProgressIndicator())
            else
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  state.resultText.isEmpty ? 'Waiting for input...' : state.resultText,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
