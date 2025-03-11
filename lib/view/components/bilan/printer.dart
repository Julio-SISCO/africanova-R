import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:pluto_grid/pluto_grid.dart';

Future<Uint8List> generatePDF({
  required List<PlutoRow> rows,
  required String period,
}) async {
  final pdf = pw.Document();

  final font = pw.Font.ttf(
    await rootBundle.load("assets/fonts/Inter-VariableFont_opsz.ttf"),
  );

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4.landscape,
      margin: pw.EdgeInsets.symmetric(horizontal: 40.0, vertical: 20.0),
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            pw.Text(
              "Rapport des Ventes par Employer".toUpperCase(),
              style: pw.TextStyle(
                fontSize: 16.0,
                font: font,
                fontWeight: pw.FontWeight.bold,
                decoration: pw.TextDecoration.underline,
              ),
            ),
            pw.SizedBox(height: 5),
            pw.Center(
              child: pw.Text(
                period.toUpperCase(),
                style: pw.TextStyle(
                  font: font,
                  fontSize: 10.0,
                  color: PdfColors.blueGrey,
                ),
              ),
            ),
            pw.SizedBox(height: 20),
            pw.Table.fromTextArray(
              headers: [
                "Employer",
                "Ventes",
                "Services",
                "Totaux",
                "% Ventes",
                "% Services",
                "% Totaux"
              ],
              data: rows.map((row) {
                return [
                  row.cells["vendeur"]!.value,
                  row.cells["vente"]!.value,
                  row.cells["service"]!.value,
                  row.cells["total"]!.value,
                  row.cells["p_vente"]!.value,
                  row.cells["p_service"]!.value,
                  row.cells["p_total"]!.value,
                ];
              }).toList(),
              border: pw.TableBorder.all(color: PdfColors.grey),
              cellAlignments: {
                0: pw.Alignment.centerLeft,
                1: pw.Alignment.center,
                2: pw.Alignment.center,
                3: pw.Alignment.center,
                4: pw.Alignment.center,
                5: pw.Alignment.center,
                6: pw.Alignment.center,
              },
              headerAlignments: {
                0: pw.Alignment.centerLeft,
                1: pw.Alignment.center,
                2: pw.Alignment.center,
                3: pw.Alignment.center,
                4: pw.Alignment.center,
                5: pw.Alignment.center,
                6: pw.Alignment.center,
              },
              cellStyle: pw.TextStyle(
                font: font,
                fontSize: 8,
              ),
              headerStyle: pw.TextStyle(
                font: font,
                color: PdfColors.white,
                fontSize: 10,
                fontWeight: pw.FontWeight.bold,
              ),
              headerDecoration:
                  pw.BoxDecoration(color: PdfColor(0.149, 0.176, 0.302)),
            ),
          ],
        );
      },
    ),
  );
  return pdf.save();
}
