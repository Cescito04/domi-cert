import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:domicert/features/certificate/domain/models/certificat.dart';

class CertificatVerificationScreen extends StatefulWidget {
  const CertificatVerificationScreen({Key? key}) : super(key: key);

  @override
  State<CertificatVerificationScreen> createState() =>
      _CertificatVerificationScreenState();
}

class _CertificatVerificationScreenState
    extends State<CertificatVerificationScreen> {
  Certificat? certificat;
  Map<String, dynamic>? habitantData;
  bool isLoading = true;
  String? error;
  String? certificatId;

  @override
  void initState() {
    super.initState();
    _loadCertificat();
  }

  void _loadCertificat() async {
    setState(() {
      isLoading = true;
      error = null;
    });
    try {
      // Get certificat_id from URL
      final uri = Uri.base;
      final segments = uri.pathSegments;
      certificatId = segments.isNotEmpty ? segments.last : null;
      if (certificatId == null || certificatId!.isEmpty) {
        setState(() {
          error = 'Certificat ID not found in URL.';
          isLoading = false;
        });
        return;
      }
      // Fetch certificat from Firestore
      final doc = await FirebaseFirestore.instance
          .collection('certificats')
          .doc(certificatId)
          .get();
      if (!doc.exists) {
        setState(() {
          error = 'Certificat not found.';
          isLoading = false;
        });
        return;
      }
      certificat =
          Certificat.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      // Fetch habitant info
      final habitantDoc = await FirebaseFirestore.instance
          .collection('habitants')
          .doc(certificat!.habitantId)
          .get();
      habitantData = habitantDoc.data();
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = 'Error: $e';
        isLoading = false;
      });
    }
  }

  Future<void> _markAsConsulted() async {
    if (certificatId == null) return;
    setState(() {
      isLoading = true;
    });
    await FirebaseFirestore.instance
        .collection('certificats')
        .doc(certificatId)
        .update({
      'statut': CertificatStatut.annule.toString(),
    });
    _loadCertificat();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (error != null) {
      return Scaffold(
        body: Center(
            child: Text(error!, style: const TextStyle(color: Colors.red))),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Certificate Verification')),
      body: Center(
        child: Card(
          margin: const EdgeInsets.all(24),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Certificate ID: ${certificat!.id}',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                if (habitantData != null) ...[
                  Text(
                      'Name: ${habitantData!['prenom']} ${habitantData!['nom']}'),
                  Text('Address: ${habitantData!['adresse'] ?? ''}'),
                ],
                Text(
                    'Issued: ${certificat!.dateEmission.toString().split(' ')[0]}'),
                Text(
                    'Expires: ${certificat!.dateExpiration.toString().split(' ')[0]}'),
                const SizedBox(height: 12),
                Text(
                  'Status: ${certificat!.statut.toString().split('.').last}',
                  style: TextStyle(
                    color: certificat!.statut == CertificatStatut.valide
                        ? Colors.green
                        : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                if (certificat!.statut == CertificatStatut.valide)
                  ElevatedButton(
                    onPressed: _markAsConsulted,
                    child: const Text('Mark as Consulted (Invalidate)'),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
