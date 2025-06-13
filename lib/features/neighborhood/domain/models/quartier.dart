import 'package:cloud_firestore/cloud_firestore.dart';

class Quartier {
  final String id;
  final String nom;
  final String commune;
  final String userId;
  final String chefPrenom;
  final String chefNom;

  Quartier({
    required this.id,
    required this.nom,
    required this.commune,
    required this.userId,
    required this.chefPrenom,
    required this.chefNom,
  });

  Quartier copyWith({
    String? id,
    String? nom,
    String? commune,
    String? userId,
    String? chefPrenom,
    String? chefNom,
  }) {
    return Quartier(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      commune: commune ?? this.commune,
      userId: userId ?? this.userId,
      chefPrenom: chefPrenom ?? this.chefPrenom,
      chefNom: chefNom ?? this.chefNom,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nom': nom,
      'commune': commune,
      'userId': userId,
      'chefPrenom': chefPrenom,
      'chefNom': chefNom,
    };
  }

  factory Quartier.fromJson(Map<String, dynamic> json) {
    return Quartier(
      id: json['id']?.toString() ?? '',
      nom: json['nom']?.toString() ?? '',
      commune: json['commune']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      chefPrenom: json['chefPrenom']?.toString() ?? '',
      chefNom: json['chefNom']?.toString() ?? '',
    );
  }
}
