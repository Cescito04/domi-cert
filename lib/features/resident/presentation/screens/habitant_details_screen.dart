import 'package:flutter/material.dart';
import 'package:domicert/features/resident/domain/models/habitant.dart';
import 'package:domicert/features/house/domain/models/maison.dart';
import 'package:domicert/features/house/data/services/maison_service.dart';

class HabitantDetailsScreen extends StatelessWidget {
  const HabitantDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final habitant = ModalRoute.of(context)!.settings.arguments as Habitant;
    final maisonService = MaisonService();

    return Scaffold(
      appBar: AppBar(
        title: Text('${habitant.prenom} ${habitant.nom}'),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.surface,
            ],
            stops: const [0.0, 0.3],
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Center(
                  child: Hero(
                    tag: 'habitant-${habitant.id}',
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.2),
                      child: Text(
                        habitant.prenom.isNotEmpty
                            ? habitant.prenom[0].toUpperCase()
                            : habitant.nom.isNotEmpty
                                ? habitant.nom[0].toUpperCase()
                                : '?',
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                _buildSection(
                  context,
                  title: 'Informations personnelles',
                  icon: Icons.person_outline,
                  children: [
                    _buildInfoRow(
                      context,
                      icon: Icons.badge_outlined,
                      label: 'Nom',
                      value: habitant.nom,
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow(
                      context,
                      icon: Icons.person_outline,
                      label: 'Prénom',
                      value: habitant.prenom,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildSection(
                  context,
                  title: 'Adresse',
                  icon: Icons.home_outlined,
                  children: [
                    FutureBuilder<Maison?>(
                      future: maisonService.getMaison(habitant.maisonId),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Text(
                            'Erreur: ${snapshot.error}',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          );
                        }

                        if (!snapshot.hasData) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        final maison = snapshot.data;
                        return _buildInfoRow(
                          context,
                          icon: Icons.location_on_outlined,
                          label: 'Adresse',
                          value: maison?.adresse ?? 'Non disponible',
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
