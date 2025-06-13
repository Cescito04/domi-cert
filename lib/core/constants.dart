import 'package:flutter/material.dart';

// App Constants
const String appName = 'DomiCert';
const String appVersion = '1.0.0';

// Firebase Collections
const String usersCollection = 'users';
const String quartiersCollection = 'quartiers';
const String maisonsCollection = 'maisons';
const String habitantsCollection = 'habitants';
const String certificatsCollection = 'certificats';

// Theme Constants
const Color primaryColor = Color(0xFF2196F3);
const Color secondaryColor = Color(0xFF03A9F4);
const Color accentColor = Color(0xFF00BCD4);

// Text Styles
const TextStyle titleStyle = TextStyle(
  fontSize: 24,
  fontWeight: FontWeight.bold,
  color: Colors.black87,
);

const TextStyle subtitleStyle = TextStyle(
  fontSize: 18,
  fontWeight: FontWeight.w500,
  color: Colors.black54,
);

// Padding Constants
const double defaultPadding = 16.0;
const double smallPadding = 8.0;
const double largePadding = 24.0;

// Border Radius
const double defaultBorderRadius = 8.0;
const double largeBorderRadius = 16.0;

// Animation Durations
const Duration defaultAnimationDuration = Duration(milliseconds: 300);
const Duration longAnimationDuration = Duration(milliseconds: 500);

// Error Messages
const String genericErrorMessage =
    'Une erreur est survenue. Veuillez réessayer.';
const String networkErrorMessage =
    'Erreur de connexion. Vérifiez votre connexion internet.';
const String authErrorMessage =
    'Erreur d\'authentification. Veuillez vérifier vos identifiants.';

// Success Messages
const String saveSuccessMessage = 'Enregistrement réussi';
const String deleteSuccessMessage = 'Suppression réussi';
const String updateSuccessMessage = 'Mise à jour réussi';
