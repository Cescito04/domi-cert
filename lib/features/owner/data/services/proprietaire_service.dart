import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:domicert/features/owner/domain/models/proprietaire.dart';

class ProprietaireService {
  final CollectionReference _proprietairesCollection =
      FirebaseFirestore.instance.collection('proprietaires');

  // Créer un nouveau propriétaire
  Future<void> createProprietaire(Proprietaire proprietaire) async {
    try {
      await _proprietairesCollection
          .doc(proprietaire.id)
          .set(proprietaire.toMap());
    } catch (e) {
      throw Exception('Erreur lors de la création du propriétaire: $e');
    }
  }

  // Récupérer un propriétaire par son ID
  Future<Proprietaire?> getProprietaire(String id) async {
    try {
      final doc = await _proprietairesCollection.doc(id).get();
      if (doc.exists) {
        return Proprietaire.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      throw Exception('Erreur lors de la récupération du propriétaire: $e');
    }
  }

  // Mettre à jour un propriétaire
  Future<void> updateProprietaire(Proprietaire proprietaire) async {
    try {
      await _proprietairesCollection
          .doc(proprietaire.id)
          .update(proprietaire.toMap());
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour du propriétaire: $e');
    }
  }

  // Vérifier si un propriétaire existe
  Future<bool> proprietaireExists(String id) async {
    try {
      final doc = await _proprietairesCollection.doc(id).get();
      return doc.exists;
    } catch (e) {
      throw Exception('Erreur lors de la vérification du propriétaire: $e');
    }
  }

  Stream<List<Proprietaire>> getProprietaires() {
    return _proprietairesCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Proprietaire.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }
}
