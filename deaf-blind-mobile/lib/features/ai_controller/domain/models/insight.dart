/// §5 LLM-generated insight: weak areas, trend, recommended lessons.
class Insight {
  Insight({required this.summary, required this.weakAreas, required this.trend});
  final String summary;
  final List<String> weakAreas;
  final String trend;
}
