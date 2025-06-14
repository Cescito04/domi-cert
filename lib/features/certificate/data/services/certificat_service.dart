import 'dart:io';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:domicert/features/certificate/domain/models/certificat.dart';
import 'package:domicert/features/resident/data/services/habitant_service.dart';
import 'package:domicert/features/house/data/services/maison_service.dart';
import 'package:domicert/features/neighborhood/data/services/quartier_service.dart';
import 'package:domicert/features/owner/data/services/proprietaire_service.dart';

final certificatServiceProvider =
    Provider<CertificatService>((ref) => CertificatService(
          ref.read(habitantServiceProvider),
          ref.read(maisonServiceProvider),
          ref.read(quartierServiceProvider),
          ref.read(proprietaireServiceProvider),
        ));

class CertificatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final CollectionReference _certificatsCollection =
      FirebaseFirestore.instance.collection('certificats');

  final HabitantService _habitantService;
  final MaisonService _maisonService;
  final QuartierService _quartierService;
  final ProprietaireService _proprietaireService;

  CertificatService(
    this._habitantService,
    this._maisonService,
    this._quartierService,
    this._proprietaireService,
  );

  // Créer un nouveau certificat
  Future<Certificat> createCertificat(String habitantId, File pdfFile) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Utilisateur non connecté');

    // Générer un ID unique pour le certificat
    final certificatId = const Uuid().v4();

    try {
      // Convertir le fichier PDF en base64
      final bytes = await pdfFile.readAsBytes();
      final base64Pdf = base64Encode(bytes);

      // Créer le document certificat dans Firestore
      final now = DateTime.now();
      final dateExpiration = DateTime(
        now.year + 1,
        now.month,
        now.day,
      ); // Valide 1 an

      final certificat = Certificat(
        id: certificatId,
        habitantId: habitantId,
        dateEmission: now,
        dateExpiration: dateExpiration,
        statut: CertificatStatut.valide,
        certificatPdfBase64: base64Pdf,
        userId: user.uid,
      );

      await _certificatsCollection.doc(certificatId).set(certificat.toMap());
      return certificat;
    } catch (e) {
      print('Erreur lors de la création du certificat: $e');
      rethrow;
    }
  }

  // Obtenir tous les certificats de l'utilisateur
  Stream<List<Certificat>> getCertificats() {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Utilisateur non connecté');

    return _certificatsCollection
        .where('userId', isEqualTo: user.uid)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => Certificat.fromMap(
                  doc.data() as Map<String, dynamic>,
                  doc.id,
                ),
              )
              .toList(),
        );
  }

  // Obtenir un certificat spécifique
  Future<Certificat> getCertificat(String id) async {
    final doc = await _certificatsCollection.doc(id).get();
    if (!doc.exists) throw Exception('Certificat non trouvé');

    final data = doc.data() as Map<String, dynamic>;
    final user = _auth.currentUser;
    if (user == null || data['userId'] != user.uid) {
      throw Exception('Accès non autorisé');
    }

    return Certificat.fromMap(data, doc.id);
  }

  // Annuler un certificat
  Future<void> annulerCertificat(String id) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Utilisateur non connecté');

    final doc = await _certificatsCollection.doc(id).get();
    if (!doc.exists) throw Exception('Certificat non trouvé');

    final data = doc.data() as Map<String, dynamic>;
    if (data['userId'] != user.uid) {
      throw Exception('Accès non autorisé');
    }

    await _certificatsCollection.doc(id).update({
      'statut': CertificatStatut.annule.toString(),
    });
  }

  // Supprimer un certificat
  Future<void> deleteCertificat(String id) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Utilisateur non connecté');

    final doc = await _certificatsCollection.doc(id).get();
    if (!doc.exists) throw Exception('Certificat non trouvé');

    final data = doc.data() as Map<String, dynamic>;
    if (data['userId'] != user.uid) {
      throw Exception('Accès non autorisé');
    }

    // Supprimer le document du certificat
    await _certificatsCollection.doc(id).delete();
  }

  // Obtenir les informations complètes pour la génération du PDF
  Future<Map<String, dynamic>> getCertificatData(String habitantId) async {
    final habitant = await _habitantService.getHabitant(habitantId);
    final maison = await _maisonService.getMaison(habitant.maisonId);
    if (maison == null) throw Exception('Maison non trouvée');

    final quartier = await _quartierService.getQuartier(maison.quartierId);
    if (quartier == null) throw Exception('Quartier non trouvé');

    final proprietaire =
        await _proprietaireService.getProprietaire(maison.proprietaireId);
    if (proprietaire == null) throw Exception('Propriétaire non trouvé');

    return {
      'habitant': habitant,
      'maison': maison,
      'quartier': quartier,
      'proprietaire': proprietaire,
    };
  }
}
