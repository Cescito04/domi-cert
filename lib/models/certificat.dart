import 'package:cloud_firestore/cloud_firestore.dart';

enum CertificatStatut { enAttente, valide, expire, annule }

class Certificat {
  final String id;
  final String habitantId;
  final DateTime dateEmission;
  final DateTime dateExpiration;
  final CertificatStatut statut;
  final String certificatPdfBase64;
  final String userId;

  Certificat({
    required this.id,
    required this.habitantId,
    required this.dateEmission,
    required this.dateExpiration,
    required this.statut,
    required this.certificatPdfBase64,
    required this.userId,
  });

  factory Certificat.fromMap(Map<String, dynamic> data, String documentId) {
    return Certificat(
      id: documentId,
      habitantId: data['habitantId'] ?? '',
      dateEmission: (data['dateEmission'] as Timestamp).toDate(),
      dateExpiration: (data['dateExpiration'] as Timestamp).toDate(),
      statut: CertificatStatut.values.firstWhere(
        (e) => e.toString() == data['statut'],
        orElse: () => CertificatStatut.enAttente,
      ),
      certificatPdfBase64: data['certificatPdfBase64'] ?? '',
      userId: data['userId'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'habitantId': habitantId,
      'dateEmission': Timestamp.fromDate(dateEmission),
      'dateExpiration': Timestamp.fromDate(dateExpiration),
      'statut': statut.toString(),
      'certificatPdfBase64': certificatPdfBase64,
      'userId': userId,
    };
  }

  Certificat copyWith({
    String? id,
    String? habitantId,
    DateTime? dateEmission,
    DateTime? dateExpiration,
    CertificatStatut? statut,
    String? certificatPdfBase64,
    String? userId,
  }) {
    return Certificat(
      id: id ?? this.id,
      habitantId: habitantId ?? this.habitantId,
      dateEmission: dateEmission ?? this.dateEmission,
      dateExpiration: dateExpiration ?? this.dateExpiration,
      statut: statut ?? this.statut,
      certificatPdfBase64: certificatPdfBase64 ?? this.certificatPdfBase64,
      userId: userId ?? this.userId,
    );
  }
}
