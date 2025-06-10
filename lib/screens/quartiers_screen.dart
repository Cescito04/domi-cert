import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/quartier.dart';
import '../models/habitant.dart';
import '../services/quartier_service.dart';
import '../services/habitant_service.dart';
import '../screens/quartier_screen.dart';

final quartierServiceProvider = Provider((ref) => QuartierService());
final habitantServiceProvider = Provider((ref) => HabitantService());

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

  Future<void> _deleteQuartier(String id) async {
    try {
      await ref.read(quartierServiceProvider).deleteQuartier(id);
      ref.invalidate(quartiersStreamProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Quartier supprimé avec succès')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: ${e.toString()}')),
        );
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
                      Text('Description: ${quartier.description}'),
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
