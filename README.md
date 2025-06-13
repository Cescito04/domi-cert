# DomiCert

Une application Flutter pour la gestion des certificats de résidence.

## Structure du Projet

Le projet suit une architecture modulaire basée sur les fonctionnalités (Feature-First Architecture) :

```
lib/
├── core/                     # Composants centraux
│   ├── constants.dart       # Constantes globales
│   └── theme.dart          # Configuration du thème
├── features/               # Fonctionnalités de l'application
│   ├── auth/              # Authentification
│   │   ├── data/         # Services et sources de données
│   │   ├── domain/       # Modèles et interfaces
│   │   └── presentation/ # UI et widgets
│   ├── neighborhood/     # Gestion des quartiers
│   ├── house/           # Gestion des maisons
│   ├── resident/        # Gestion des résidents
│   ├── certificate/     # Gestion des certificats
│   ├── profile/         # Gestion des profils
│   └── owner/           # Gestion des propriétaires
├── shared/              # Composants partagés
│   ├── widgets/        # Widgets réutilisables
│   │   ├── buttons/   # Boutons personnalisés
│   │   ├── cards/     # Cartes d'information
│   │   ├── forms/     # Champs de formulaire
│   │   └── loading/   # Indicateurs de chargement
│   └── utils/         # Utilitaires partagés
└── main.dart          # Point d'entrée de l'application
```

## Widgets Partagés

### LoadingIndicator
Un widget de chargement réutilisable avec support pour les messages personnalisés.

### InfoCard
Une carte d'information avec titre et contenu personnalisable.

### PrimaryButton
Un bouton principal avec support pour les états de chargement et les icônes.

### CustomTextField
Un champ de texte personnalisé avec validation et style cohérent.

## Tests

Les tests sont organisés par fonctionnalité et type de composant :
```
test/
├── shared/
│   └── widgets/
│       └── loading_indicator_test.dart
└── features/
    ├── auth/
    ├── neighborhood/
    └── ...
```

## Installation

1. Cloner le repository
2. Installer les dépendances :
```bash
flutter pub get
```
3. Configurer Firebase :
   - Ajouter le fichier `google-services.json` pour Android
   - Ajouter le fichier `GoogleService-Info.plist` pour iOS

## Développement

### Commandes utiles

- Lancer l'application :
```bash
flutter run
```

- Exécuter les tests :
```bash
flutter test
```

- Analyser le code :
```bash
flutter analyze
```

### Bonnes pratiques

1. Suivre la structure modulaire
2. Utiliser les widgets partagés
3. Documenter le code
4. Écrire des tests
5. Maintenir la cohérence du style

## Features

### Neighborhood Management
- Create and modify neighborhoods
- Assign neighborhood chiefs
- View existing neighborhoods
- Delete neighborhoods

### House Management
- Register houses by neighborhood
- Associate owners with houses
- Track addresses
- Manage detailed information

### Resident Management
- Register residents
- Associate residents with houses
- Track personal information
- Manage residents per house

### Residence Certificates
- Generate residence certificates
- View certificates in PDF format
- Track certificate validity
- Cancel and delete certificates

### User Profile
- Display personal statistics
- Track number of houses and residents
- Manage personal information

## Prerequisites

- Flutter SDK (version 2.0.0 or higher)
- Dart SDK (version 2.12.0 or higher)
- Configured Firebase project
- Android Studio / VS Code with Flutter extensions

## Project Structure

```
lib/
├── models/          # Data models
├── screens/         # Application screens
├── services/        # Services (Firebase, etc.)
├── utils/           # Utilities
└── widgets/         # Reusable widgets
```

## Firebase Configuration

1. Create a Firebase project
2. Enable the following services:
   - Authentication
   - Cloud Firestore
   - Storage (for PDFs)

3. Configure Firestore security rules:
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

## Usage

### Creating a Certificate
1. Navigate to the certificates screen
2. Select a resident
3. Click "Generate Certificate"
4. The certificate will be generated and available as PDF

### Managing Neighborhoods
1. Navigate to the neighborhoods screen
2. Use the "+" button to create a new neighborhood
3. Fill in the required information
4. Save the neighborhood

### Managing Residents
1. Navigate to the residents screen
2. Add a new resident
3. Associate them with a house
4. Save the information

## Contributing

Contributions are welcome! To contribute:

1. Fork the project
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Open a Pull Request

## License

This project is licensed under the MIT License. See the `LICENSE` file for details.

## Support

For questions or issues, please:
- Open an issue on GitHub
- Contact the support team at support@domicert.com

## Authors

- Your Name - Lead Developer

## Acknowledgments

- Flutter Team
- Firebase Team
- All contributors
