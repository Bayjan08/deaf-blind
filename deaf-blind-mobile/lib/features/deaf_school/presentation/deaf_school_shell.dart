import 'package:flutter/material.dart';

import '../../../../pet_selection_screen.dart';
import '../../alphabet_game/presentation/screens/letter_intro_screen.dart';
import '../../../core/theme/app_colors.dart';
import '../../ai_translator/presentation/screens/gesture_camera_screen.dart';
import '../../flashcards/flashcards.dart';
import '../../live_class/live_class.dart';
import '../../pronunciation/pronunciation.dart';
import 'models/music_note.dart';
import 'app_screen.dart';
import 'screens/home_subjects_map.dart';
import 'screens/math_screens.dart';
import 'screens/other_screens.dart';
import 'models/math_content.dart';
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
  String? _activeNoteId;
  bool _showTranslator = false;
  MeetingConnection? _activeMeeting;
  String _activeMathNodeId = 'L1_N0';
  final Set<String> _mathCompletedIds = {};
  final Set<String> _mathUnlockedIds = {'L1_N0'};

  void _go(AppScreen screen) {
    setState(() {
      if (_screen == AppScreen.liveclass && screen != AppScreen.liveclass) {
        _activeMeeting = null;
      }
      _screen = screen;
      _activeNoteId = null;
    });
  }

  void _completeMathNode() {
    setState(() {
      _mathCompletedIds.add(_activeMathNodeId);
      final next = nextMathNodeId(_activeMathNodeId);
      if (next != null) _mathUnlockedIds.add(next);
      _screen = AppScreen.mathSuccess;
    });
  }

  void _openMathNode(String id) {
    setState(() {
      _activeMathNodeId = id;
      _screen = AppScreen.mathIntro;
    });
  }

  MathNode? get _activeMathNode => mathNodeById(_activeMathNodeId);

  @override
  Widget build(BuildContext context) {
    final activeNote = noteById(_activeNoteId);
    final showNav = showBottomNav(_screen);
    final showFab = showAiFab(_screen);

    return Scaffold(
      backgroundColor: AppColors.background,
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
                  onClass: () => _go(AppScreen.classLobby),
                  onProfile: () => _go(AppScreen.profile),
                ),
              ),
            if (activeNote != null)
              Positioned.fill(
                child: NoteOverlay(
                  note: activeNote,
                  onDismiss: () => setState(() => _activeNoteId = null),
                  onNext: () {
                    final idx = musicNotes.indexWhere((n) => n.id == _activeNoteId);
                    if (idx == -1 || idx + 1 >= musicNotes.length) return;
                    setState(() => _activeNoteId = musicNotes[idx + 1].id);
                  },
                ),
              ),
            if (_showTranslator)
              Positioned.fill(
                child: TranslatorOverlay(
                  onClose: () => setState(() => _showTranslator = false),
                  onGestureToText: () {
                    setState(() => _showTranslator = false);
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const GestureCameraScreen(),
                      ),
                    );
                  },
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
          onAlphabetMap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => PetSelectionScreen(
                onConfirmed: (pet) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute<void>(
                      builder: (_) => LetterIntroScreen(
                        letter: 'А',
                        word: 'Арбуз',
                        petAsset: pet.asset,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          onSubjects: () => _go(AppScreen.subjects),
        ),
      AppScreen.subjects => SubjectsScreen(
          onMathMap: () => _go(AppScreen.mathMap),
          onMusicNotes: () => _go(AppScreen.musicNotes),
          onPronunciation: () => _go(AppScreen.pronunciation),
          onFlashcards: () => _go(AppScreen.flashcards),
        ),
      AppScreen.musicNotes => MusicNotesScreen(
          onBack: () => _go(AppScreen.subjects),
          onNoteTap: (n) => setState(() => _activeNoteId = n.id),
          onGame: () => _go(AppScreen.musicGame),
        ),
      AppScreen.musicGame => MusicGameScreen(
          onBack: () => _go(AppScreen.musicNotes),
        ),
      AppScreen.pronunciation => PronunciationLessonScreen(
          onBack: () => _go(AppScreen.subjects),
        ),
      AppScreen.mathMap => MathMapScreen(
          onBack: () => _go(AppScreen.subjects),
          onNodeTap: _openMathNode,
          completedIds: _mathCompletedIds,
          unlockedIds: _mathUnlockedIds,
          currentId: _activeMathNodeId,
        ),
      AppScreen.mathIntro => MathIntroScreen(
          node: _activeMathNode!,
          onBack: () => _go(AppScreen.mathMap),
          onPractice: () => _go(AppScreen.mathPractice),
        ),
      AppScreen.mathPractice => MathPracticeScreen(
          node: _activeMathNode!,
          onBack: () => _go(AppScreen.mathIntro),
          onComplete: _completeMathNode,
        ),
      AppScreen.mathSuccess => MathSuccessScreen(
          node: _activeMathNode!,
          completedCount: _mathCompletedIds.length,
          totalCount: buildMathCatalog().length,
          onMap: () => _go(AppScreen.mathMap),
          onNext: () {
            final next = nextMathNodeId(_activeMathNodeId);
            if (next != null) _openMathNode(next);
          },
          hasNext: nextMathNodeId(_activeMathNodeId) != null,
        ),
      AppScreen.flashcards => FlashcardsScreen(
          onBack: () => _go(AppScreen.subjects),
        ),
      AppScreen.classLobby => MeetingLobbyScreen(
          onEnterMeeting: (connection) {
            setState(() {
              _activeMeeting = connection;
              _screen = AppScreen.liveclass;
            });
          },
        ),
      AppScreen.liveclass => MeetingRoomScreen(
          connection: _activeMeeting!,
          onExit: () {
            setState(() {
              _activeMeeting = null;
              _screen = AppScreen.classLobby;
            });
          },
        ),
      AppScreen.profile => const ProfileScreen(),
    };
  }
}
