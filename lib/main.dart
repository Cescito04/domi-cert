import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:homepass/screens/auth/login_screen.dart';
import 'package:homepass/screens/auth/register_screen.dart';
import 'package:homepass/screens/auth/google_signin_phone_screen.dart';
import 'package:homepass/screens/home/home_screen.dart';
import 'package:homepass/screens/maisons_screen.dart';
import 'package:homepass/screens/quartiers_screen.dart';
import 'package:homepass/screens/habitants_screen.dart';
import 'package:homepass/screens/habitant_details_screen.dart';
import 'package:homepass/screens/profile_screen.dart';
import 'package:homepass/services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialiser Firebase
    await Firebase.initializeApp();
    print('Firebase initialisé avec succès');

    // Configurer Firestore
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );

    // Test de connexion à Firestore
    print('Tentative de connexion à Firestore...');
    await FirebaseFirestore.instance.collection('quartiers').limit(1).get();
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
      title: 'DomiCert',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E88E5),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        textTheme: GoogleFonts.poppinsTextTheme(),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[50],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF1E88E5), width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E88E5),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
      ),
      themeMode: ThemeMode.system,
      home: authState.when(
        data: (user) => user != null ? const HomeScreen() : const LoginScreen(),
        loading:
            () => const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
        error:
            (error, stack) =>
                Scaffold(body: Center(child: Text('Erreur: $error'))),
      ),
      routes: {
        '/maisons': (context) => const MaisonsScreen(),
        '/quartiers': (context) => const QuartiersScreen(),
        '/habitants': (context) => const HabitantsScreen(),
        '/habitant-details': (context) => const HabitantDetailsScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
        '/profile': (context) => const ProfileScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/google-signin-phone') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder:
                (context) => GoogleSignInPhoneScreen(
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
