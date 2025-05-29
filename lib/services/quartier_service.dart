import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/quartier.dart';

class QuartierService {
  final CollectionReference _quartiersCollection = FirebaseFirestore.instance
      .collection('quartiers');
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Créer un nouveau quartier
  Future<void> createQuartier(Quartier quartier) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('Utilisateur non connecté');
      }

      final quartierWithUser = quartier.copyWith(userId: user.uid);
      await _quartiersCollection.doc(quartier.id).set(quartierWithUser.toMap());
    } catch (e) {
      throw Exception('Erreur lors de la création du quartier: $e');
    }
  }

  // Récupérer un quartier par son ID
  Future<Quartier?> getQuartier(String id) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('Utilisateur non connecté');
      }

      final doc = await _quartiersCollection.doc(id).get();
      if (doc.exists) {
        final quartier = Quartier.fromMap(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
        if (quartier.userId != user.uid) {
          throw Exception('Accès non autorisé à ce quartier');
        }
        return quartier;
      }
      return null;
    } catch (e) {
      throw Exception('Erreur lors de la récupération du quartier: $e');
    }
  }

  // Mettre à jour un quartier
  Future<void> updateQuartier(Quartier quartier) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('Utilisateur non connecté');
      }

      if (quartier.userId != user.uid) {
        throw Exception('Accès non autorisé à ce quartier');
      }

      await _quartiersCollection.doc(quartier.id).update(quartier.toMap());
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour du quartier: $e');
    }
  }

  // Supprimer un quartier
  Future<void> deleteQuartier(String id) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('Utilisateur non connecté');
      }

      final doc = await _quartiersCollection.doc(id).get();
      if (doc.exists) {
        final quartier = Quartier.fromMap(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
        if (quartier.userId != user.uid) {
          throw Exception('Accès non autorisé à ce quartier');
        }
        await _quartiersCollection.doc(id).delete();
      }
    } catch (e) {
      throw Exception('Erreur lors de la suppression du quartier: $e');
    }
  }

  // Récupérer tous les quartiers de l'utilisateur connecté
  Stream<List<Quartier>> getQuartiers() {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('Utilisateur non connecté');
    }

    return _quartiersCollection
        .where('userId', isEqualTo: user.uid)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return Quartier.fromMap(doc.data() as Map<String, dynamic>, doc.id);
          }).toList();
        });
  }

  // Méthode de test pour créer un quartier de test
  Future<void> createTestQuartier() async {
    try {
      await createQuartier(
        Quartier(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          nom: 'Quartier Test',
          description: 'Description du quartier test',
          userId: _auth.currentUser?.uid ?? '',
        ),
      );
    } catch (e) {
      throw Exception('Erreur lors de la création du quartier de test: $e');
    }
  }
}
