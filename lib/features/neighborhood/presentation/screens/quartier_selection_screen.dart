import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';
import '../../domain/models/recensement_data.dart';
import '../../data/services/recensement_service.dart';

class QuartierSelectionScreen extends StatefulWidget {
  const QuartierSelectionScreen({super.key});

  @override
  State<QuartierSelectionScreen> createState() =>
      _QuartierSelectionScreenState();
}

class _QuartierSelectionScreenState extends State<QuartierSelectionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _recensementService = RecensementService();
  String? _selectedCommune;
  String? _selectedQuartier;
  List<String> _availableQuartiers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      await _recensementService.loadData();
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur de chargement: $e')),
        );
      }
    }
  }

  void _onCommuneChanged(String? commune) {
    setState(() {
      _selectedCommune = commune;
      _selectedQuartier = null;
      if (commune != null) {
        _availableQuartiers =
            _recensementService.getQuartiersForCommune(commune);
      } else {
        _availableQuartiers = [];
      }
    });
  }

  void _onSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      final selection = QuartierSelection(
        commune: _selectedCommune!,
        quartier: _selectedQuartier!,
      );
      Navigator.pop(context, selection.toJson());
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sélection du Quartier'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
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
                          popupProps: const PopupProps.menu(
                            showSearchBox: true,
                            searchFieldProps: TextFieldProps(
                              decoration: InputDecoration(
                                labelText: 'Rechercher une commune',
                                prefixIcon: Icon(Icons.search),
                              ),
                            ),
                          ),
                          items: _recensementService.getCommunes(),
                          onChanged: _onCommuneChanged,
                          selectedItem: _selectedCommune,
                          itemAsString: (String item) => item,
                          compareFn: (item1, item2) => item1 == item2,
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
                        DropdownSearch<String>(
                          popupProps: const PopupProps.menu(
                            showSearchBox: true,
                            searchFieldProps: TextFieldProps(
                              decoration: InputDecoration(
                                labelText: 'Rechercher un quartier',
                                prefixIcon: Icon(Icons.search),
                              ),
                            ),
                          ),
                          items: _availableQuartiers,
                          onChanged: (value) {
                            setState(() {
                              _selectedQuartier = value;
                            });
                          },
                          selectedItem: _selectedQuartier,
                          enabled: _selectedCommune != null,
                          itemAsString: (String item) => item,
                          compareFn: (item1, item2) => item1 == item2,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez sélectionner un quartier';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _onSubmit,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text(
                    'Valider',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
