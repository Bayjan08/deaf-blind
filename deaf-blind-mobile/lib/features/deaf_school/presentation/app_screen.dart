/// All screens from the Deaf School HTML prototype.
enum AppScreen {
  home,
  subjects,
  alphabetMap,
  alphabetIntro,
  alphabetPractice,
  alphabetSuccess,
  musicNotes,
  musicGame,
  pronunciation,
  mathMap,
  mathIntro,
  mathPractice,
  mathSuccess,
  flashcards,
  classLobby,
  liveclass,
  profile,
}

enum PracticeState { ready, checking, success }

enum NavTab { home, subjects, class_, profile }

NavTab navTabForScreen(AppScreen screen) {
  const subjectScreens = {
    AppScreen.subjects,
    AppScreen.alphabetMap,
    AppScreen.alphabetIntro,
    AppScreen.alphabetPractice,
    AppScreen.alphabetSuccess,
    AppScreen.musicNotes,
    AppScreen.musicGame,
    AppScreen.pronunciation,
    AppScreen.mathMap,
    AppScreen.mathIntro,
    AppScreen.mathPractice,
    AppScreen.mathSuccess,
    AppScreen.flashcards,
  };
  return switch (screen) {
    AppScreen.home => NavTab.home,
    AppScreen.classLobby => NavTab.class_,
    AppScreen.liveclass => NavTab.class_,
    AppScreen.profile => NavTab.profile,
    _ when subjectScreens.contains(screen) => NavTab.subjects,
    _ => NavTab.home,
  };
}

bool showBottomNav(AppScreen screen) =>
    screen != AppScreen.alphabetPractice &&
    screen != AppScreen.mathPractice &&
    screen != AppScreen.liveclass;

bool showAiFab(AppScreen screen) =>
    screen != AppScreen.alphabetPractice &&
    screen != AppScreen.mathPractice &&
    screen != AppScreen.liveclass;
