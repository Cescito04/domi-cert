class Maison {
  final String id;
  final String adresse;
  final String quartierId;
  final String proprietaireId;

  Maison({
    required this.id,
    required this.adresse,
    required this.quartierId,
    required this.proprietaireId,
  });

  factory Maison.fromMap(Map<String, dynamic> data, String documentId) {
    return Maison(
      id: documentId,
      adresse: data['adresse'] ?? '',
      quartierId: data['quartierId'] ?? '',
      proprietaireId: data['proprietaireId'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'adresse': adresse,
      'quartierId': quartierId,
      'proprietaireId': proprietaireId,
    };
  }

  Maison copyWith({
    String? id,
    String? adresse,
    String? quartierId,
    String? proprietaireId,
  }) {
    return Maison(
      id: id ?? this.id,
      adresse: adresse ?? this.adresse,
      quartierId: quartierId ?? this.quartierId,
      proprietaireId: proprietaireId ?? this.proprietaireId,
    );
  }
}
