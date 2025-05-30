import 'package:flutter/material.dart';
import '../models/habitant.dart';
import '../models/maison.dart';
import '../services/maison_service.dart';

class HabitantDetailsScreen extends StatelessWidget {
  const HabitantDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final habitant = ModalRoute.of(context)!.settings.arguments as Habitant;
    final maisonService = MaisonService();

    return Scaffold(
      appBar: AppBar(title: Text('${habitant.prenom} ${habitant.nom}')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Informations personnelles',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow('Nom', habitant.nom),
                    const SizedBox(height: 8),
                    _buildInfoRow('Prénom', habitant.prenom),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Adresse',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    FutureBuilder<Maison?>(
                      future: maisonService.getMaison(habitant.maisonId),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Text('Erreur: ${snapshot.error}');
                        }

                        if (!snapshot.hasData) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        final maison = snapshot.data;
                        return _buildInfoRow(
                          'Adresse',
                          maison?.adresse ?? 'Non disponible',
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(child: Text(value)),
      ],
    );
  }
}
