import 'package:cloud_firestore/cloud_firestore.dart';

enum CertificatStatut { valide, expire, annule, enAttente }

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

  factory Certificat.fromMap(Map<String, dynamic> map, String id) {
    print('Debug: dateEmission type: ${map['dateEmission'].runtimeType}');
    print('Debug: dateExpiration type: ${map['dateExpiration'].runtimeType}');
    return Certificat(
      id: id,
      habitantId: map['habitantId'] as String,
      dateEmission: _parseFirestoreDate(map['dateEmission']),
      dateExpiration: _parseFirestoreDate(map['dateExpiration']),
      statut: CertificatStatut.values.firstWhere(
        (e) => e.toString() == map['statut'],
        orElse: () => CertificatStatut.enAttente,
      ),
      certificatPdfBase64: map['certificatPdfBase64'] as String,
      userId: map['userId'] as String,
    );
  }

  static DateTime _parseFirestoreDate(dynamic date) {
    if (date == null) {
      return DateTime.now();
    } else if (date is Timestamp) {
      return date.toDate();
    } else if (date is String) {
      return DateTime.parse(date);
    } else {
      throw FormatException('Unexpected date type: ${date.runtimeType}');
    }
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
