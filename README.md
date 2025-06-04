# DomiCert - Residence Certificate Management

DomiCert is a Flutter mobile application that enables digital management of residence certificates. The application facilitates the creation, management, and tracking of residence certificates for community residents.

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

## Installation

1. Clone the repository:
```bash
git clone https://github.com/your-username/domi-cert.git
```

2. Install dependencies:
```bash
flutter pub get
```

3. Configure Firebase:
   - Create a Firebase project
   - Add your Android/iOS application
   - Download and add the configuration file
   - Enable Authentication and Firestore

4. Launch the application:
```bash
flutter run
```

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
