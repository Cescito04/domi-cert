import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/maison.dart';

class MaisonService {
  final CollectionReference _maisonsCollection = FirebaseFirestore.instance
      .collection('maisons');
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Créer une nouvelle maison
  Future<void> createMaison(Maison maison) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('Utilisateur non connecté');
      }

      final maisonWithUser = maison.copyWith(userId: user.uid);
      await _maisonsCollection.doc(maison.id).set(maisonWithUser.toMap());
    } catch (e) {
      throw Exception('Erreur lors de la création de la maison: $e');
    }
  }

  // Récupérer une maison par son ID
  Future<Maison?> getMaison(String id) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('Utilisateur non connecté');
      }

      final doc = await _maisonsCollection.doc(id).get();
      if (doc.exists) {
        final maison = Maison.fromMap(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
        if (maison.userId != user.uid) {
          throw Exception('Accès non autorisé à cette maison');
        }
        return maison;
      }
      return null;
    } catch (e) {
      throw Exception('Erreur lors de la récupération de la maison: $e');
    }
  }

  // Mettre à jour une maison
  Future<void> updateMaison(Maison maison) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('Utilisateur non connecté');
      }

      if (maison.userId != user.uid) {
        throw Exception('Accès non autorisé à cette maison');
      }

      await _maisonsCollection.doc(maison.id).update(maison.toMap());
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour de la maison: $e');
    }
  }

  // Supprimer une maison
  Future<void> deleteMaison(String id) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('Utilisateur non connecté');
      }

      final doc = await _maisonsCollection.doc(id).get();
      if (doc.exists) {
        final maison = Maison.fromMap(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
        if (maison.userId != user.uid) {
          throw Exception('Accès non autorisé à cette maison');
        }
        await _maisonsCollection.doc(id).delete();
      }
    } catch (e) {
      throw Exception('Erreur lors de la suppression de la maison: $e');
    }
  }

  // Récupérer toutes les maisons de l'utilisateur connecté
  Stream<List<Maison>> getMaisons() {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('Utilisateur non connecté');
    }

    return _maisonsCollection
        .where('userId', isEqualTo: user.uid)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return Maison.fromMap(doc.data() as Map<String, dynamic>, doc.id);
          }).toList();
        });
  }

  // Récupérer les maisons d'un propriétaire pour l'utilisateur connecté
  Stream<List<Maison>> getMaisonsByProprietaire(String proprietaireId) {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('Utilisateur non connecté');
    }

    return _maisonsCollection
        .where('userId', isEqualTo: user.uid)
        .where('proprietaireId', isEqualTo: proprietaireId)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return Maison.fromMap(doc.data() as Map<String, dynamic>, doc.id);
          }).toList();
        });
  }

  // Récupérer les maisons d'un quartier pour l'utilisateur connecté
  Stream<List<Maison>> getMaisonsByQuartier(String quartierId) {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('Utilisateur non connecté');
    }

    return _maisonsCollection
        .where('userId', isEqualTo: user.uid)
        .where('quartierId', isEqualTo: quartierId)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return Maison.fromMap(doc.data() as Map<String, dynamic>, doc.id);
          }).toList();
        });
  }
}
