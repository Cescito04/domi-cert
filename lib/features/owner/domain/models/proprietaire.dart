class Proprietaire {
  final String id;
  final String nom;
  final String prenom;
  final String telephone;
  final String email;
  final String userId;

  Proprietaire({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.telephone,
    required this.email,
    required this.userId,
  });

  factory Proprietaire.fromMap(Map<String, dynamic> data, String documentId) {
    return Proprietaire(
      id: documentId,
      nom: data['nom'] ?? '',
      prenom: data['prenom'] ?? '',
      telephone: data['telephone'] ?? '',
      email: data['email'] ?? '',
      userId: data['userId'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nom': nom,
      'prenom': prenom,
      'telephone': telephone,
      'email': email,
      'userId': userId,
    };
  }

  Proprietaire copyWith({
    String? id,
    String? nom,
    String? prenom,
    String? telephone,
    String? email,
    String? userId,
  }) {
    return Proprietaire(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      prenom: prenom ?? this.prenom,
      telephone: telephone ?? this.telephone,
      email: email ?? this.email,
      userId: userId ?? this.userId,
    );
  }
}
