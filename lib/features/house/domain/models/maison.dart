class Maison {
  final String id;
  final String adresse;
  final String quartierId;
  final String proprietaireId;
  final String userId;

  Maison({
    required this.id,
    required this.adresse,
    required this.quartierId,
    required this.proprietaireId,
    required this.userId,
  });

  factory Maison.fromMap(Map<String, dynamic> data, String documentId) {
    return Maison(
      id: documentId,
      adresse: data['adresse'] ?? '',
      quartierId: data['quartierId'] ?? '',
      proprietaireId: data['proprietaireId'] ?? '',
      userId: data['userId'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'adresse': adresse,
      'quartierId': quartierId,
      'proprietaireId': proprietaireId,
      'userId': userId,
    };
  }

  Maison copyWith({
    String? id,
    String? adresse,
    String? quartierId,
    String? proprietaireId,
    String? userId,
  }) {
    return Maison(
      id: id ?? this.id,
      adresse: adresse ?? this.adresse,
      quartierId: quartierId ?? this.quartierId,
      proprietaireId: proprietaireId ?? this.proprietaireId,
      userId: userId ?? this.userId,
    );
  }
}
