class Quartier {
  final String id;
  final String nom;

  Quartier({required this.id, required this.nom});

  factory Quartier.fromMap(Map<String, dynamic> data, String documentId) {
    return Quartier(id: documentId, nom: data['nom'] ?? '');
  }

  Map<String, dynamic> toMap() {
    return {'nom': nom};
  }

  Quartier copyWith({String? id, String? nom}) {
    return Quartier(id: id ?? this.id, nom: nom ?? this.nom);
  }
}
