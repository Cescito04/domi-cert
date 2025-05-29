import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/quartier.dart';

class QuartierService {
  final CollectionReference _quartiersCollection = FirebaseFirestore.instance
      .collection('quartiers');

  // Créer un nouveau quartier
  Future<Quartier> createQuartier(String nom) async {
    try {
      DocumentReference docRef = await _quartiersCollection.add({
        'nom': nom,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return Quartier(id: docRef.id, nom: nom);
    } catch (e) {
      throw Exception('Erreur lors de la création du quartier: $e');
    }
  }

  // Récupérer tous les quartiers
  Stream<List<Quartier>> getQuartiers() {
    return _quartiersCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return Quartier.fromMap(doc.data() as Map<String, dynamic>, doc.id);
          }).toList();
        });
  }

  // Mettre à jour un quartier
  Future<void> updateQuartier(String id, String nom) async {
    try {
      await _quartiersCollection.doc(id).update({
        'nom': nom,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour du quartier: $e');
    }
  }

  // Supprimer un quartier
  Future<void> deleteQuartier(String id) async {
    try {
      await _quartiersCollection.doc(id).delete();
    } catch (e) {
      throw Exception('Erreur lors de la suppression du quartier: $e');
    }
  }

  // Méthode de test pour créer un quartier de test
  Future<void> createTestQuartier() async {
    try {
      await createQuartier('Quartier Test');
    } catch (e) {
      throw Exception('Erreur lors de la création du quartier de test: $e');
    }
  }

  Future<Quartier?> getQuartier(String id) async {
    try {
      final doc = await _quartiersCollection.doc(id).get();
      if (doc.exists) {
        return Quartier.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      throw Exception('Erreur lors de la récupération du quartier: $e');
    }
  }
}
