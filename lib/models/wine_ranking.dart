import 'wine.dart';

/// Represents a wine's ranking with aggregated scores
class WineRanking {
  final Wine wine;
  final int rank;
  final double averageScore;
  final double totalScore;
  final int numberOfRatings;
  final double highestScore;
  final double lowestScore;

  WineRanking({
    required this.wine,
    required this.rank,
    required this.averageScore,
    required this.totalScore,
    required this.numberOfRatings,
    required this.highestScore,
    required this.lowestScore,
  });

  String get formattedAverage => averageScore.toStringAsFixed(2);
}
