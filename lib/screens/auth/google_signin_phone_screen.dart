import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/proprietaire.dart';
import '../../services/proprietaire_service.dart';

class GoogleSignInPhoneScreen extends StatefulWidget {
  final User user;
  final String displayName;
  final String email;

  const GoogleSignInPhoneScreen({
    super.key,
    required this.user,
    required this.displayName,
    required this.email,
  });

  @override
  State<GoogleSignInPhoneScreen> createState() =>
      _GoogleSignInPhoneScreenState();
}

class _GoogleSignInPhoneScreenState extends State<GoogleSignInPhoneScreen> {
  final _formKey = GlobalKey<FormState>();
  final _telephoneController = TextEditingController();
  final _proprietaireService = ProprietaireService();
  bool _isLoading = false;

  @override
  void dispose() {
    _telephoneController.dispose();
    super.dispose();
  }

  Future<void> _saveProprietaire() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final proprietaire = Proprietaire(
          id: widget.user.uid,
          nom: widget.displayName,
          telephone: _telephoneController.text.trim(),
          email: widget.email,
        );

        await _proprietaireService.createProprietaire(proprietaire);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profil créé avec succès !')),
          );
          Navigator.pushReplacementNamed(context, '/home');
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Erreur: $e')));
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Compléter votre profil')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              CircleAvatar(
                radius: 50,
                backgroundImage:
                    widget.user.photoURL != null
                        ? NetworkImage(widget.user.photoURL!)
                        : null,
                child:
                    widget.user.photoURL == null
                        ? const Icon(Icons.person, size: 50)
                        : null,
              ),
              const SizedBox(height: 16),
              Text(
                'Bienvenue ${widget.displayName} !',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                widget.email,
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Text(
                'Pour finaliser votre inscription, veuillez entrer votre numéro de téléphone',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _telephoneController,
                decoration: InputDecoration(
                  labelText: 'Téléphone',
                  prefixIcon: const Icon(Icons.phone_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer votre numéro de téléphone';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _saveProprietaire,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child:
                    _isLoading
                        ? const CircularProgressIndicator()
                        : const Text('Continuer'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
