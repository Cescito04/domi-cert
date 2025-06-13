import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:domicert/features/auth/presentation/screens/login_screen.dart';
import 'package:domicert/features/auth/presentation/screens/register_screen.dart';
import 'package:domicert/features/auth/presentation/screens/google_signin_phone_screen.dart';
import 'package:domicert/features/home/presentation/screens/home_screen.dart';
import 'package:domicert/features/house/presentation/screens/maisons_screen.dart';
import 'package:domicert/features/neighborhood/presentation/screens/quartiers_screen_list.dart';
import 'package:domicert/features/resident/presentation/screens/habitants_screen.dart';
import 'package:domicert/features/resident/presentation/screens/habitant_details_screen.dart';
import 'package:domicert/features/profile/presentation/screens/profile_screen.dart';
import 'package:domicert/features/certificate/presentation/screens/certificat_screen.dart';
import 'package:domicert/features/auth/data/services/auth_service.dart';
import 'package:domicert/core/constants.dart';
import 'package:domicert/core/theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp();
    print('Firebase initialisé avec succès');

    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );

    print('Tentative de connexion à Firestore...');
    await FirebaseFirestore.instance
        .collection(quartiersCollection)
        .limit(1)
        .get();
    print('Connexion à Firestore réussie !');
  } catch (e, stackTrace) {
    print('Erreur Firebase: $e');
    print('Stack trace: $stackTrace');
  }

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: appName,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: authState.when(
        data: (user) => user != null ? const HomeScreen() : const LoginScreen(),
        loading: () => const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
        error: (error, stack) =>
            Scaffold(body: Center(child: Text(genericErrorMessage))),
      ),
      routes: {
        '/maisons': (context) => const MaisonsScreen(),
        '/quartiers': (context) => const QuartiersScreen(),
        '/habitants': (context) => const HabitantsScreen(),
        '/habitant-details': (context) => const HabitantDetailsScreen(),
        '/certificats': (context) => const CertificatScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
        '/profile': (context) => const ProfileScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/google-signin-phone') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => GoogleSignInPhoneScreen(
              user: args['user'],
              displayName: args['displayName'],
              email: args['email'],
            ),
          );
        }
        return null;
      },
    );
  }
}
