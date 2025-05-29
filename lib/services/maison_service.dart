import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/maison.dart';

class MaisonService {
  final CollectionReference _maisonsCollection = FirebaseFirestore.instance
      .collection('maisons');

  // Créer une nouvelle maison
  Future<void> createMaison(Maison maison) async {
    try {
      await _maisonsCollection.doc(maison.id).set(maison.toMap());
    } catch (e) {
      throw Exception('Erreur lors de la création de la maison: $e');
    }
  }

  // Récupérer une maison par son ID
  Future<Maison?> getMaison(String id) async {
    try {
      final doc = await _maisonsCollection.doc(id).get();
      if (doc.exists) {
        return Maison.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      throw Exception('Erreur lors de la récupération de la maison: $e');
    }
  }

  // Mettre à jour une maison
  Future<void> updateMaison(Maison maison) async {
    try {
      await _maisonsCollection.doc(maison.id).update(maison.toMap());
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour de la maison: $e');
    }
  }

  // Supprimer une maison
  Future<void> deleteMaison(String id) async {
    try {
      await _maisonsCollection.doc(id).delete();
    } catch (e) {
      throw Exception('Erreur lors de la suppression de la maison: $e');
    }
  }

  // Récupérer toutes les maisons
  Stream<List<Maison>> getMaisons() {
    return _maisonsCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Maison.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  // Récupérer les maisons d'un propriétaire
  Stream<List<Maison>> getMaisonsByProprietaire(String proprietaireId) {
    return _maisonsCollection
        .where('proprietaireId', isEqualTo: proprietaireId)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return Maison.fromMap(doc.data() as Map<String, dynamic>, doc.id);
          }).toList();
        });
  }

  // Récupérer les maisons d'un quartier
  Stream<List<Maison>> getMaisonsByQuartier(String quartierId) {
    return _maisonsCollection
        .where('quartierId', isEqualTo: quartierId)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return Maison.fromMap(doc.data() as Map<String, dynamic>, doc.id);
          }).toList();
        });
  }
}
