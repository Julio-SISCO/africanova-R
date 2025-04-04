import 'dart:typed_data';
import 'package:africanova/database/ligne_vente.dart';
import 'package:africanova/database/vente.dart';
import 'package:africanova/util/date_formatter.dart';
import 'package:africanova/widget/pdf/pdf_config.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/material.dart';

class PdfHeaderPreview extends StatelessWidget {
  final Vente vente;

  const PdfHeaderPreview({
    super.key,
    required this.vente,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(2.0),
        ),
        elevation: 0,
        color: Colors.white,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                right: 50.0,
                top: 15.0,
                left: 15.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SvgPicture.asset(
                    'assets/logos/logo.svg',
                    width: 200,
                    height: 180,
                    fit: BoxFit.contain,
                    color: Color(0xFF056148),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "FACTURE",
                        style: TextStyle(
                          fontSize: 50,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF056148),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "N° : ${vente.numFacture}",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Date : ${DateFormat('dd MMMM yyyy', 'fr').format(vente.createdAt ?? DateTime.now())}",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Divider(color: Colors.black),
            Padding(
              padding: const EdgeInsets.only(
                right: 50.0,
                top: 15.0,
                left: 50.0,
                bottom: 15.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Fournisseur",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF056148),
                        ),
                      ),
                      Text(
                        "Hédzranawoé, Lomé-Togo",
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        "(+228) 90000000",
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        "Vendeur : Anonymous",
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Client",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF056148),
                        ),
                      ),
                      Text(
                        "Anonymous Anonymous",
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        "Hédzranawoé, Lomé-Togo",
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        "(+228) 90000000",
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Divider(color: Colors.black),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 50.0,
                vertical: 15.0,
              ),
              child: buildTable(vente.lignes),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTable(List<LigneVente> lignes) {
    return Card(
      child: Table(
        columnWidths: const {
          0: FlexColumnWidth(3),
          1: FlexColumnWidth(1),
          2: FlexColumnWidth(2),
          3: FlexColumnWidth(2),
        },
        border: TableBorder(
          horizontalInside: BorderSide(width: 1),
          bottom: BorderSide(
            width: 1,
          ),
        ),
        children: [
          // En-tête
          TableRow(
            decoration: BoxDecoration(color: Color(0xFF056148)),
            children: [
              _buildHeaderCell("Article et Description"),
              _buildHeaderCell("Quantité"),
              _buildHeaderCell("Prix Unitaire"),
              _buildHeaderCell("Total"),
            ],
          ),

          ...lignes.map(
            (ligne) => TableRow(
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.zero)),
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
    );
  }

  Widget _buildHeaderCell(String text) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildArticleCell(String libelle, String description) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            libelle,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(description),
        ],
      ),
    );
  }

  Widget _buildTextCell(String text, {TextAlign textAlign = TextAlign.left}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        textAlign: textAlign,
      ),
    );
  }
}

Future<pw.Widget> buildHeader(String date, String factureNumber) async {
  final Uint8List logoBytes = await convertSvgToPng('assets/logos/logo.svg');

  return pw.Padding(
    padding: pw.EdgeInsets.only(right: 50.0, top: 15.0, left: 15.0),
    child: pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(
          width: 200,
          height: 180,
          child: pw.Image(pw.MemoryImage(logoBytes), fit: pw.BoxFit.contain),
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              "FACTURE",
              style: pw.TextStyle(
                fontSize: 50,
                fontWeight: pw.FontWeight.bold,
                color: PdfColor(0.0196, 0.3804, 0.2824),
              ),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              "N° : $factureNumber",
              style: pw.TextStyle(
                fontSize: 20,
                color: PdfColors.black,
              ),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              "Date : $date",
              style: pw.TextStyle(
                fontSize: 20,
                color: PdfColors.black,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

pw.Widget buildArticlesTable(List<LigneVente> lignes) {
  return pw.Table(
    border: pw.TableBorder(
      horizontalInside: pw.BorderSide(width: 1, color: PdfColors.black),
      bottom: pw.BorderSide(width: 1, color: PdfColors.black),
    ),
    columnWidths: {
      0: pw.FlexColumnWidth(3),
      1: pw.FlexColumnWidth(1),
      2: pw.FlexColumnWidth(2),
      3: pw.FlexColumnWidth(2),
    },
    children: [
      // En-tête de la table
      pw.TableRow(
        decoration: pw.BoxDecoration(color: PdfColor(0.0196, 0.3804, 0.2824)),
        children: [
          pw.Padding(
            padding: const pw.EdgeInsets.all(8),
            child: pw.Text(
              "Article",
              style: pw.TextStyle(
                color: PdfColors.white,
                fontWeight: pw.FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.all(8),
            child: pw.Text(
              "Qté",
              style: pw.TextStyle(
                color: PdfColors.white,
                fontWeight: pw.FontWeight.bold,
                fontSize: 14,
              ),
              textAlign: pw.TextAlign.center,
            ),
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.all(8),
            child: pw.Text(
              "Prix U.",
              style: pw.TextStyle(
                color: PdfColors.white,
                fontWeight: pw.FontWeight.bold,
                fontSize: 14,
              ),
              textAlign: pw.TextAlign.right,
            ),
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.all(8),
            child: pw.Text(
              "Total",
              style: pw.TextStyle(
                color: PdfColors.white,
                fontWeight: pw.FontWeight.bold,
                fontSize: 14,
              ),
              textAlign: pw.TextAlign.right,
            ),
          ),
        ],
      ),

      // Lignes des articles
      ...lignes.map(
        (ligne) => pw.TableRow(
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    ligne.article?.libelle ?? "Inconnu ",
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  pw.Text(ligne.article?.description ?? ""),
                ],
              ),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(
                ligne.quantite.toString(),
                textAlign: pw.TextAlign.center,
              ),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(
                "${formatMontant(ligne.article?.prixVente ?? 0)} F",
                textAlign: pw.TextAlign.right,
              ),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(
                "${formatMontant(((ligne.montant ?? 0) * ligne.quantite))} F",
                textAlign: pw.TextAlign.right,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

  //  pw.Padding(
  //   padding: pw.EdgeInsets.symmetric(horizontal: 71, vertical: 8),
  //   child: pw.Row(
  //     mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
  //     crossAxisAlignment: pw.CrossAxisAlignment.start,
  //     children: [
  //       pw.Container(
  //         width: 60,
  //         height: 60,
  //         child: pw.Image(pw.MemoryImage(logoBytes), fit: pw.BoxFit.contain),
  //       ),
  //       pw.Column(
  //         crossAxisAlignment: pw.CrossAxisAlignment.end,
  //         children: [
  //           pw.Text(
  //             "FACTURE",
  //             style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
  //           ),
  //           pw.SizedBox(height: 4),
  //           pw.Text("Date : $date", style: pw.TextStyle(fontSize: 12)),
  //           pw.Text("Facture N° : $factureNumber",
  //               style: pw.TextStyle(fontSize: 12)),
  //         ],
  //       ),
  //     ],
  //   ),
  // )