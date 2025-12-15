/// Represents a judge/attendee at a wine tasting party
class Judge {
  final String id;
  final String name;
  final String? partyId;
  final bool hasSubmittedScores;

  Judge({
    required this.id,
    required this.name,
    this.partyId,
    this.hasSubmittedScores = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'partyId': partyId,
      'hasSubmittedScores': hasSubmittedScores,
    };
  }

  factory Judge.fromJson(Map<String, dynamic> json) {
    return Judge(
      id: json['id'],
      name: json['name'],
      partyId: json['partyId'],
      hasSubmittedScores: json['hasSubmittedScores'] ?? false,
    );
  }

  Judge copyWith({
    String? id,
    String? name,
    String? partyId,
    bool? hasSubmittedScores,
  }) {
    return Judge(
      id: id ?? this.id,
      name: name ?? this.name,
      partyId: partyId ?? this.partyId,
      hasSubmittedScores: hasSubmittedScores ?? this.hasSubmittedScores,
    );
  }
}
