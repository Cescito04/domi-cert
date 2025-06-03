import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/proprietaire.dart';
import 'proprietaire_service.dart';

final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final ProprietaireService _proprietaireService = ProprietaireService();

  Future<UserCredential> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  Future<UserCredential> createUserWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw Exception('Erreur d\'inscription: $e');
    }
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      print('Attempting Google Sign-In');
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        print('Google Sign-In aborted by user');
        return null;
      }
      print('Google user signed in: ${googleUser.email}');

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      print('Google authentication obtained');
      print('Access Token: ${googleAuth.accessToken}');
      print(
          'ID Token: ${googleAuth.idToken?.substring(0, 10)}...'); // Log partial ID token

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      print('Firebase credential created');

      print('Signing in with Firebase credential');
      final userCredential = await _auth.signInWithCredential(credential);
      print('Signed in with Firebase: ${userCredential.user?.uid}');
      print(
          'User credential additional info: ${userCredential.additionalUserInfo}');

      if (userCredential.additionalUserInfo?.isNewUser ?? false) {
        print('New user signed in with Google');
        return userCredential;
      } else {
        print('Existing user signed in with Google');
        final userId = userCredential.user!.uid;
        print('Checking for existing proprietaire profile for user: $userId');
        final proprietaire = await _proprietaireService.getProprietaire(
          userId,
        );

        if (proprietaire == null) {
          print('No existing proprietaire profile, creating a new one');
          final newProprietaire = Proprietaire(
            id: userId,
            nom: userCredential.user!.displayName ?? '',
            telephone: '',
            email: userCredential.user!.email ?? '',
          );
          await _proprietaireService.createProprietaire(newProprietaire);
          print('New proprietaire profile created');
        } else {
          print('Existing proprietaire profile found');
        }
      }

      return userCredential;
    } catch (e, stackTrace) {
      print('Error during Google Sign-In: $e');
      print('Stack trace: $stackTrace');
      throw Exception('Erreur de connexion Google: $e');
    }
  }

  Future<void> signOut() async {
    try {
      await Future.wait([_auth.signOut(), _googleSignIn.signOut()]);
    } catch (e) {
      throw Exception('Erreur de déconnexion: $e');
    }
  }

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();
}
