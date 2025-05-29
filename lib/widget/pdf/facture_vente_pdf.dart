import 'package:africanova/database/vente.dart';
import 'package:africanova/util/date_formatter.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import 'dart:io';

Future<Uint8List> factureVente(Vente vente) async {
  final pdf = pw.Document();

  // Charger les polices Roboto
  final robotoRegular = pw.Font.ttf(await rootBundle.load('assets/fonts/Roboto-Regular.ttf'));
  final robotoBold = pw.Font.ttf(await rootBundle.load('assets/fonts/Roboto-Bold.ttf'));
  final robotoItalic = pw.Font.ttf(await rootBundle.load('assets/fonts/Roboto-Italic.ttf'));

  final totalLignes = vente.lignes.fold<double>(
    0,
    (sum, ligne) => sum + (ligne.montant ?? 0) * ligne.quantite,
  );

  final image = pw.MemoryImage(
    File('assets/logos/logo-light.png').readAsBytesSync(),
  );

  String formatRowValue(double? val, bool pourcent, double total) {
    if (val == null) return '0 F';
    return pourcent
        ? '${formatMontant(val * total / 100)} F'
        : '${formatMontant(val)} F';
  }

  String formatRowLabel(String label, double? val, bool pourcent) {
    return "$label ${pourcent ? '${val?.toStringAsFixed(2) ?? 0}%' : ''} : ";
  }

  pdf.addPage(pw.Page(
    margin: const pw.EdgeInsets.all(30),
    build: (_) => pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Container(
              width: 150,
              height: 130,
              child: pw.Image(image, fit: pw.BoxFit.contain),
            ),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text("FACTURE",
                    style: pw.TextStyle(
                      font: robotoBold,
                      fontSize: 22,
                      color: PdfColor.fromHex("#056148"),
                    )),
                pw.SizedBox(height: 4),
                pw.Text("Réf : ${vente.numFacture}", style: _textStyle(robotoRegular)),
                pw.SizedBox(height: 4),
                pw.Text(
                  "Date : ${DateFormat('dd MMMM yyyy', 'fr').format(vente.createdAt ?? DateTime.now())}",
                  style: _textStyle(robotoRegular),
                ),
              ],
            ),
          ],
        ),
        pw.SizedBox(height: 20),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _sectionTitle("Emmetteur", robotoBold),
                pw.Text("Hédzranawoé,\nEn face du club de Karaté,\nNon loin de la Pharmacie Hédzranawoé,\nLomé-Togo",
                    style: _textStyle(robotoRegular, size: 10)),
                pw.Text("(+228) 90802525/99026979", style: _textStyle(robotoRegular, size: 10)),
                pw.Text("Vendeur : ${vente.employer?.prenom ?? vente.initiateur?.prenom ?? 'ANOC'}",
                    style: _textStyle(robotoRegular, size: 10)),
              ],
            ),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                _sectionTitle("Adressé à", robotoBold),
                pw.Text(vente.client?.fullname ?? 'Commun', style: _textStyle(robotoRegular, size: 10)),
                pw.Text(vente.client?.adresse ?? '', style: _textStyle(robotoRegular, size: 10)),
                pw.Text(vente.client?.contact ?? '', style: _textStyle(robotoRegular, size: 10)),
              ],
            ),
          ],
        ),
        pw.SizedBox(height: 20),
        pw.Table(
          border: pw.TableBorder(
            horizontalInside: pw.BorderSide(width: 1),
            bottom: pw.BorderSide(width: 1),
          ),
          columnWidths: {
            0: pw.FlexColumnWidth(3),
            1: pw.FlexColumnWidth(2),
            2: pw.FlexColumnWidth(2),
            3: pw.FlexColumnWidth(2),
          },
          children: [
            pw.TableRow(
              decoration: pw.BoxDecoration(color: PdfColor.fromHex("#056148")),
              children: [
                _buildHeaderCell("Designation", robotoBold),
                _buildHeaderCell("Quantité", robotoBold),
                _buildHeaderCell("P.U. HT", robotoBold),
                _buildHeaderCell("Total", robotoBold),
              ],
            ),
            ...vente.lignes.map((ligne) => pw.TableRow(children: [
                  _buildArticleCell(ligne.article?.libelle ?? "Inconnu", ligne.article?.description ?? "", robotoRegular),
                  _buildTextCell(ligne.quantite.toString(), robotoRegular),
                  _buildTextCell("${formatMontant(ligne.montant ?? 0)} F", robotoRegular),
                  _buildTextCell("${formatMontant((ligne.montant ?? 0) * ligne.quantite)} F", robotoRegular),
                ])),
          ],
        ),
        pw.SizedBox(height: 20),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.end,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                _buildSummaryRow("TOTAL HT: ", " ${formatMontant(totalLignes)} F",
                    isBold: true, color: PdfColor.fromHex("#056148"), font: robotoBold),
                pw.SizedBox(height: 8),
                _buildSummaryRow(
                  formatRowLabel("TVA", vente.taxe, vente.taxeInPercent == true),
                  formatRowValue(vente.taxe, vente.taxeInPercent == true, totalLignes),
                  isBold: true,
                  font: robotoRegular,
                ),
                pw.SizedBox(height: 8),
                _buildSummaryRow(
                  formatRowLabel("REMISE", vente.remise, vente.remiseInPercent == true),
                  formatRowValue(vente.remise, vente.remiseInPercent == true, totalLignes),
                  isBold: true,
                  font: robotoRegular,
                ),
                pw.SizedBox(height: 8),
                pw.Container(
                  color: PdfColor.fromHex("#056148"),
                  height: 30,
                  padding: pw.EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                  child: _buildSummaryRow(
                    "TOTAL TTC : ",
                    " ${formatMontant(vente.montantTotal)} F",
                    isBold: true,
                    fontSize: 12,
                    color: PdfColors.white,
                    font: robotoBold,
                  ),
                ),
              ],
            ),
          ],
        ),
        pw.Spacer(flex: 2),
        pw.Align(
          alignment: pw.Alignment.bottomRight,
          child: pw.Text("Signature", style: _textStyle(robotoItalic, size: 10, bold: true)),
        ),
        pw.Spacer(),
        pw.Align(
          alignment: pw.Alignment.bottomLeft,
          child: pw.Text(
            "MERCI POUR VOS ACHATS !",
            style: _textStyle(robotoItalic, size: 8, bold: true, color: PdfColor.fromHex("#056148")),
          ),
        ),
      ],
    ),
  ));

  return pdf.save();
}

