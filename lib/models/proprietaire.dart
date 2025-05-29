class Proprietaire {
  final String id;
  final String nom;
  final String telephone;
  final String email;

  Proprietaire({
    required this.id,
    required this.nom,
    required this.telephone,
    required this.email,
  });

  factory Proprietaire.fromMap(Map<String, dynamic> data, String documentId) {
    return Proprietaire(
      id: documentId,
      nom: data['nom'] ?? '',
      telephone: data['telephone'] ?? '',
      email: data['email'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {'nom': nom, 'telephone': telephone, 'email': email};
  }

  Proprietaire copyWith({
    String? id,
    String? nom,
    String? telephone,
    String? email,
  }) {
    return Proprietaire(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      telephone: telephone ?? this.telephone,
      email: email ?? this.email,
    );
  }
}
