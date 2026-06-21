import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/translation/sign_avatar_player.dart';
import '../providers/ai_translator_provider.dart';

const _guestIntroText =
    'Привет! Меня зовут ДИЛА. Я здесь, чтобы поделиться с тобой нашим '
    'проектом. Это приложение помогает глухим и слабовидящим людям общаться, '
    'учиться и познавать мир — через жесты, голос и вибрацию. Спасибо, что '
    'заглянул! Давай покажу, как это работает.';

class AiTranslatorScreen extends ConsumerStatefulWidget {
  const AiTranslatorScreen({super.key, this.initialMode = 0});

  final int initialMode;

  @override
  ConsumerState<AiTranslatorScreen> createState() => _AiTranslatorScreenState();
}

class _AiTranslatorScreenState extends ConsumerState<AiTranslatorScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _gestureController = TextEditingController();
  final _textController = TextEditingController();
  late final AudioRecorder _audioRecorder;
  final _tts = FlutterTts();
  bool _isRecording = false;
  bool _isGuestSpeaking = false;
  String? _guestText;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: widget.initialMode);
    _audioRecorder = AudioRecorder();
    _initTts();
    _tabController.addListener(() {
      // Clear translation state when switching tabs
      setState(() {});
    });
  }

  Future<void> _initTts() async {
    await _tts.setLanguage('ru-RU');
    await _tts.setSpeechRate(0.5);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);
  }

  Future<void> _playGuestIntro() async {
    setState(() {
      _guestText = _guestIntroText;
      _isGuestSpeaking = true;
    });
    await _tts.stop();
    await _tts.speak(_guestIntroText);
    if (mounted) setState(() => _isGuestSpeaking = false);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _gestureController.dispose();
    _textController.dispose();
    _audioRecorder.dispose();
    _tts.stop();
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
        // Mode 0: Voice -> Gestures, calls with andShowGestures: true
        ref.read(aiTranslatorProvider.notifier).translateSpeech(
          path, 
          andShowGestures: _tabController.index == 0,
        );
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

  void _translateText() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    ref.read(aiTranslatorProvider.notifier).translateTextToSign(text);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(aiTranslatorProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'ИИ-переводчик',
          style: AppTextStyles.style(fontSize: 22, fontWeight: FontWeight.w800),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
          tabs: const [
            Tab(text: 'Голос ➔ Жесты'),
            Tab(text: 'Жесты ➔ Текст'),
            Tab(text: 'Текст ➔ Жесты'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildVoiceToGesturesTab(state),
          _buildGesturesToTextTab(state),
          _buildTextToGesturesTab(state),
        ],
      ),
    );
  }

  Widget _buildVoiceToGesturesTab(AiTranslatorState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Recorder Button Card
          Container(
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              children: [
                GestureDetector(
                  onLongPressStart: (_) => _startRecording(),
                  onLongPressEnd: (_) => _stopRecording(),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isRecording ? AppColors.error : AppColors.primary,
                      boxShadow: [
                        BoxShadow(
                          color: (_isRecording ? AppColors.error : AppColors.primary).withValues(alpha: 0.35),
                          blurRadius: _isRecording ? 24 : 12,
                          spreadRadius: _isRecording ? 4 : 0,
                        ),
                      ],
                    ),
                    child: Icon(
                      _isRecording ? Icons.mic_rounded : Icons.mic_none_rounded,
                      size: 46,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _isRecording ? 'Запись...' : 'Удерживайте для записи',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    color: _isRecording ? AppColors.error : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Отпустите, чтобы перевести в жесты',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 20),
                TextButton.icon(
                  onPressed: _isGuestSpeaking ? null : _playGuestIntro,
                  icon: Icon(
                    _isGuestSpeaking ? Icons.volume_up_rounded : Icons.record_voice_over_rounded,
                    color: AppColors.primary,
                  ),
                  label: Text(
                    'Гостевой режим: познакомиться с ДИЛА',
                    style: AppTextStyles.style(fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
          ),
          if (_guestText != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.15), width: 2),
              ),
              child: Text(
                _guestText!,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              ),
            ),
          ],
          const SizedBox(height: 24),
          // Translation Output Section
          if (state.isLoading)
            const Center(child: Padding(padding: EdgeInsets.all(32.0), child: CircularProgressIndicator()))
          else ...[
            if (state.resultText.isNotEmpty) ...[
              Text(
                'Распознанный текст:',
                style: AppTextStyles.style(fontSize: 16, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  state.resultText,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                ),
              ),
              const SizedBox(height: 24),
            ],
            if (state.animationIds.isNotEmpty) ...[
              Text(
                'Показ аватаром:',
                style: AppTextStyles.style(fontSize: 16, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 8),
              SignAvatarPlayer(animationIds: state.animationIds),
            ],
          ]
        ],
      ),
    );
  }

  Widget _buildGesturesToTextTab(AiTranslatorState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _gestureController,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                  decoration: InputDecoration(
                    labelText: 'Введите жесты через запятую',
                    labelStyle: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w700),
                    hintText: 'я, хотеть, кушать',
                    hintStyle: TextStyle(color: AppColors.textTertiary.withValues(alpha: 0.6)),
                    filled: true,
                    fillColor: AppColors.background,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: state.isLoading ? null : _translateGestures,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Перевести жесты в текст',
                    style: AppTextStyles.style(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          if (state.isLoading)
            const Center(child: Padding(padding: EdgeInsets.all(32.0), child: CircularProgressIndicator()))
          else if (state.resultText.isNotEmpty) ...[
            Text(
              'Связное предложение:',
              style: AppTextStyles.style(fontSize: 16, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.1), width: 2),
              ),
              child: Text(
                state.resultText,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.primary),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTextToGesturesTab(AiTranslatorState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _textController,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                  decoration: InputDecoration(
                    labelText: 'Введите предложение на русском',
                    labelStyle: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w700),
                    hintText: 'Я хочу кушать',
                    hintStyle: TextStyle(color: AppColors.textTertiary.withValues(alpha: 0.6)),
                    filled: true,
                    fillColor: AppColors.background,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: state.isLoading ? null : _translateText,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Перевести в жесты',
                    style: AppTextStyles.style(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          if (state.isLoading)
            const Center(child: Padding(padding: EdgeInsets.all(32.0), child: CircularProgressIndicator()))
          else if (state.animationIds.isNotEmpty) ...[
            Text(
              'Показ аватаром:',
              style: AppTextStyles.style(fontSize: 16, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            SignAvatarPlayer(animationIds: state.animationIds),
          ],
        ],
      ),
    );
  }
}
