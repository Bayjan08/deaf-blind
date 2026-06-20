import 'package:flutter/material.dart';

class MusicNote {
  const MusicNote({
    required this.id,
    required this.name,
    required this.color,
    required this.desc,
    required this.bg,
  });

  final String id;
  final String name;
  final Color color;
  final String desc;
  final Color bg;
}

const List<MusicNote> musicNotes = [
  MusicNote(
    id: 'do',
    name: 'До',
    color: Color(0xFFFF6B6B),
    desc: 'короткий низкий импульс',
    bg: Color(0xFFFFEDED),
  ),
  MusicNote(
    id: 're',
    name: 'Ре',
    color: Color(0xFFFF9F45),
    desc: 'два мягких толчка',
    bg: Color(0xFFFFF1E3),
  ),
  MusicNote(
    id: 'mi',
    name: 'Ми',
    color: Color(0xFFFFC93C),
    desc: 'ровная средняя вибрация',
    bg: Color(0xFFFFF6DE),
  ),
  MusicNote(
    id: 'fa',
    name: 'Фа',
    color: Color(0xFF3DD68C),
    desc: 'плавная длинная волна',
    bg: Color(0xFFE3FAEE),
  ),
  MusicNote(
    id: 'sol',
    name: 'Соль',
    color: Color(0xFF19BBD6),
    desc: 'быстрая частая дрожь',
    bg: Color(0xFFE0F7FB),
  ),
  MusicNote(
    id: 'la',
    name: 'Ля',
    color: Color(0xFF4D8BFF),
    desc: 'тройной импульс',
    bg: Color(0xFFE8F0FF),
  ),
  MusicNote(
    id: 'si',
    name: 'Си',
    color: Color(0xFF9C6BFF),
    desc: 'высокая короткая дрожь',
    bg: Color(0xFFF0E9FF),
  ),
];

MusicNote? noteById(String? id) {
  if (id == null) return null;
  for (final n in musicNotes) {
    if (n.id == id) return n;
  }
  return null;
}

MusicNote nextNoteAfter(String id) {
  final index = musicNotes.indexWhere((n) => n.id == id);
  if (index == -1) return musicNotes.first;
  return musicNotes[(index + 1) % musicNotes.length];
}

class MusicQuizQuestion {
  const MusicQuizQuestion({
    required this.correctId,
    required this.optionIds,
  });

  final String correctId;
  final List<String> optionIds;
}

const List<MusicQuizQuestion> musicQuizQuestions = [
  MusicQuizQuestion(correctId: 'fa', optionIds: ['fa', 're', 'la', 'mi']),
  MusicQuizQuestion(correctId: 'do', optionIds: ['do', 're', 'mi', 'sol']),
  MusicQuizQuestion(correctId: 'sol', optionIds: ['fa', 'sol', 'la', 'si']),
  MusicQuizQuestion(correctId: 'la', optionIds: ['re', 'mi', 'la', 'do']),
  MusicQuizQuestion(correctId: 'si', optionIds: ['mi', 'fa', 'si', 're']),
];
