import 'package:flutter/material.dart';

import '../../../../core/haptics/note_patterns.dart';

class MusicNote {
  const MusicNote({
    required this.id,
    required this.name,
    required this.color,
    required this.desc,
    required this.bg,
    required this.pattern,
  });

  final String id;
  final String name;
  final Color color;
  final String desc;
  final Color bg;

  /// The note's distinct haptic "feel" — beat count/duration/intensity are
  /// what's actually perceivable (the `vibration` package only controls
  /// duration + amplitude, not real frequency), so each entry below is built
  /// to physically match its `desc`.
  final List<NotePattern> pattern;
}

const List<MusicNote> musicNotes = [
  MusicNote(
    id: 'do',
    name: 'До',
    color: Color(0xFFFF6B6B),
    desc: 'короткий низкий импульс',
    bg: Color(0xFFFFEDED),
    pattern: [
      NotePattern(name: 'do', colorHex: 0xFFFF6B6B, vibrationHz: 80, durationMs: 150, intensity: 0.6),
    ],
  ),
  MusicNote(
    id: 're',
    name: 'Ре',
    color: Color(0xFFFF9F45),
    desc: 'два мягких толчка',
    bg: Color(0xFFFFF1E3),
    pattern: [
      NotePattern(name: 're', colorHex: 0xFFFF9F45, vibrationHz: 110, durationMs: 130, intensity: 0.4),
      NotePattern(name: 're', colorHex: 0xFFFF9F45, vibrationHz: 110, durationMs: 130, intensity: 0.4),
    ],
  ),
  MusicNote(
    id: 'mi',
    name: 'Ми',
    color: Color(0xFFFFC93C),
    desc: 'ровная средняя вибрация',
    bg: Color(0xFFFFF6DE),
    pattern: [
      NotePattern(name: 'mi', colorHex: 0xFFFFC93C, vibrationHz: 140, durationMs: 420, intensity: 0.65),
    ],
  ),
  MusicNote(
    id: 'fa',
    name: 'Фа',
    color: Color(0xFF3DD68C),
    desc: 'плавная длинная волна',
    bg: Color(0xFFE3FAEE),
    pattern: [
      NotePattern(name: 'fa', colorHex: 0xFF3DD68C, vibrationHz: 70, durationMs: 700, intensity: 0.5),
    ],
  ),
  MusicNote(
    id: 'sol',
    name: 'Соль',
    color: Color(0xFF19BBD6),
    desc: 'быстрая частая дрожь',
    bg: Color(0xFFE0F7FB),
    pattern: [
      NotePattern(name: 'sol', colorHex: 0xFF19BBD6, vibrationHz: 260, durationMs: 50, intensity: 0.55),
      NotePattern(name: 'sol', colorHex: 0xFF19BBD6, vibrationHz: 260, durationMs: 50, intensity: 0.55),
      NotePattern(name: 'sol', colorHex: 0xFF19BBD6, vibrationHz: 260, durationMs: 50, intensity: 0.55),
      NotePattern(name: 'sol', colorHex: 0xFF19BBD6, vibrationHz: 260, durationMs: 50, intensity: 0.55),
      NotePattern(name: 'sol', colorHex: 0xFF19BBD6, vibrationHz: 260, durationMs: 50, intensity: 0.55),
    ],
  ),
  MusicNote(
    id: 'la',
    name: 'Ля',
    color: Color(0xFF4D8BFF),
    desc: 'тройной импульс',
    bg: Color(0xFFE8F0FF),
    pattern: [
      NotePattern(name: 'la', colorHex: 0xFF4D8BFF, vibrationHz: 170, durationMs: 140, intensity: 0.75),
      NotePattern(name: 'la', colorHex: 0xFF4D8BFF, vibrationHz: 170, durationMs: 140, intensity: 0.75),
      NotePattern(name: 'la', colorHex: 0xFF4D8BFF, vibrationHz: 170, durationMs: 140, intensity: 0.75),
    ],
  ),
  MusicNote(
    id: 'si',
    name: 'Си',
    color: Color(0xFF9C6BFF),
    desc: 'высокая короткая дрожь',
    bg: Color(0xFFF0E9FF),
    pattern: [
      NotePattern(name: 'si', colorHex: 0xFF9C6BFF, vibrationHz: 280, durationMs: 60, intensity: 0.9),
      NotePattern(name: 'si', colorHex: 0xFF9C6BFF, vibrationHz: 280, durationMs: 60, intensity: 0.9),
    ],
  ),
];

MusicNote? noteById(String? id) {
  if (id == null) return null;
  for (final n in musicNotes) {
    if (n.id == id) return n;
  }
  return null;
}
