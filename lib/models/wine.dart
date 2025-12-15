/// Represents a wine registered for a tasting party
class Wine {
  final String id;
  final String partyId;
  final String registeredBy; // Judge ID who brought this wine
  final int blindNumber; // The number shown during blind tasting (1-20)

  // Wine details (hidden during blind tasting, revealed after)
  final String name;
  final String? winery;
  final String? vintage;
  final String? varietal;
  final String? region;
  final String? notes;

  Wine({
    required this.id,
    required this.partyId,
    required this.registeredBy,
    required this.blindNumber,
    required this.name,
    this.winery,
    this.vintage,
    this.varietal,
    this.region,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'partyId': partyId,
      'registeredBy': registeredBy,
      'blindNumber': blindNumber,
      'name': name,
      'winery': winery,
      'vintage': vintage,
      'varietal': varietal,
      'region': region,
      'notes': notes,
    };
  }

  factory Wine.fromJson(Map<String, dynamic> json) {
    return Wine(
      id: json['id'],
      partyId: json['partyId'],
      registeredBy: json['registeredBy'],
      blindNumber: json['blindNumber'],
      name: json['name'],
      winery: json['winery'],
      vintage: json['vintage'],
      varietal: json['varietal'],
      region: json['region'],
      notes: json['notes'],
    );
  }

  Wine copyWith({
    String? id,
    String? partyId,
    String? registeredBy,
    int? blindNumber,
    String? name,
    String? winery,
    String? vintage,
    String? varietal,
    String? region,
    String? notes,
  }) {
    return Wine(
      id: id ?? this.id,
      partyId: partyId ?? this.partyId,
      registeredBy: registeredBy ?? this.registeredBy,
      blindNumber: blindNumber ?? this.blindNumber,
      name: name ?? this.name,
      winery: winery ?? this.winery,
      vintage: vintage ?? this.vintage,
      varietal: varietal ?? this.varietal,
      region: region ?? this.region,
      notes: notes ?? this.notes,
    );
  }
}
