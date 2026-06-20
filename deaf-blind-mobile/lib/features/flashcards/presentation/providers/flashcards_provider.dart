import 'dart:math';

import 'package:flutter_riverpod/legacy.dart';

import '../../data/gesture_card_catalog.dart';
import '../../domain/models/gesture_card.dart';

class FlashcardsState {
  FlashcardsState({
    required this.deck,
    required this.index,
    required this.flipped,
    required this.knownIds,
  });

  final List<GestureCard> deck;
  final int index;
  final bool flipped;
  final Set<int> knownIds;

  bool get isFinished => index >= deck.length;
  GestureCard? get current => isFinished ? null : deck[index];

  FlashcardsState copyWith({
    List<GestureCard>? deck,
    int? index,
    bool? flipped,
    Set<int>? knownIds,
  }) {
    return FlashcardsState(
      deck: deck ?? this.deck,
      index: index ?? this.index,
      flipped: flipped ?? this.flipped,
      knownIds: knownIds ?? this.knownIds,
    );
  }
}

class FlashcardsNotifier extends StateNotifier<FlashcardsState> {
  FlashcardsNotifier()
      : super(FlashcardsState(
          deck: buildGestureCardCatalog(),
          index: 0,
          flipped: false,
          knownIds: {},
        ));

  void flip() => state = state.copyWith(flipped: !state.flipped);

  void markKnown() {
    final card = state.current;
    if (card == null) return;
    state = state.copyWith(
      knownIds: {...state.knownIds, card.id},
      index: state.index + 1,
      flipped: false,
    );
  }

  void markLearning() {
    if (state.current == null) return;
    state = state.copyWith(index: state.index + 1, flipped: false);
  }

  void restart({bool shuffleDeck = false}) {
    var deck = buildGestureCardCatalog();
    if (shuffleDeck) deck = [...deck]..shuffle(Random());
    state = FlashcardsState(deck: deck, index: 0, flipped: false, knownIds: {});
  }
}

final flashcardsProvider =
    StateNotifierProvider.autoDispose<FlashcardsNotifier, FlashcardsState>(
  (ref) => FlashcardsNotifier(),
);
