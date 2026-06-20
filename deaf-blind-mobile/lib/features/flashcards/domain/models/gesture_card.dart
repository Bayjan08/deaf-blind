/// A single flashcard: a sign-language gesture's picture and its meaning.
class GestureCard {
  GestureCard({
    required this.id,
    required this.meaning,
    required this.imageAsset,
  });

  final int id;
  final String meaning;
  final String imageAsset;
}
