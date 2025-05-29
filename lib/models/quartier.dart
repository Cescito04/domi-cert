class Quartier {
  final String id;
  final String nom;
  final String description;
  final String userId;

  Quartier({
    required this.id,
    required this.nom,
    required this.description,
    required this.userId,
  });

  factory Quartier.fromMap(Map<String, dynamic> data, String documentId) {
    return Quartier(
      id: documentId,
      nom: data['nom'] ?? '',
      description: data['description'] ?? '',
      userId: data['userId'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {'nom': nom, 'description': description, 'userId': userId};
  }

  Quartier copyWith({
    String? id,
    String? nom,
    String? description,
    String? userId,
  }) {
    return Quartier(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      description: description ?? this.description,
      userId: userId ?? this.userId,
    );
  }
}
