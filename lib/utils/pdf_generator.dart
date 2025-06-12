import 'dart:io';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import '../models/habitant.dart';
import '../models/maison.dart';
import '../models/quartier.dart';
import '../models/proprietaire.dart';

class PdfGenerator {
  static Future<File> generateCertificate({
    required Habitant habitant,
    required Maison maison,
    required Quartier quartier,
    required Proprietaire proprietaire,
  }) async {
    final pdf = pw.Document();

    final stampImage = await rootBundle.load('assets/images/tampon.png');
    final stampImageBytes = stampImage.buffer.asUint8List();
    final stampImagePdf = pw.MemoryImage(stampImageBytes);

    // En-tête du certificat
    final header = pw.Center(
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Text(
            'RÉPUBLIQUE DU SÉNÉGAL',
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
            ),
            textAlign: pw.TextAlign.center,
          ),
          pw.SizedBox(height: 10),
          pw.Text(
            'COMMUNE DE ${quartier.commune.toUpperCase()}',
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
            ),
            textAlign: pw.TextAlign.center,
          ),
          pw.SizedBox(height: 40),
          pw.Text(
            'CERTIFICAT DE DOMICILE',
            style: pw.TextStyle(
              fontSize: 24,
              fontWeight: pw.FontWeight.bold,
              letterSpacing: 1.5,
            ),
            textAlign: pw.TextAlign.center,
          ),
          //pw.SizedBox(height: 40),
        ],
      ),
    );

    // Corps du certificat
    final body = pw.Container(
      padding: const pw.EdgeInsets.symmetric(vertical: 20),
      child: pw.Text(
        'Je soussigné Monsieur ${quartier.chefNom} ${quartier.chefPrenom}, Délégué de quartier ${quartier.nom}, atteste que M. ${habitant.nom} ${habitant.prenom} est domicilié dans mon quartier chez M. ${proprietaire.nom}, ${maison.adresse}.',
        style: const pw.TextStyle(fontSize: 18),
        textAlign: pw.TextAlign.justify,
      ),
    );

    // Pied de page avec signature et date
    final footer = pw.Container(
      padding: const pw.EdgeInsets.only(top: 50),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Signature à gauche
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Le délégué du quartier',
                style: const pw.TextStyle(fontSize: 14),
              ),
              pw.SizedBox(height: 20),
              pw.Stack(
                alignment: pw.Alignment.center,
                children: [
                  pw.Opacity(
                    opacity: 0.7,
                    child: pw.Image(
                      stampImagePdf,
                      width: 100,
                      height: 100,
                    ),
                  ),
                  pw.Text(
                    '${quartier.chefNom} ${quartier.chefPrenom}',
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          // Date à droite
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                'fait à ${quartier.commune}, le ${DateTime.now().toString().split(' ')[0]}',
                style: const pw.TextStyle(fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );

    // Assemblage du document
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Center(
            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                header,
                body,
                footer,
              ],
            ),
          ),
        ],
      ),
    );

    final file =
        File('${(await getTemporaryDirectory()).path}/certificate.pdf');
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  static pw.Widget _buildInfoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 5),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 100,
            child: pw.Text(
              label,
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.Expanded(child: pw.Text(value)),
        ],
      ),
    );
  }
}
