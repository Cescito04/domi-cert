# DomiCert

DomiCert is a Flutter application for digital certificate management, verification, and traceability, designed for administrative and residential use.

## Features

- Generate digital certificates as PDFs with embedded QR codes
- Each QR code encodes a unique verification URL
- Public web page for certificate verification (Flutter Web + Firebase Hosting)
- Real-time status: Valid / Cancelled (one-time use)
- Mark certificate as consulted (status set to cancelled)
- User authentication (Firebase Auth)
- Data storage in Firebase Firestore
- Multi-platform: Android, iOS, Web, Desktop

## Technologies

- **Flutter** (Dart)
- **Firebase** (Firestore, Auth, Hosting)
- **qr_flutter** (QR code generation)
- **pdf** (PDF generation)
- **url_launcher** (open URLs)

## Getting Started

### Prerequisites
- Flutter SDK (3.22.x recommended)
- Dart SDK (3.4.x)
- Firebase project (Firestore, Auth, Hosting enabled)

### Installation
1. Clone the repository:
   ```sh
   git clone https://github.com/Cescito04/domi-cert.git
   cd domi-cert
   ```
2. Install dependencies:
   ```sh
   flutter pub get
   ```
3. Configure Firebase:
   - Generate `firebase_options.dart` using [FlutterFire CLI](https://firebase.flutter.dev/docs/cli/)
   - Add your `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)

### Running the App
- **Mobile:**
  ```sh
  flutter run
  ```
- **Web:**
  ```sh
  flutter run -d chrome
  ```

### Building for Web & Deploying
1. Build the web app:
   ```sh
   flutter build web --release
   ```
2. Deploy to Firebase Hosting:
   ```sh
   firebase deploy --only hosting
   ```

## Certificate Verification Flow
- Each generated certificate PDF contains a QR code with a unique URL:
  `https://domicert-53795.web.app/certificat/verify/<certificat_id>`
- Scanning the QR code opens a public verification page:
  - Displays certificate info and status
  - Allows one-time validation (status set to cancelled after viewing)

## Security
- Firestore rules restrict access to sensitive collections
- Only the certificate verification page is public (read/update status)
- All other data requires authentication

## Project Structure

```
domi-cert/
├── android/           # Android native project
├── ios/               # iOS native project
├── lib/               # Main Flutter/Dart code
│   ├── core/          # Core services, constants, theme
│   ├── features/      # Main app features (auth, certificate, resident, etc.)
│   │   ├── auth/
│   │   ├── certificate/
│   │   ├── home/
│   │   ├── house/
│   │   ├── neighborhood/
│   │   ├── owner/
│   │   ├── profile/
│   │   └── resident/
│   ├── shared/        # Shared widgets/components
│   └── main.dart      # App entry point
├── web/               # Web static files (index.html, icons, etc.)
├── test/              # Unit and widget tests
├── pubspec.yaml       # Flutter dependencies
├── firebase.json      # Firebase Hosting config
├── firestore.rules    # Firestore security rules
├── README.md          # Project documentation
└── ...
```

- `lib/features/` contains all main business logic and screens, organized by domain.
- `lib/core/` contains shared services, constants, and theming.
- `lib/shared/` contains reusable UI widgets.
- Platform-specific code is in `android/`, `ios/`, `web/`, etc.

## Contributing
Pull requests are welcome! For major changes, please open an issue first to discuss what you would like to change.

## License
[MIT](LICENSE)
