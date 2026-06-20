import 'package:flutter/material.dart';

import '../../../core/theme/design_colors.dart';
import 'models/music_note.dart';
import 'app_screen.dart';
import 'screens/alphabet_screens.dart';
import 'screens/home_subjects_map.dart';
import 'screens/other_screens.dart';
import 'widgets/bottom_nav_bar.dart';
import 'widgets/overlays.dart';

/// Main shell replicating the Deaf School HTML prototype navigation and UI.
class DeafSchoolShell extends StatefulWidget {
  const DeafSchoolShell({super.key});

  @override
  State<DeafSchoolShell> createState() => _DeafSchoolShellState();
}

class _DeafSchoolShellState extends State<DeafSchoolShell> {
  AppScreen _screen = AppScreen.home;
  PracticeState _practice = PracticeState.ready;
  String? _activeNoteId;
  bool _showTranslator = false;
  String? _gamePick;
  int _gameQuestionIndex = 0;

  void _go(AppScreen screen) {
    setState(() {
      _screen = screen;
      _practice = PracticeState.ready;
      _activeNoteId = null;
      _gamePick = null;
      _gameQuestionIndex = 0;
    });
  }

  void _startMusicGame() {
    setState(() {
      _screen = AppScreen.musicGame;
      _gamePick = null;
      _gameQuestionIndex = 0;
      _activeNoteId = null;
      _practice = PracticeState.ready;
    });
  }

  void _nextGameQuestion() {
    final isLast = _gameQuestionIndex >= musicQuizQuestions.length - 1;
    if (isLast) {
      _go(AppScreen.musicNotes);
      return;
    }
    setState(() {
      _gameQuestionIndex++;
      _gamePick = null;
    });
  }

  void _openNote(MusicNote note) {
    setState(() {
      _screen = AppScreen.musicNoteDetail;
      _activeNoteId = note.id;
      _gamePick = null;
      _practice = PracticeState.ready;
    });
  }

  void _nextNote() {
    final currentId = _activeNoteId;
    if (currentId == null) return;
    setState(() => _activeNoteId = nextNoteAfter(currentId).id);
  }

  void _checkPractice() {
    setState(() => _practice = PracticeState.checking);
    Future.delayed(const Duration(milliseconds: 1600), () {
      if (mounted) setState(() => _practice = PracticeState.success);
    });
  }

  @override
  Widget build(BuildContext context) {
    final showNav = showBottomNav(_screen);
    final showFab = showAiFab(_screen);

    return Scaffold(
      backgroundColor: DesignColors.bg,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Positioned.fill(
              child: _buildScreen(),
            ),
            if (showFab)
              Positioned(
                right: 18,
                bottom: showNav ? 96 : 24,
                child: AiTranslatorFab(
                  onTap: () => setState(() => _showTranslator = true),
                ),
              ),
            if (showNav)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: DesignBottomNav(
                  activeTab: navTabForScreen(_screen),
                  onHome: () => _go(AppScreen.home),
                  onSubjects: () => _go(AppScreen.subjects),
                  onClass: () => _go(AppScreen.liveclass),
                  onProfile: () => _go(AppScreen.profile),
                ),
              ),
            if (_showTranslator)
              Positioned.fill(
                child: TranslatorOverlay(
                  onClose: () => setState(() => _showTranslator = false),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildScreen() {
    return switch (_screen) {
      AppScreen.home => HomeScreen(
          onProfile: () => _go(AppScreen.profile),
          onAlphabetMap: () => _go(AppScreen.alphabetMap),
          onSubjects: () => _go(AppScreen.subjects),
        ),
      AppScreen.subjects => SubjectsScreen(
          onAlphabetMap: () => _go(AppScreen.alphabetMap),
          onMusicNotes: () => _go(AppScreen.musicNotes),
          onPronunciation: () => _go(AppScreen.pronunciation),
        ),
      AppScreen.alphabetMap => AlphabetMapScreen(
          onBack: () => _go(AppScreen.subjects),
          onIntro: () => _go(AppScreen.alphabetIntro),
        ),
      AppScreen.alphabetIntro => AlphabetIntroScreen(
          onBack: () => _go(AppScreen.alphabetMap),
          onPractice: () => _go(AppScreen.alphabetPractice),
        ),
      AppScreen.alphabetPractice => AlphabetPracticeScreen(
          onBack: () => _go(AppScreen.alphabetIntro),
          practiceState: _practice,
          onCheck: _checkPractice,
          onSuccess: () => _go(AppScreen.alphabetSuccess),
        ),
      AppScreen.alphabetSuccess => AlphabetSuccessScreen(
          onMap: () => _go(AppScreen.alphabetMap),
          onNextLetter: () => _go(AppScreen.alphabetIntro),
        ),
      AppScreen.musicNotes => MusicNotesScreen(
          onBack: () => _go(AppScreen.subjects),
          onNoteTap: _openNote,
          onGame: _startMusicGame,
        ),
      AppScreen.musicNoteDetail => MusicNoteDetailScreen(
          note: noteById(_activeNoteId)!,
          onBack: () => _go(AppScreen.musicNotes),
          onNext: _nextNote,
        ),
      AppScreen.musicGame => MusicGameScreen(
          onBack: () => _go(AppScreen.musicNotes),
          questionIndex: _gameQuestionIndex,
          question: musicQuizQuestions[_gameQuestionIndex],
          gamePick: _gamePick,
          onPick: (id) => setState(() => _gamePick = id),
          onNext: _nextGameQuestion,
        ),
      AppScreen.pronunciation => PronunciationScreen(
          onBack: () => _go(AppScreen.subjects),
        ),
      AppScreen.liveclass => LiveClassScreen(
          onBack: () => _go(AppScreen.home),
        ),
      AppScreen.profile => ProfileScreen(
          onAlphabetMap: () => _go(AppScreen.alphabetMap),
        ),
    };
  }
}
