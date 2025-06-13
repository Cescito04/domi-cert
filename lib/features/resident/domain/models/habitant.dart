class Habitant {
  final String id;
  final String nom;
  final String prenom;
  final String maisonId;
  final String userId;

  Habitant({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.maisonId,
    required this.userId,
  });

  factory Habitant.fromMap(Map<String, dynamic> data, String documentId) {
    return Habitant(
      id: documentId,
      nom: data['nom'] ?? '',
      prenom: data['prenom'] ?? '',
      maisonId: data['maisonId'] ?? '',
      userId: data['userId'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nom': nom,
      'prenom': prenom,
      'maisonId': maisonId,
      'userId': userId,
    };
  }

  Habitant copyWith({
    String? id,
    String? nom,
    String? prenom,
    String? maisonId,
    String? userId,
  }) {
    return Habitant(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      prenom: prenom ?? this.prenom,
      maisonId: maisonId ?? this.maisonId,
      userId: userId ?? this.userId,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Habitant &&
        other.id == id &&
        other.nom == nom &&
        other.prenom == prenom &&
        other.maisonId == maisonId &&
        other.userId == userId;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        nom.hashCode ^
        prenom.hashCode ^
        maisonId.hashCode ^
        userId.hashCode;
  }
}
