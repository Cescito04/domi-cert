import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/quartier.dart';
import '../models/recensement_data.dart';
import '../services/quartier_service.dart';
import '../services/recensement_service.dart';
import 'package:dropdown_search/dropdown_search.dart';

class QuartierScreen extends StatefulWidget {
  final Quartier? quartier;

  const QuartierScreen({super.key, this.quartier});

  @override
  State<QuartierScreen> createState() => _QuartierScreenState();
}

class _QuartierScreenState extends State<QuartierScreen> {
  final _formKey = GlobalKey<FormState>();
  final _quartierService = QuartierService();
  final _recensementService = RecensementService();
  final _chefPrenomController = TextEditingController();
  final _chefNomController = TextEditingController();
  String? _selectedCommune;
  String? _selectedQuartier;
  List<String> _communes = [];
  List<String> _quartiers = [];
  bool _isLoading = true;
  String? _error;
  Quartier? _editingQuartier;

  @override
  void initState() {
    super.initState();
    _loadData();

    if (widget.quartier != null) {
      _editingQuartier = widget.quartier;
      _selectedCommune = widget.quartier!.commune;
      _selectedQuartier = widget.quartier!.nom;

      _chefPrenomController.text = widget.quartier!.chefPrenom;
      _chefNomController.text = widget.quartier!.chefNom;

      if (_selectedCommune != null && _selectedCommune!.isNotEmpty) {
        _quartiers =
            _recensementService.getQuartiersForCommune(_selectedCommune!);
      }
    }
  }

  @override
  void dispose() {
    _chefPrenomController.dispose();
    _chefNomController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      await _recensementService.loadData();
      setState(() {
        _communes = _recensementService.getCommunes();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _onQuartierChanged(String? quartier) {
    setState(() {
      _selectedQuartier = quartier;
    });
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _chefPrenomController.clear();
    _chefNomController.clear();
    setState(() {
      _selectedCommune = null;
      _selectedQuartier = null;
      _editingQuartier = null;
      _quartiers = [];
    });
  }

  Future<void> _saveQuartier() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        final quartier = Quartier(
          id: _editingQuartier?.id ?? const Uuid().v4(),
          nom: _selectedQuartier!,
          commune: _selectedCommune!,
          userId: widget.quartier?.userId ?? '',
          chefPrenom: _chefPrenomController.text,
          chefNom: _chefNomController.text,
        );

        if (_editingQuartier == null) {
          await _quartierService.createQuartier(quartier);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Quartier créé avec succès'),
              ),
            );
          }
        } else {
          await _quartierService.updateQuartier(quartier);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Quartier mis à jour avec succès'),
              ),
            );
          }
        }
        if (mounted) {
          Navigator.pop(context);
        }
        _resetForm();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur: ${e.toString()}'),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // The back button is automatically provided by Scaffold
        automaticallyImplyLeading: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Erreur: ${_error!}'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // New visual header for the screen
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24.0),
                          child: Column(
                            children: [
                              Icon(
                                widget.quartier == null
                                    ? Icons.add_location_alt_outlined
                                    : Icons.edit_location_alt_outlined,
                                size: 50,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                widget.quartier == null
                                    ? 'Ajouter un Nouveau Quartier'
                                    : 'Modifier le Quartier',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        Card(
                          elevation: 4,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Commune',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                DropdownSearch<String>(
                                  popupProps: PopupProps.menu(
                                    showSearchBox: true,
                                    searchFieldProps: TextFieldProps(
                                      decoration: InputDecoration(
                                        labelText: 'Rechercher une commune',
                                        prefixIcon: Icon(Icons.search),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        filled: true,
                                        fillColor: Colors.grey[50],
                                      ),
                                    ),
                                  ),
                                  items: _communes,
                                  onChanged: (String? commune) {
                                    setState(() {
                                      _selectedCommune = commune;
                                      _selectedQuartier = null;
                                      _quartiers = [];
                                      if (commune != null) {
                                        _quartiers = [
                                          ..._recensementService
                                              .getQuartiersForCommune(commune)
                                        ];
                                      }
                                    });
                                  },
                                  selectedItem: _selectedCommune,
                                  dropdownDecoratorProps:
                                      DropDownDecoratorProps(
                                    dropdownSearchDecoration: InputDecoration(
                                      labelText: 'Commune',
                                      prefixIcon:
                                          Icon(Icons.location_city_outlined),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      filled: true,
                                      fillColor: Colors.grey[50],
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Veuillez sélectionner une commune';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Card(
                          elevation: 4,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Quartier',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                if (_selectedCommune != null &&
                                    _quartiers.isNotEmpty)
                                  DropdownSearch<String>(
                                    key: ValueKey(_selectedCommune),
                                    popupProps: PopupProps.menu(
                                      showSearchBox: true,
                                      searchFieldProps: TextFieldProps(
                                        decoration: InputDecoration(
                                          labelText: 'Rechercher un quartier',
                                          prefixIcon: Icon(Icons.search),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          filled: true,
                                          fillColor: Colors.grey[50],
                                        ),
                                      ),
                                    ),
                                    items: _quartiers,
                                    onChanged: _onQuartierChanged,
                                    selectedItem: _selectedQuartier,
                                    enabled: _selectedCommune != null,
                                    dropdownDecoratorProps:
                                        DropDownDecoratorProps(
                                      dropdownSearchDecoration: InputDecoration(
                                        labelText: 'Quartier',
                                        prefixIcon: Icon(Icons.apartment),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        filled: true,
                                        fillColor: Colors.grey[50],
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Veuillez sélectionner un quartier';
                                      }
                                      return null;
                                    },
                                  )
                                else if (_selectedCommune != null &&
                                    _quartiers.isEmpty &&
                                    !_isLoading)
                                  Padding(
                                    padding:
                                        EdgeInsets.symmetric(vertical: 8.0),
                                    child: Text(
                                      'Aucun quartier trouvé pour cette commune.',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  )
                                else if (_selectedCommune == null)
                                  Padding(
                                    padding:
                                        EdgeInsets.symmetric(vertical: 8.0),
                                    child: Text(
                                      'Veuillez sélectionner une commune d\'abord.',
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Card(
                          elevation: 4,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Informations du Chef de Quartier',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _chefPrenomController,
                                  decoration: InputDecoration(
                                    labelText: 'Prénom du Chef',
                                    prefixIcon: Icon(Icons.person_outline),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    filled: true,
                                    fillColor: Colors.grey[50],
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Veuillez entrer le prénom du chef';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: _chefNomController,
                                  decoration: InputDecoration(
                                    labelText: 'Nom du Chef',
                                    prefixIcon: Icon(Icons.person_outline),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    filled: true,
                                    fillColor: Colors.grey[50],
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Veuillez entrer le nom du chef';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              style: TextButton.styleFrom(
                                foregroundColor:
                                    Theme.of(context).colorScheme.primary,
                              ),
                              child: const Text('Annuler'),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: _saveQuartier,
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    Theme.of(context).colorScheme.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 12),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                              child: Text(widget.quartier == null
                                  ? 'Ajouter'
                                  : 'Mettre à jour'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
    );
  }
}
