import 'package:africanova/database/vente.dart';
import 'package:africanova/util/date_formatter.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:io';
import 'package:path_provider/path_provider.dart';

Future<void> generateAndPrintPdf(Vente vente) async {
  final pdf = pw.Document();

  pdf.addPage(
    pw.Page(
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Container(
                  width: 200,
                  height: 180,
                  child: pw.Image(
                    pw.MemoryImage(
                      File('assets/logos/logo.svg').readAsBytesSync(),
                    ),
                    fit: pw.BoxFit.contain,
                  ),
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      "FACTURE",
                      style: pw.TextStyle(
                        fontSize: 50,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColor.fromHex("#056148"),
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      "N° : ${vente.numFacture}",
                      style: pw.TextStyle(
                        fontSize: 18,
                        color: PdfColors.black,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      "Date : ${DateFormat('dd MMMM yyyy', 'fr').format(vente.createdAt ?? DateTime.now())}",
                      style: pw.TextStyle(
                        fontSize: 18,
                        color: PdfColors.black,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            pw.Divider(color: PdfColors.black),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      "Fournisseur",
                      style: pw.TextStyle(
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColor.fromHex("#056148"),
                      ),
                    ),
                    pw.Text("Hédzranawoé, Lomé-Togo"),
                    pw.Text("(+228) 90000000"),
                    pw.Text("Vendeur : Anonymous"),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      "Client",
                      style: pw.TextStyle(
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColor.fromHex("#056148"),
                      ),
                    ),
                    pw.Text("Anonymous Anonymous"),
                    pw.Text("Hédzranawoé, Lomé-Togo"),
                    pw.Text("(+228) 90000000"),
                  ],
                ),
              ],
            ),
            pw.Divider(color: PdfColors.black),
            pw.Table(
              border: pw.TableBorder.all(),
              columnWidths: {
                0: pw.FlexColumnWidth(3),
                1: pw.FlexColumnWidth(1),
                2: pw.FlexColumnWidth(2),
                3: pw.FlexColumnWidth(2),
              },
              children: [
                pw.TableRow(
                  decoration: pw.BoxDecoration(
                    color: PdfColor.fromHex("#056148"),
                  ),
                  children: [
                    _buildHeaderCell("Article et Description"),
                    _buildHeaderCell("Quantité"),
                    _buildHeaderCell("Prix Unitaire"),
                    _buildHeaderCell("Total"),
                  ],
                ),
                ...vente.lignes.map(
                  (ligne) => pw.TableRow(
                    children: [
                      _buildArticleCell(
                        ligne.article?.libelle ?? "Inconnu",
                        ligne.article?.description ?? "",
                      ),
                      _buildTextCell(ligne.quantite.toString()),
                      _buildTextCell(
                        "${formatMontant(ligne.montant ?? 0)} F",
                      ),
                      _buildTextCell(
                        "${formatMontant((ligne.montant ?? 0) * ligne.quantite)} F",
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        );
      },
    ),
  );

  final output = await getTemporaryDirectory();
  final file = File("${output.path}/facture.pdf");
  await file.writeAsBytes(await pdf.save());
}

pw.Widget _buildHeaderCell(String text) {
  return pw.Padding(
    padding: const pw.EdgeInsets.all(8.0),
    child: pw.Text(
      text,
      style: pw.TextStyle(
        color: PdfColors.white,
        fontWeight: pw.FontWeight.bold,
        fontSize: 14,
      ),
    ),
  );
}

pw.Widget _buildArticleCell(String libelle, String description) {
  return pw.Padding(
    padding: const pw.EdgeInsets.all(8.0),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          libelle,
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
        ),
        pw.Text(description),
      ],
    ),
  );
}

pw.Widget _buildTextCell(String text, {pw.TextAlign textAlign = pw.TextAlign.left}) {
  return pw.Padding(
    padding: const pw.EdgeInsets.all(8.0),
    child: pw.Text(
      text,
      textAlign: textAlign,
    ),
  );
}
