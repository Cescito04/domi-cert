import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:domicert/features/owner/domain/models/proprietaire.dart';

final proprietaireServiceProvider = Provider((ref) => ProprietaireService());

class ProprietaireService {
  final CollectionReference _proprietaireCollection =
      FirebaseFirestore.instance.collection('proprietaires');
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Créer un nouveau propriétaire
  Future<void> createProprietaire(Proprietaire proprietaire) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('Utilisateur non connecté');
      }
      await _proprietaireCollection.doc(proprietaire.id).set({
        ...proprietaire.toMap(),
        'userId': user.uid,
      });
    } catch (e) {
      throw Exception('Erreur lors de la création du propriétaire: $e');
    }
  }

  // Récupérer un propriétaire par son ID
  Future<Proprietaire?> getProprietaire(String id) async {
    try {
      final doc = await _proprietaireCollection.doc(id).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        final proprietaire = Proprietaire.fromMap(data, doc.id);
        final user = _auth.currentUser;
        if (user == null || proprietaire.userId != user.uid) {
          throw Exception('Accès non autorisé');
        }
        return proprietaire;
      }
      return null;
    } catch (e) {
      throw Exception('Erreur lors de la récupération du propriétaire: $e');
    }
  }

  // Mettre à jour un propriétaire
  Future<void> updateProprietaire(Proprietaire proprietaire) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('Utilisateur non connecté');
      }

      if (proprietaire.userId != user.uid) {
        throw Exception('Accès non autorisé');
      }

      await _proprietaireCollection
          .doc(proprietaire.id)
          .update(proprietaire.toMap());
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour du propriétaire: $e');
    }
  }

  // Vérifier si un propriétaire existe
  Future<bool> proprietaireExists(String id) async {
    try {
      final doc = await _proprietaireCollection.doc(id).get();
      return doc.exists;
    } catch (e) {
      throw Exception('Erreur lors de la vérification du propriétaire: $e');
    }
  }

  Future<void> deleteProprietaire(String id) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('Utilisateur non connecté');
      }

      final doc = await _proprietaireCollection.doc(id).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        final proprietaire = Proprietaire.fromMap(data, doc.id);
        if (proprietaire.userId != user.uid) {
          throw Exception('Accès non autorisé');
        }
        await _proprietaireCollection.doc(id).delete();
      }
    } catch (e) {
      throw Exception('Erreur lors de la suppression du propriétaire: $e');
    }
  }

  Stream<List<Proprietaire>> getProprietaires() {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream.value([]);
    }

    return _proprietaireCollection
        .where('userId', isEqualTo: user.uid)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Proprietaire.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }
}
