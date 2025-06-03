import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import '../models/habitant.dart';
import '../models/maison.dart';
import '../models/quartier.dart';

class PdfGenerator {
  static Future<File> generateCertificat({
    required Habitant habitant,
    required Maison maison,
    required Quartier quartier,
  }) async {
    final pdf = pw.Document();

    // En-tête
    final header = pw.Header(
      level: 0,
      child: pw.Text(
        'CERTIFICAT DE DOMICILE',
        style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
        textAlign: pw.TextAlign.center,
      ),
    );

    // Date d'émission
    final dateEmission = pw.Text(
      'Date d\'émission: ${DateTime.now().toString().split(' ')[0]}',
      style: const pw.TextStyle(fontSize: 12),
    );

    // Informations de l'habitant
    final habitantInfo = pw.Container(
      padding: const pw.EdgeInsets.all(20),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'INFORMATIONS DE L\'HABITANT',
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 10),
          _buildInfoRow('Nom', habitant.nom),
          _buildInfoRow('Prénom', habitant.prenom),
        ],
      ),
    );

    // Informations de l'adresse
    final adresseInfo = pw.Container(
      padding: const pw.EdgeInsets.all(20),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'ADRESSE',
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 10),
          _buildInfoRow('Adresse', maison.adresse),
          _buildInfoRow('Quartier', quartier.nom),
        ],
      ),
    );

    // Pied de page
    final footer = pw.Container(
      padding: const pw.EdgeInsets.all(20),
      child: pw.Text(
        'Ce certificat est valide pour une durée d\'un an à compter de la date d\'émission.',
        style: const pw.TextStyle(fontSize: 10),
        textAlign: pw.TextAlign.center,
      ),
    );

    // Assemblage du document
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          header,
          pw.SizedBox(height: 20),
          dateEmission,
          pw.SizedBox(height: 20),
          habitantInfo,
          pw.SizedBox(height: 20),
          adresseInfo,
          pw.SizedBox(height: 40),
          footer,
        ],
      ),
    );

    // Sauvegarde du PDF
    final output = await getTemporaryDirectory();
    final file = File('${output.path}/certificat_${habitant.id}.pdf');
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
