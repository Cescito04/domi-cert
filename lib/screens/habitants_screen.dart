import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'dart:async';
import '../models/habitant.dart';
import '../models/maison.dart';
import '../models/quartier.dart';
import '../services/habitant_service.dart';
import '../services/maison_service.dart';
import '../services/quartier_service.dart';

class HabitantsScreen extends StatefulWidget {
  const HabitantsScreen({super.key});

  @override
  State<HabitantsScreen> createState() => _HabitantsScreenState();
}

class _HabitantsScreenState extends State<HabitantsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _habitantService = HabitantService();
  final _maisonService = MaisonService();
  final _quartierService = QuartierService();
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  String? _selectedQuartierId;
  String? _selectedMaisonId;
  Habitant? _editingHabitant;
  List<Maison> _maisons = [];
  List<Quartier> _quartiers = [];
  StreamSubscription? _maisonsSubscription;
  StreamSubscription? _quartiersSubscription;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _maisonsSubscription?.cancel();
    _quartiersSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadData() async {
    _quartiersSubscription = _quartierService.getQuartiers().listen((
      quartiers,
    ) {
      if (mounted) {
        setState(() {
          _quartiers = quartiers;
        });
      }
    });

    _maisonsSubscription = _maisonService.getMaisons().listen((maisons) {
      if (mounted) {
        setState(() {
          _maisons = maisons;
          // Si on est en mode édition, on s'assure que la maison sélectionnée est toujours valide
          if (_editingHabitant != null && _selectedMaisonId != null) {
            final maisonExists = maisons.any((m) => m.id == _selectedMaisonId);
            if (!maisonExists) {
              _selectedMaisonId = null;
            }
          }
        });
      }
    });
  }

  List<Maison> get _filteredMaisons {
    if (_selectedQuartierId == null) return _maisons;
    return _maisons.where((m) => m.quartierId == _selectedQuartierId).toList();
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _nomController.clear();
    _prenomController.clear();
    setState(() {
      _selectedQuartierId = null;
      _selectedMaisonId = null;
      _editingHabitant = null;
    });
  }

  Future<void> _openHabitantForm({Habitant? habitant}) async {
    if (habitant != null) {
      _editingHabitant = habitant;
      _nomController.text = habitant.nom;
      _prenomController.text = habitant.prenom;
      _selectedMaisonId = habitant.maisonId;
      // Récupérer le quartier de la maison sélectionnée
      final maison = await _maisonService.getMaison(habitant.maisonId);
      if (maison != null) {
        setState(() {
          _selectedQuartierId = maison.quartierId;
        });
      }
    } else {
      _resetForm();
    }

    if (!mounted) return;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setModalState) => Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                    left: 24,
                    right: 24,
                    top: 24,
                  ),
                  child: SingleChildScrollView(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            habitant == null
                                ? 'Ajouter un Habitant'
                                : 'Modifier l\'Habitant',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          TextFormField(
                            controller: _nomController,
                            decoration: const InputDecoration(
                              labelText: 'Nom',
                              prefixIcon: Icon(Icons.person_outline),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Veuillez entrer un nom';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _prenomController,
                            decoration: const InputDecoration(
                              labelText: 'Prénom',
                              prefixIcon: Icon(Icons.person_outline),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Veuillez entrer un prénom';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          StreamBuilder<List<Quartier>>(
                            stream: _quartierService.getQuartiers(),
                            builder: (context, snapshot) {
                              if (snapshot.hasError) {
                                return Text('Erreur: ${snapshot.error}');
                              }
                              if (!snapshot.hasData) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              }
                              final quartiers = snapshot.data!;
                              return DropdownButtonFormField<String>(
                                value: _selectedQuartierId,
                                decoration: const InputDecoration(
                                  labelText: 'Quartier',
                                  prefixIcon: Icon(
                                    Icons.location_city_outlined,
                                  ),
                                ),
                                items:
                                    quartiers.map((quartier) {
                                      return DropdownMenuItem(
                                        value: quartier.id,
                                        child: Text(quartier.nom),
                                      );
                                    }).toList(),
                                onChanged: (value) {
                                  setModalState(() {
                                    _selectedQuartierId = value;
                                    _selectedMaisonId =
                                        null; // Réinitialiser la maison sélectionnée
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
                          StreamBuilder<List<Maison>>(
                            stream: _maisonService.getMaisons(),
                            builder: (context, snapshot) {
                              if (snapshot.hasError) {
                                return Text('Erreur: ${snapshot.error}');
                              }
                              if (!snapshot.hasData) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              }
                              final maisons = snapshot.data!;
                              final filteredMaisons =
                                  _selectedQuartierId == null
                                      ? maisons
                                      : maisons
                                          .where(
                                            (m) =>
                                                m.quartierId ==
                                                _selectedQuartierId,
                                          )
                                          .toList();

                              return DropdownButtonFormField<String>(
                                value: _selectedMaisonId,
                                decoration: const InputDecoration(
                                  labelText: 'Maison',
                                  prefixIcon: Icon(Icons.home_outlined),
                                ),
                                items:
                                    filteredMaisons.map((maison) {
                                      return DropdownMenuItem(
                                        value: maison.id,
                                        child: Text(maison.adresse),
                                      );
                                    }).toList(),
                                onChanged:
                                    _selectedQuartierId == null
                                        ? null
                                        : (value) {
                                          setModalState(() {
                                            _selectedMaisonId = value;
                                          });
                                        },
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Veuillez sélectionner une maison';
                                  }
                                  return null;
                                },
                              );
                            },
                          ),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              if (_editingHabitant != null)
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    _resetForm();
                                  },
                                  child: const Text('Annuler'),
                                ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: () async {
                                  if (_formKey.currentState?.validate() ??
                                      false) {
                                    try {
                                      final habitant = Habitant(
                                        id:
                                            _editingHabitant?.id ??
                                            const Uuid().v4(),
                                        nom: _nomController.text,
                                        prenom: _prenomController.text,
                                        maisonId: _selectedMaisonId!,
                                        userId:
                                            '', // Will be set by the service
                                      );
                                      if (_editingHabitant == null) {
                                        await _habitantService.createHabitant(
                                          habitant,
                                        );
                                        if (mounted) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Habitant créé avec succès',
                                              ),
                                            ),
                                          );
                                        }
                                      } else {
                                        await _habitantService.updateHabitant(
                                          habitant,
                                        );
                                        if (mounted) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Habitant mis à jour avec succès',
                                              ),
                                            ),
                                          );
                                        }
                                      }
                                      Navigator.pop(context);
                                      _resetForm();
                                    } catch (e) {
                                      if (mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Erreur: ${e.toString()}',
                                            ),
                                          ),
                                        );
                                      }
                                    }
                                  }
                                },
                                child: Text(
                                  _editingHabitant == null
                                      ? 'Ajouter'
                                      : 'Mettre à jour',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                ),
          ),
    );
  }

  Future<void> _deleteHabitant(String id) async {
    try {
      await _habitantService.deleteHabitant(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Habitant supprimé avec succès')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erreur: ${e.toString()}')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gestion des Habitants')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openHabitantForm(),
        icon: const Icon(Icons.add),
        label: const Text('Nouvel Habitant'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder<List<Habitant>>(
          stream: _habitantService.getHabitants(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text('Erreur: ${snapshot.error}');
            }
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final habitants = snapshot.data!;
            if (habitants.isEmpty) {
              return const Center(child: Text('Aucun habitant trouvé'));
            }
            return ListView.separated(
              itemCount: habitants.length,
              separatorBuilder: (context, i) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final habitant = habitants[index];
                return FutureBuilder<Maison?>(
                  future: _maisonService.getMaison(habitant.maisonId),
                  builder: (context, maisonSnapshot) {
                    final maison = maisonSnapshot.data;
                    return Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        leading: CircleAvatar(
                          radius: 26,
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primary.withOpacity(0.15),
                          child: Text(
                            habitant.prenom.isNotEmpty
                                ? habitant.prenom[0].toUpperCase()
                                : habitant.nom.isNotEmpty
                                ? habitant.nom[0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          '${habitant.prenom} ${habitant.nom}',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        subtitle:
                            maison != null
                                ? Row(
                                  children: [
                                    const Icon(
                                      Icons.home_outlined,
                                      size: 16,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(width: 4),
                                    Flexible(
                                      child: Text(
                                        maison.adresse,
                                        style: const TextStyle(
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                                : const Text(
                                  'Chargement...',
                                  style: TextStyle(color: Colors.grey),
                                ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.visibility,
                                color: Colors.blueAccent,
                              ),
                              tooltip: 'Voir les détails',
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  '/habitant-details',
                                  arguments: habitant,
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.edit,
                                color: Colors.orange,
                              ),
                              tooltip: 'Modifier',
                              onPressed:
                                  () => _openHabitantForm(habitant: habitant),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.redAccent,
                              ),
                              tooltip: 'Supprimer',
                              onPressed: () => _deleteHabitant(habitant.id),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
