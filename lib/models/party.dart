/// Represents a wine tasting party
class Party {
  final String id;
  final String name;
  final String hostId;
  final String hostName;
  final String partyCode; // Short code for judges to join
  final DateTime createdAt;
  final bool isActive; // Can judges still submit scores?
  final bool resultsRevealed; // Are wine details visible?

  Party({
    required this.id,
    required this.name,
    required this.hostId,
    required this.hostName,
    required this.partyCode,
    required this.createdAt,
    this.isActive = true,
    this.resultsRevealed = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'hostId': hostId,
      'hostName': hostName,
      'partyCode': partyCode,
      'createdAt': createdAt.toIso8601String(),
      'isActive': isActive,
      'resultsRevealed': resultsRevealed,
    };
  }

  factory Party.fromJson(Map<String, dynamic> json) {
    return Party(
      id: json['id'],
      name: json['name'],
      hostId: json['hostId'],
      hostName: json['hostName'],
      partyCode: json['partyCode'],
      createdAt: DateTime.parse(json['createdAt']),
      isActive: json['isActive'] ?? true,
      resultsRevealed: json['resultsRevealed'] ?? false,
    );
  }

  Party copyWith({
    String? id,
    String? name,
    String? hostId,
    String? hostName,
    String? partyCode,
    DateTime? createdAt,
    bool? isActive,
    bool? resultsRevealed,
  }) {
    return Party(
      id: id ?? this.id,
      name: name ?? this.name,
      hostId: hostId ?? this.hostId,
      hostName: hostName ?? this.hostName,
      partyCode: partyCode ?? this.partyCode,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
      resultsRevealed: resultsRevealed ?? this.resultsRevealed,
    );
  }
}
