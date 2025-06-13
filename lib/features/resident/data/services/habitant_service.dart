import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:domicert/features/resident/domain/models/habitant.dart';

class HabitantService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final CollectionReference _habitantsCollection =
      FirebaseFirestore.instance.collection('habitants');

  // Create a new habitant
  Future<void> createHabitant(Habitant habitant) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Utilisateur non connecté');

    await _habitantsCollection.doc(habitant.id).set({
      ...habitant.toMap(),
      'userId': user.uid,
    });
  }

  // Get all habitants for the current user
  Stream<List<Habitant>> getHabitants() {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Utilisateur non connecté');

    return _habitantsCollection
        .where('userId', isEqualTo: user.uid)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => Habitant.fromMap(
                  doc.data() as Map<String, dynamic>,
                  doc.id,
                ),
              )
              .toList(),
        );
  }

  // Get a single habitant
  Future<Habitant> getHabitant(String id) async {
    final doc = await _habitantsCollection.doc(id).get();
    if (!doc.exists) throw Exception('Habitant non trouvé');

    final data = doc.data() as Map<String, dynamic>;
    final user = _auth.currentUser;
    if (user == null || data['userId'] != user.uid) {
      throw Exception('Accès non autorisé');
    }

    return Habitant.fromMap(data, doc.id);
  }

  // Update a habitant
  Future<void> updateHabitant(Habitant habitant) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Utilisateur non connecté');

    final doc = await _habitantsCollection.doc(habitant.id).get();
    if (!doc.exists) throw Exception('Habitant non trouvé');

    final data = doc.data() as Map<String, dynamic>;
    if (data['userId'] != user.uid) {
      throw Exception('Accès non autorisé');
    }

    await _habitantsCollection.doc(habitant.id).update(habitant.toMap());
  }

  // Delete a habitant
  Future<void> deleteHabitant(String id) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Utilisateur non connecté');

    final doc = await _habitantsCollection.doc(id).get();
    if (!doc.exists) throw Exception('Habitant non trouvé');

    final data = doc.data() as Map<String, dynamic>;
    if (data['userId'] != user.uid) {
      throw Exception('Accès non autorisé');
    }

    await _habitantsCollection.doc(id).delete();
  }

  // Get habitants by maison
  Stream<List<Habitant>> getHabitantsByMaison(String maisonId) {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Utilisateur non connecté');

    return _habitantsCollection
        .where('userId', isEqualTo: user.uid)
        .where('maisonId', isEqualTo: maisonId)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => Habitant.fromMap(
                  doc.data() as Map<String, dynamic>,
                  doc.id,
                ),
              )
              .toList(),
        );
  }
}
