import 'package:africanova/controller/image_url_controller.dart';
import 'package:africanova/database/ligne_vente.dart';
import 'package:africanova/database/vente.dart';
import 'package:africanova/theme/theme_provider.dart';
import 'package:africanova/util/date_formatter.dart';
import 'package:africanova/view/components/ventes/detail_header.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class FactureVente extends StatelessWidget {
  final Function(Widget) switchView;
  final Vente vente;

  const FactureVente({
    super.key,
    required this.vente,
    required this.switchView,
  });

  @override
  Widget build(BuildContext context) {
    final totalLignes = vente.lignes.fold<double>(
        0, (sum, ligne) => sum + (ligne.montant ?? 0) * ligne.quantite);

    String calcLigne(double? val, bool pourcent) {
      if (val == null) return '0 F';
      return pourcent
          ? '${formatMontant(val * totalLignes / 100)} F'
          : '${formatMontant(val)} F';
    }

    String formatLabel(String libelle, double? val, bool pourcent) {
      return "$libelle ${pourcent ? '${val?.toStringAsFixed(2) ?? 0}%' : ''} : ";
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(
            height: 60.0,
            child: DetailHeader(
              vente: vente,
              switchView: switchView,
            ),
          ),
          Container(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height * 0.85,
            ),
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(2)),
              elevation: 0,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoHeader(),
                    SizedBox(height: 20),
                    _buildArticles(context),
                    SizedBox(height: 20),
                    _buildMontants(
                      totalLignes: totalLignes,
                      context: context,
                      tvaLabel: formatLabel(
                          "TVA", vente.taxe, vente.taxeInPercent == true),
                      tvaValue:
                          calcLigne(vente.taxe, vente.taxeInPercent == true),
                      remiseLabel: formatLabel("REMISE", vente.remise,
                          vente.remiseInPercent == true),
                      remiseValue: calcLigne(
                          vente.remise, vente.remiseInPercent == true),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _infoBloc("FACTURE", [
          "N° : ${vente.numFacture}",
          "Date : ${DateFormat('dd MMMM yyyy', 'fr').format(vente.createdAt ?? DateTime.now())}",
          "Vendeur : ${vente.employer?.prenom ?? vente.initiateur?.prenom ?? 'ANOC'}",
        ]),
        _infoBloc(
            "INFO CLIENT",
            [
              vente.client?.fullname ?? 'Commun',
              vente.client?.adresse ?? 'Commun',
              vente.client?.contact ?? 'Commun',
            ],
            alignEnd: true),
      ],
    );
  }

  Widget _infoBloc(String title, List<String> lines, {bool alignEnd = false}) {
    return Column(
      crossAxisAlignment:
          alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              color: Color(0xFF056148),
            )),
        for (var line in lines)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(line, style: const TextStyle(fontSize: 16)),
          ),
      ],
    );
  }

  Widget _buildArticles(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final width = (constraints.maxWidth - 25) / 5;
      return Wrap(
        alignment: WrapAlignment.start,
        children: vente.lignes
            .map((ligne) => SizedBox(
                  width: width,
                  child: _buildArticleDetail(ligne, context),
                ))
            .toList(),
      );
    });
  }

  Widget _buildMontants({
    required double totalLignes,
    required BuildContext context,
    required String tvaLabel,
    required String tvaValue,
    required String remiseLabel,
    required String remiseValue,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _buildSummaryRow("MONTANT : ", " ${formatMontant(totalLignes)} F",
                isBold: true, fontSize: 18, color: const Color(0xFF056148)),
            SizedBox(height: 8),
            _buildSummaryRow(tvaLabel, tvaValue, isBold: true),
            SizedBox(height: 8),
            _buildSummaryRow(remiseLabel, remiseValue, isBold: true),
            SizedBox(height: 10),
            Container(
              color: const Color(0xFF056148),
              height: 45,
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
              child: _buildSummaryRow(
                  "TOTAL A PAYER : ", " ${formatMontant(vente.montantTotal)} F",
                  isBold: true, fontSize: 18, color: Colors.white),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value,
      {bool isBold = false, Color? color, double fontSize = 16.0}) {
    final style = TextStyle(
      fontSize: fontSize,
      fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
      color: color,
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(label, style: style),
        Text(value, style: style.copyWith(fontSize: fontSize + 1)),
      ],
    );
  }

  Widget _buildArticleDetail(LigneVente ligne, BuildContext context) {
    final imagePath = ligne.article?.images?.firstOrNull?.path;
    final imageUrl = imagePath != null ? buildUrl(imagePath) : null;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      margin: const EdgeInsets.all(4),
      elevation: 0,
      color: Provider.of<ThemeProvider>(context).themeData.colorScheme.primary,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                bottomLeft: Radius.circular(4),
              ),
              child: imageUrl != null
                  ? CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.fill,
                      height: 100,
                      placeholder: (_, __) => LinearProgressIndicator(
                          color: Colors.grey.withOpacity(.2)),
                      errorWidget: (_, __, ___) => Image.asset(
                        'assets/images/placeholder.png',
                        height: 100,
                        fit: BoxFit.fill,
                      ),
                    )
                  : Image.asset(
                      'assets/images/placeholder.png',
                      height: 100,
                      fit: BoxFit.fill,
                    ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _textLine(ligne.article?.libelle ?? "Inconnu",
                      fontWeight: FontWeight.w600, size: 14),
                  _textLine('Prix : ${ligne.montant?.toInt() ?? 0} F'),
                  _textLine('Quantité : ${ligne.quantite}'),
                  _textLine(
                      'Total : ${ligne.quantite * (ligne.montant ?? 0).toInt()} F'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _textLine(String text,
      {FontWeight fontWeight = FontWeight.w500, double size = 13}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
            color: Colors.blueGrey, fontWeight: fontWeight, fontSize: size),
      ),
    );
  }
}
