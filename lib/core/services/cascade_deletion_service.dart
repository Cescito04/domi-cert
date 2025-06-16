import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final cascadeDeletionServiceProvider =
    Provider((ref) => CascadeDeletionService());

class CascadeDeletionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Suppression en cascade d'un quartier
  Future<void> deleteQuartierCascade(String quartierId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Utilisateur non connecté');

    try {
      // 1. Récupérer toutes les maisons du quartier
      final maisonsSnapshot = await _firestore
          .collection('maisons')
          .where('quartierId', isEqualTo: quartierId)
          .where('userId', isEqualTo: user.uid)
          .get();

      // 2. Pour chaque maison, supprimer les habitants et leurs certificats
      for (var maisonDoc in maisonsSnapshot.docs) {
        await deleteMaisonCascade(maisonDoc.id);
      }

      // 3. Supprimer le quartier
      await _firestore.collection('quartiers').doc(quartierId).delete();
    } catch (e) {
      throw Exception(
          'Erreur lors de la suppression en cascade du quartier: $e');
    }
  }

  // Suppression en cascade d'une maison
  Future<void> deleteMaisonCascade(String maisonId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Utilisateur non connecté');

    try {
      // 1. Récupérer tous les habitants de la maison
      final habitantsSnapshot = await _firestore
          .collection('habitants')
          .where('maisonId', isEqualTo: maisonId)
          .where('userId', isEqualTo: user.uid)
          .get();

      // 2. Pour chaque habitant, supprimer ses certificats
      for (var habitantDoc in habitantsSnapshot.docs) {
        await deleteHabitantCascade(habitantDoc.id);
      }

      // 3. Supprimer la maison
      await _firestore.collection('maisons').doc(maisonId).delete();
    } catch (e) {
      throw Exception(
          'Erreur lors de la suppression en cascade de la maison: $e');
    }
  }

  // Suppression en cascade d'un habitant
  Future<void> deleteHabitantCascade(String habitantId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Utilisateur non connecté');

    try {
      // 1. Supprimer tous les certificats de l'habitant
      final certificatsSnapshot = await _firestore
          .collection('certificats')
          .where('habitantId', isEqualTo: habitantId)
          .where('userId', isEqualTo: user.uid)
          .get();

      for (var certificatDoc in certificatsSnapshot.docs) {
        await certificatDoc.reference.delete();
      }

      // 2. Supprimer l'habitant
      await _firestore.collection('habitants').doc(habitantId).delete();
    } catch (e) {
      throw Exception(
          'Erreur lors de la suppression en cascade de l\'habitant: $e');
    }
  }

  // Méthode utilitaire pour afficher un dialogue de confirmation
  Future<bool> showDeleteConfirmationDialog(
    BuildContext context,
    String title,
    String message,
  ) async {
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.red.shade700,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.blue.shade700,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'Cette action est irréversible',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(
                    'Annuler',
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 16,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Supprimer',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
              actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            );
          },
        ) ??
        false;
  }
}
