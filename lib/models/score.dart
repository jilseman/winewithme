/// Represents a judge's score for a specific wine
class Score {
  final String id;
  final String partyId;
  final String wineId;
  final String judgeId;
  final String judgeName;
  final double rating; // 0-10 scale
  final String? notes;
  final DateTime createdAt;

  Score({
    required this.id,
    required this.partyId,
    required this.wineId,
    required this.judgeId,
    required this.judgeName,
    required this.rating,
    this.notes,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'partyId': partyId,
      'wineId': wineId,
      'judgeId': judgeId,
      'judgeName': judgeName,
      'rating': rating,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Score.fromJson(Map<String, dynamic> json) {
    return Score(
      id: json['id'],
      partyId: json['partyId'],
      wineId: json['wineId'],
      judgeId: json['judgeId'],
      judgeName: json['judgeName'],
      rating: (json['rating'] as num).toDouble(),
      notes: json['notes'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Score copyWith({
    String? id,
    String? partyId,
    String? wineId,
    String? judgeId,
    String? judgeName,
    double? rating,
    String? notes,
    DateTime? createdAt,
  }) {
    return Score(
      id: id ?? this.id,
      partyId: partyId ?? this.partyId,
      wineId: wineId ?? this.wineId,
      judgeId: judgeId ?? this.judgeId,
      judgeName: judgeName ?? this.judgeName,
      rating: rating ?? this.rating,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
