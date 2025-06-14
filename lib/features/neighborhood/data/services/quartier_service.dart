import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:domicert/features/neighborhood/domain/models/quartier.dart';
import 'package:domicert/core/services/cascade_deletion_service.dart';

// Removed imports for MaisonService, HabitantService, CertificatService as they are not needed for QuartierService's direct Firestore operations.

final quartierServiceProvider =
    Provider<QuartierService>((ref) => QuartierService());

class QuartierService {
  final CollectionReference _quartiersCollection =
      FirebaseFirestore.instance.collection('quartiers');
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final CascadeDeletionService _cascadeDeletionService =
      CascadeDeletionService();

  // Removed injected service fields as QuartierService performs direct Firestore operations for cascade deletion.
  // final MaisonService _maisonService;
  // final HabitantService _habitantService;
  // final CertificatService _certificatService;

  QuartierService(); // Reverted to a no-argument constructor.

  Future<void> createQuartier(Quartier quartier) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('Utilisateur non connecté');
      }

      final quartierWithUser = quartier.copyWith(userId: user.uid);
      await _quartiersCollection
          .doc(quartier.id)
          .set(quartierWithUser.toJson());
    } catch (e) {
      throw Exception('Erreur lors de la création du quartier: $e');
    }
  }

  Future<Quartier?> getQuartier(String id) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('Utilisateur non connecté');
      }

      final doc = await _quartiersCollection.doc(id).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        final quartier = Quartier.fromJson(data);
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

  Future<void> updateQuartier(Quartier quartier) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('Utilisateur non connecté');
      }

      if (quartier.userId != user.uid) {
        throw Exception('Accès non autorisé à ce quartier');
      }

      await _quartiersCollection.doc(quartier.id).update(quartier.toJson());
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour du quartier: $e');
    }
  }

  Future<void> deleteQuartier(String id) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('Utilisateur non connecté');
      }

      final doc = await _quartiersCollection.doc(id).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        if (data['userId'] != user.uid) {
          throw Exception('Accès non autorisé à ce quartier');
        }
        await _cascadeDeletionService.deleteQuartierCascade(id);
      }
    } catch (e) {
      throw Exception('Erreur lors de la suppression du quartier: $e');
    }
  }

  Stream<List<Quartier>> getQuartiers() {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream.value([]);
    }

    return _quartiersCollection
        .where('userId', isEqualTo: user.uid)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return Quartier.fromJson(data);
      }).toList();
    });
  }

  Future<void> createTestQuartier() async {
    try {
      await createQuartier(
        Quartier(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          nom: 'Quartier Test',
          commune: 'Commune Test',
          userId: _auth.currentUser?.uid ?? '',
          chefPrenom: 'Prénom Test',
          chefNom: 'Nom Test',
        ),
      );
    } catch (e) {
      throw Exception('Erreur lors de la création du quartier de test: $e');
    }
  }
}

final quartiersStreamProvider = StreamProvider<List<Quartier>>((ref) {
  final quartierService = ref.watch(quartierServiceProvider);
  return quartierService.getQuartiers();
});
