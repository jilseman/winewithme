/// Party status enum
enum PartyStatus {
  registering, // Wines being registered, no scoring yet
  active,      // Party started, scoring is open
  locked,      // Scoring is closed
}

/// Represents a wine tasting party
class Party {
  final String id;
  final String name;
  final String hostId;
  final String hostName;
  final String partyCode; // Short code for attendees to join
  final DateTime createdAt;
  final PartyStatus status;
  final bool resultsRevealed; // Are wine details visible?

  Party({
    required this.id,
    required this.name,
    required this.hostId,
    required this.hostName,
    required this.partyCode,
    required this.createdAt,
    this.status = PartyStatus.registering,
    this.resultsRevealed = false,
  });

  // Convenience getters
  bool get isRegistering => status == PartyStatus.registering;
  bool get isActive => status == PartyStatus.active;
  bool get isLocked => status == PartyStatus.locked;
  bool get canRegisterWines => status == PartyStatus.registering;
  bool get canScore => status == PartyStatus.active;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'hostId': hostId,
      'hostName': hostName,
      'partyCode': partyCode,
      'createdAt': createdAt.toIso8601String(),
      'status': status.name,
      'resultsRevealed': resultsRevealed,
    };
  }

  factory Party.fromJson(Map<String, dynamic> json) {
    // Handle legacy 'isActive' field for backward compatibility
    PartyStatus status;
    if (json.containsKey('status')) {
      status = PartyStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => PartyStatus.registering,
      );
    } else if (json.containsKey('isActive')) {
      // Legacy support
      status = json['isActive'] == true ? PartyStatus.active : PartyStatus.locked;
    } else {
      status = PartyStatus.registering;
    }

    return Party(
      id: json['id'],
      name: json['name'],
      hostId: json['hostId'],
      hostName: json['hostName'],
      partyCode: json['partyCode'],
      createdAt: DateTime.parse(json['createdAt']),
      status: status,
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
    PartyStatus? status,
    bool? resultsRevealed,
  }) {
    return Party(
      id: id ?? this.id,
      name: name ?? this.name,
      hostId: hostId ?? this.hostId,
      hostName: hostName ?? this.hostName,
      partyCode: partyCode ?? this.partyCode,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      resultsRevealed: resultsRevealed ?? this.resultsRevealed,
    );
  }
}
