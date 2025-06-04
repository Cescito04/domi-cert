class Quartier {
  final String id;
  final String nom;
  final String description;
  final String userId;
  final String chefQuartierId;

  Quartier({
    required this.id,
    required this.nom,
    required this.description,
    required this.userId,
    required this.chefQuartierId,
  });

  factory Quartier.fromMap(Map<String, dynamic> data, String documentId) {
    return Quartier(
      id: documentId,
      nom: data['nom'] ?? '',
      description: data['description'] ?? '',
      userId: data['userId'] ?? '',
      chefQuartierId: data['chefQuartierId'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nom': nom,
      'description': description,
      'userId': userId,
      'chefQuartierId': chefQuartierId,
    };
  }

  Quartier copyWith({
    String? id,
    String? nom,
    String? description,
    String? userId,
    String? chefQuartierId,
  }) {
    return Quartier(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      description: description ?? this.description,
      userId: userId ?? this.userId,
      chefQuartierId: chefQuartierId ?? this.chefQuartierId,
    );
  }
}
