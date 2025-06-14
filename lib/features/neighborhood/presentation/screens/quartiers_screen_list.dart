import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:domicert/features/neighborhood/data/services/quartier_service.dart';
import 'package:domicert/features/resident/data/services/habitant_service.dart';
import 'package:domicert/features/neighborhood/presentation/screens/quartier_screen.dart';
import 'package:domicert/features/house/data/services/maison_service.dart';
import 'package:domicert/features/certificate/data/services/certificat_service.dart';
import 'package:domicert/core/services/cascade_deletion_service.dart';

final quartierServiceProvider = Provider((ref) => QuartierService());
final habitantServiceProvider = Provider((ref) => HabitantService());
final cascadeDeletionServiceProvider =
    Provider((ref) => CascadeDeletionService());

class QuartiersScreen extends ConsumerStatefulWidget {
  const QuartiersScreen({super.key});

  @override
  ConsumerState<QuartiersScreen> createState() => _QuartiersScreenState();
}

class _QuartiersScreenState extends ConsumerState<QuartiersScreen> {
  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _deleteQuartier(String quartierId) async {
    final confirmed = await ref
        .read(cascadeDeletionServiceProvider)
        .showDeleteConfirmationDialog(
          context,
          'Supprimer le quartier',
          'Êtes-vous sûr de vouloir supprimer ce quartier ? Cette action supprimera également toutes les maisons, habitants et certificats associés.',
        );

    if (confirmed) {
      try {
        await ref.read(quartierServiceProvider).deleteQuartier(quartierId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Quartier supprimé avec succès'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur lors de la suppression: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final quartiersAsyncValue = ref.watch(quartiersStreamProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Gestion des Quartiers')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const QuartierScreen(),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Nouveau Quartier'),
      ),
      body: quartiersAsyncValue.when(
        data: (quartiers) {
          if (quartiers.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.location_city_outlined,
                      size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Aucun quartier enregistré pour le moment.',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            itemCount: quartiers.length,
            itemBuilder: (context, index) {
              final quartier = quartiers[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                elevation: 2,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .secondary
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.location_city,
                        color: Theme.of(context).colorScheme.secondary),
                  ),
                  title: Text(
                    quartier.nom,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Commune: ${quartier.commune}'),
                      Text('Chef: ${quartier.chefPrenom} ${quartier.chefNom}'),
                    ],
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) async {
                      if (value == 'edit') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                QuartierScreen(quartier: quartier),
                          ),
                        );
                      } else if (value == 'delete') {
                        await _deleteQuartier(quartier.id);
                      }
                    },
                    itemBuilder: (BuildContext context) =>
                        <PopupMenuEntry<String>>[
                      const PopupMenuItem<String>(
                        value: 'edit',
                        child: Text('Modifier'),
                      ),
                      const PopupMenuItem<String>(
                        value: 'delete',
                        child: Text('Supprimer'),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) =>
            Center(child: Text('Erreur: ${error.toString()}')),
      ),
    );
  }
}
