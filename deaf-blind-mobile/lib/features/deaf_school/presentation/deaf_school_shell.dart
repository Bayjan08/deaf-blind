import 'package:flutter/material.dart';

import '../../../core/theme/design_colors.dart';
import '../../ai_translator/presentation/screens/gesture_camera_screen.dart';
import '../../live_class/live_class.dart';
import 'models/music_note.dart';
import 'app_screen.dart';
import 'screens/alphabet_screens.dart';
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
  PracticeState _practice = PracticeState.ready;
  String? _activeNoteId;
  bool _showTranslator = false;
  String? _gamePick;
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
      _practice = PracticeState.ready;
      _activeNoteId = null;
      _gamePick = null;
    });
  }

  void _checkPractice() {
    setState(() => _practice = PracticeState.checking);
    Future.delayed(const Duration(milliseconds: 1600), () {
      if (mounted) setState(() => _practice = PracticeState.success);
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
                  onClass: () => _go(AppScreen.classLobby),
                  onProfile: () => _go(AppScreen.profile),
                ),
              ),
            if (activeNote != null)
              Positioned.fill(
                child: NoteOverlay(
                  note: activeNote,
                  onDismiss: () => setState(() => _activeNoteId = null),
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
          onAlphabetMap: () => _go(AppScreen.alphabetMap),
          onSubjects: () => _go(AppScreen.subjects),
        ),
      AppScreen.subjects => SubjectsScreen(
          onAlphabetMap: () => _go(AppScreen.alphabetMap),
          onMathMap: () => _go(AppScreen.mathMap),
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
          onNoteTap: (n) => setState(() => _activeNoteId = n.id),
          onGame: () => _go(AppScreen.musicGame),
        ),
      AppScreen.musicGame => MusicGameScreen(
          onBack: () => _go(AppScreen.musicNotes),
          gamePick: _gamePick,
          onPick: (id) => setState(() => _gamePick = id),
        ),
      AppScreen.pronunciation => PronunciationScreen(
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
      AppScreen.profile => ProfileScreen(
          onAlphabetMap: () => _go(AppScreen.alphabetMap),
        ),
    };
  }
}