pw.TextStyle _textStyle(pw.Font font, {double size = 11, bool bold = false, PdfColor color = PdfColors.black}) {
  return pw.TextStyle(
    font: font,
    fontSize: size,
    fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
    color: color,
  );
}

pw.Widget _buildHeaderCell(String text, pw.Font font) => pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(text, style: _textStyle(font, size: 14, bold: true, color: PdfColors.white)),
    );

pw.Widget _buildArticleCell(String libelle, String description, pw.Font font) => pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(libelle, style: _textStyle(font, size: 12, bold: true)),
          pw.Text(description, style: _textStyle(font, size: 10)),
        ],
      ),
    );

pw.Widget _buildTextCell(String text, pw.Font font) => pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(text, style: _textStyle(font, size: 10)),
    );

pw.Widget _buildSummaryRow(String label, String value,
        {bool isBold = false, PdfColor color = PdfColors.black, double fontSize = 10, required pw.Font font}) =>
    pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.center,
      children: [
        pw.Text(label, style: _textStyle(font, size: fontSize, bold: isBold, color: color)),
        pw.Text(value, style: _textStyle(font, size: fontSize + 1, bold: isBold, color: color)),
      ],
    );

pw.Widget _sectionTitle(String title, pw.Font font) => pw.Text(
      title,
      style: _textStyle(font, size: 16, bold: true, color: PdfColor.fromHex("#056148")),
    );
