class Quartier {
  final String id;
  final String nom;
  final String commune;
  final String description;
  final String userId;
  final String chefPrenom;
  final String chefNom;

  Quartier({
    required this.id,
    required this.nom,
    required this.commune,
    required this.description,
    required this.userId,
    required this.chefPrenom,
    required this.chefNom,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'commune': commune,
      'description': description,
      'userId': userId,
      'chefPrenom': chefPrenom,
      'chefNom': chefNom,
    };
  }

  factory Quartier.fromJson(Map<String, dynamic> json) {
    return Quartier(
      id: json['id'] as String,
      nom: json['nom'] as String,
      commune: json['commune'] as String,
      description: json['description'] as String,
      userId: json['userId'] as String,
      chefPrenom: json['chefPrenom'] as String,
      chefNom: json['chefNom'] as String,
    );
  }

  Quartier copyWith({
    String? id,
    String? nom,
    String? commune,
    String? description,
    String? userId,
    String? chefPrenom,
    String? chefNom,
  }) {
    return Quartier(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      commune: commune ?? this.commune,
      description: description ?? this.description,
      userId: userId ?? this.userId,
      chefPrenom: chefPrenom ?? this.chefPrenom,
      chefNom: chefNom ?? this.chefNom,
    );
  }
}
