/// §2 A node on the level map (Letters/Syllables/Words/Sentences).
class LevelNode {
  LevelNode({required this.id, required this.kind, required this.unlocked});
  final int id;
  final String kind;
  final bool unlocked;
}
