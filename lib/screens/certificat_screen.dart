import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/habitant.dart';
import '../models/certificat.dart';
import '../services/certificat_service.dart';
import '../services/habitant_service.dart';
import '../utils/pdf_generator.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'package:open_filex/open_filex.dart';

class CertificatScreen extends StatefulWidget {
  const CertificatScreen({super.key});

  @override
  State<CertificatScreen> createState() => _CertificatScreenState();
}

class _CertificatScreenState extends State<CertificatScreen> {
  final _certificatService = CertificatService();
  final _habitantService = HabitantService();
  Habitant? _selectedHabitant;
  bool _isGenerating = false;
  List<Habitant> _habitants = [];

  @override
  void initState() {
    super.initState();
    _loadHabitants();
  }

  Future<void> _loadHabitants() async {
    try {
      _habitantService.getHabitants().listen((habitants) {
        setState(() {
          _habitants = habitants;
        });
      });
    } catch (e) {
      print('Erreur lors du chargement des habitants: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Erreur lors du chargement des habitants: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _generateCertificat() async {
    if (_selectedHabitant == null) return;

    setState(() => _isGenerating = true);

    try {
      final data =
          await _certificatService.getCertificatData(_selectedHabitant!.id);
      final pdfFile = await PdfGenerator.generateCertificat(
        habitant: data['habitant'],
        maison: data['maison'],
        quartier: data['quartier'],
        proprietaire: data['proprietaire'],
      );
      final certificat = await _certificatService.createCertificat(
        _selectedHabitant!.id,
        pdfFile,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Certificat généré avec succès'),
          action: SnackBarAction(
            label: 'Voir',
            onPressed: () => _viewPdf(certificat.certificatPdfBase64),
          ),
        ),
      );
    } catch (e, stackTrace) {
      print('Erreur lors de la génération du certificat: $e');
      print('Stack trace: $stackTrace');

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isGenerating = false);
      }
    }
  }

  Future<void> _viewPdf(String base64Pdf) async {
    try {
      final bytes = base64Decode(base64Pdf);
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/certificat_temp.pdf');
      await file.writeAsBytes(bytes);
      await OpenFilex.open(file.path);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de l\'ouverture du PDF: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Générer un Certificat'),
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
              Theme.of(context).colorScheme.primary.withOpacity(0.1),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // En-tête avec icône
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.description_outlined,
                            size: 32,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Générer un Nouveau Certificat',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Sélectionnez un habitant pour générer son certificat de domicile',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Carte de sélection d'habitant
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Sélectionner un Habitant',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                          ),
                          const SizedBox(height: 16),
                          StreamBuilder<List<Habitant>>(
                            stream: _habitantService.getHabitants(),
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
                                    child: CircularProgressIndicator());
                              }

                              final habitants = snapshot.data!;
                              if (habitants.isEmpty) {
                                return const Center(
                                  child: Text('Aucun habitant disponible'),
                                );
                              }

                              return DropdownButtonFormField<Habitant>(
                                value: _selectedHabitant,
                                decoration: InputDecoration(
                                  labelText: 'Habitant',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  prefixIcon: const Icon(Icons.person_outline),
                                  filled: true,
                                  fillColor: Colors.grey[50],
                                ),
                                items: habitants.map((habitant) {
                                  return DropdownMenuItem<Habitant>(
                                    value: habitant,
                                    child: Text(
                                      '${habitant.prenom} ${habitant.nom}',
                                    ),
                                  );
                                }).toList(),
                                onChanged: (Habitant? value) {
                                  if (value != null) {
                                    setState(() => _selectedHabitant = value);
                                  }
                                },
                                validator: (value) {
                                  if (value == null) {
                                    return 'Veuillez sélectionner un habitant';
                                  }
                                  return null;
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Bouton de génération
                  ElevatedButton.icon(
                    onPressed: _selectedHabitant == null || _isGenerating
                        ? null
                        : _generateCertificat,
                    icon: _isGenerating
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Icon(Icons.description_outlined),
                    label: Text(
                      _isGenerating
                          ? 'Génération en cours...'
                          : 'Générer le Certificat',
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Liste des certificats
                  Text(
                    'Certificats Générés',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                  const SizedBox(height: 16),
                  StreamBuilder<List<Certificat>>(
                    stream: _certificatService.getCertificats(),
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
                        return const Center(child: CircularProgressIndicator());
                      }

                      final certificats = snapshot.data!;
                      if (certificats.isEmpty) {
                        return Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.description_outlined,
                                size: 48,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Aucun certificat généré',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: certificats.length,
                        itemBuilder: (context, index) {
                          final certificat = certificats[index];

                          String titleText;
                          if (_habitants.isNotEmpty) {
                            final habitant = _habitants.firstWhere(
                              (h) => h.id == certificat.habitantId,
                              orElse: () => Habitant(
                                id: '',
                                nom: 'Inconnu',
                                prenom: '',
                                maisonId: '',
                                userId: '',
                              ),
                            );
                            titleText = '${habitant.prenom} ${habitant.nom}';
                          } else {
                            titleText =
                                'Certificat #${certificat.id.substring(0, 8)}';
                          }

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.description_outlined,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              title: Text(
                                titleText,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text(
                                    'Émis le ${certificat.dateEmission.toString().split(' ')[0]}',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(certificat.statut)
                                          .withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      _getStatusText(certificat.statut),
                                      style: TextStyle(
                                        color:
                                            _getStatusColor(certificat.statut),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.visibility),
                                    onPressed: () => _viewPdf(
                                        certificat.certificatPdfBase64),
                                    tooltip: 'Voir le certificat',
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                  if (certificat.statut ==
                                      CertificatStatut.valide)
                                    IconButton(
                                      icon: const Icon(Icons.cancel_outlined),
                                      onPressed: () => _certificatService
                                          .annulerCertificat(certificat.id),
                                      tooltip: 'Annuler le certificat',
                                      color: Colors.orange,
                                    ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline),
                                    onPressed: () =>
                                        _confirmDelete(certificat.id),
                                    tooltip: 'Supprimer le certificat',
                                    color: Colors.red,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(CertificatStatut statut) {
    switch (statut) {
      case CertificatStatut.valide:
        return Colors.green;
      case CertificatStatut.expire:
        return Colors.red;
      case CertificatStatut.annule:
        return Colors.orange;
      case CertificatStatut.enAttente:
        return Colors.blue;
    }
  }

  String _getStatusText(CertificatStatut statut) {
    switch (statut) {
      case CertificatStatut.valide:
        return 'Valide';
      case CertificatStatut.expire:
        return 'Expiré';
      case CertificatStatut.annule:
        return 'Annulé';
      case CertificatStatut.enAttente:
        return 'En attente';
    }
  }

  Future<void> _confirmDelete(String certificatId) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Confirmer la suppression'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Voulez-vous vraiment supprimer ce certificat ?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Annuler'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child:
                  const Text('Supprimer', style: TextStyle(color: Colors.red)),
              onPressed: () async {
                Navigator.of(context).pop();
                await _deleteCertificat(certificatId);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteCertificat(String certificatId) async {
    try {
      await _certificatService.deleteCertificat(certificatId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Certificat supprimé avec succès'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('Erreur lors de la suppression du certificat: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Erreur lors de la suppression du certificat: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
