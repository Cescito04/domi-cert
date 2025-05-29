import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/maison.dart';
import '../models/quartier.dart';
import '../models/proprietaire.dart';
import '../services/maison_service.dart';
import '../services/quartier_service.dart';
import '../services/proprietaire_service.dart';

final maisonServiceProvider = Provider((ref) => MaisonService());
final quartierServiceProvider = Provider((ref) => QuartierService());
final proprietaireServiceProvider = Provider((ref) => ProprietaireService());

class MaisonsScreen extends ConsumerStatefulWidget {
  const MaisonsScreen({super.key});

  @override
  ConsumerState<MaisonsScreen> createState() => _MaisonsScreenState();
}

class _MaisonsScreenState extends ConsumerState<MaisonsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _adresseController = TextEditingController();
  String? _selectedQuartierId;
  String? _selectedProprietaireId;
  Maison? _maisonToEdit;

  @override
  void dispose() {
    _adresseController.dispose();
    super.dispose();
  }

  void _showMaisonDialog([Maison? maison]) {
    _maisonToEdit = maison;
    _adresseController.text = maison?.adresse ?? '';
    _selectedQuartierId = maison?.quartierId;
    _selectedProprietaireId = maison?.proprietaireId;

    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      maison == null ? Icons.add_home : Icons.edit,
                      size: 32,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    maison == null ? 'Nouvelle Maison' : 'Modifier Maison',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _adresseController,
                          decoration: InputDecoration(
                            labelText: 'Adresse',
                            hintText: 'Entrez l\'adresse de la maison',
                            prefixIcon: const Icon(Icons.home_outlined),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.grey[50],
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez entrer une adresse';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        StreamBuilder<List<Quartier>>(
                          stream:
                              ref.read(quartierServiceProvider).getQuartiers(),
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              return const Text(
                                'Erreur de chargement des quartiers',
                              );
                            }

                            if (!snapshot.hasData) {
                              return const CircularProgressIndicator();
                            }

                            final quartiers = snapshot.data!;
                            return DropdownButtonFormField<String>(
                              value: _selectedQuartierId,
                              decoration: InputDecoration(
                                labelText: 'Quartier',
                                prefixIcon: const Icon(
                                  Icons.location_city_outlined,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor: Colors.grey[50],
                              ),
                              items:
                                  quartiers.map((quartier) {
                                    return DropdownMenuItem(
                                      value: quartier.id,
                                      child: Text(quartier.nom),
                                    );
                                  }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedQuartierId = value;
                                });
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Veuillez sélectionner un quartier';
                                }
                                return null;
                              },
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        StreamBuilder<List<Proprietaire>>(
                          stream:
                              ref
                                  .read(proprietaireServiceProvider)
                                  .getProprietaires(),
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              return const Text(
                                'Erreur de chargement des propriétaires',
                              );
                            }

                            if (!snapshot.hasData) {
                              return const CircularProgressIndicator();
                            }

                            final proprietaires = snapshot.data!;
                            return DropdownButtonFormField<String>(
                              value: _selectedProprietaireId,
                              decoration: InputDecoration(
                                labelText: 'Propriétaire',
                                prefixIcon: const Icon(Icons.person_outline),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor: Colors.grey[50],
                              ),
                              items:
                                  proprietaires.map((proprietaire) {
                                    return DropdownMenuItem(
                                      value: proprietaire.id,
                                      child: Text(proprietaire.nom),
                                    );
                                  }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedProprietaireId = value;
                                });
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Veuillez sélectionner un propriétaire';
                                }
                                return null;
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Annuler'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            try {
                              final maison = Maison(
                                id:
                                    _maisonToEdit?.id ??
                                    DateTime.now().millisecondsSinceEpoch
                                        .toString(),
                                adresse: _adresseController.text,
                                quartierId: _selectedQuartierId!,
                                proprietaireId: _selectedProprietaireId!,
                                userId: _maisonToEdit?.userId ?? '',
                              );

                              if (_maisonToEdit == null) {
                                await ref
                                    .read(maisonServiceProvider)
                                    .createMaison(maison);
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Row(
                                        children: [
                                          const Icon(
                                            Icons.check_circle,
                                            color: Colors.white,
                                          ),
                                          const SizedBox(width: 8),
                                          const Text(
                                            'Maison créée avec succès',
                                          ),
                                        ],
                                      ),
                                      backgroundColor: Colors.green,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  );
                                }
                              } else {
                                await ref
                                    .read(maisonServiceProvider)
                                    .updateMaison(maison);
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Row(
                                        children: [
                                          const Icon(
                                            Icons.check_circle,
                                            color: Colors.white,
                                          ),
                                          const SizedBox(width: 8),
                                          const Text(
                                            'Maison mise à jour avec succès',
                                          ),
                                        ],
                                      ),
                                      backgroundColor: Colors.green,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  );
                                }
                              }
                              if (mounted) Navigator.pop(context);
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Row(
                                      children: [
                                        const Icon(
                                          Icons.error_outline,
                                          color: Colors.white,
                                        ),
                                        const SizedBox(width: 8),
                                        Text('Erreur: ${e.toString()}'),
                                      ],
                                    ),
                                    backgroundColor: Colors.red,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                );
                              }
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(maison == null ? 'Créer' : 'Mettre à jour'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
    );
  }

  void _deleteMaison(Maison maison) {
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.delete_outline,
                      size: 32,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Confirmer la suppression',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Êtes-vous sûr de vouloir supprimer la maison à l\'adresse "${maison.adresse}" ?',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Annuler'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () async {
                          try {
                            await ref
                                .read(maisonServiceProvider)
                                .deleteMaison(maison.id);
                            if (mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Row(
                                    children: [
                                      const Icon(
                                        Icons.check_circle,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(width: 8),
                                      const Text(
                                        'Maison supprimée avec succès',
                                      ),
                                    ],
                                  ),
                                  backgroundColor: Colors.green,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              );
                            }
                          } catch (e) {
                            if (mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Row(
                                    children: [
                                      const Icon(
                                        Icons.error_outline,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(width: 8),
                                      Text('Erreur: ${e.toString()}'),
                                    ],
                                  ),
                                  backgroundColor: Colors.red,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Supprimer'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Gestion des Maisons',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primary.withOpacity(0.1),
              Theme.of(context).colorScheme.primaryContainer.withOpacity(0.1),
            ],
          ),
        ),
        child: StreamBuilder<List<Maison>>(
          stream: ref.read(maisonServiceProvider).getMaisons(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Erreur: ${snapshot.error}',
                  style: const TextStyle(color: Colors.red),
                ),
              );
            }

            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final maisons = snapshot.data!;

            if (maisons.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.home_outlined,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Aucune maison enregistrée',
                      style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => _showMaisonDialog(),
                      icon: const Icon(Icons.add),
                      label: const Text('Ajouter une maison'),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: maisons.length,
              itemBuilder: (context, index) {
                final maison = maisons[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.home,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    title: Text(
                      maison.adresse,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        FutureBuilder<Quartier?>(
                          future: ref
                              .read(quartierServiceProvider)
                              .getQuartier(maison.quartierId),
                          builder: (context, snapshot) {
                            return Row(
                              children: [
                                const Icon(
                                  Icons.location_city_outlined,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  snapshot.data?.nom ?? 'Chargement...',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 4),
                        FutureBuilder<Proprietaire?>(
                          future: ref
                              .read(proprietaireServiceProvider)
                              .getProprietaire(maison.proprietaireId),
                          builder: (context, snapshot) {
                            return Row(
                              children: [
                                const Icon(Icons.person_outline, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  snapshot.data?.nom ?? 'Chargement...',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                    trailing: PopupMenuButton(
                      itemBuilder:
                          (context) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit),
                                  SizedBox(width: 8),
                                  Text('Modifier'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete, color: Colors.red),
                                  SizedBox(width: 8),
                                  Text(
                                    'Supprimer',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ],
                              ),
                            ),
                          ],
                      onSelected: (value) {
                        if (value == 'edit') {
                          _showMaisonDialog(maison);
                        } else if (value == 'delete') {
                          _deleteMaison(maison);
                        }
                      },
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showMaisonDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Nouvelle Maison'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
    );
  }
}
