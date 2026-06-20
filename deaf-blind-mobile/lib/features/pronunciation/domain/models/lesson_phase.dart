/// §4 Phases of a camera mouth-shape lesson (sequential, not live-overlaid).
enum LessonPhase {
  loading,
  calibrating, // capture a neutral face baseline (on-device only)
  ready, // reference shown, waiting to attempt
  cueing, // playing the haptic stress/rhythm cue
  recording, // tracking the user's attempt
  reviewing, // submitting + waiting for feedback
  result, // side-by-side comparison + directional cues
  error,
}
