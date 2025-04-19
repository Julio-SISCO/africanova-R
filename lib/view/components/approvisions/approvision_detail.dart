import 'package:africanova/controller/image_url_controller.dart';
import 'package:africanova/database/ligne_approvision.dart';
import 'package:africanova/database/approvision.dart';
import 'package:africanova/theme/theme_provider.dart';
import 'package:africanova/util/date_formatter.dart';
import 'package:africanova/view/components/approvisions/detail_header.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ApprovisionDetail extends StatelessWidget {
  final Function(Widget) switchView;
  final Approvision approvision;

  const ApprovisionDetail({
    super.key,
    required this.approvision,
    required this.switchView,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context).themeData.colorScheme;

    return Column(
      children: [
        SizedBox(
          height: 60.0,
          child: DetailHeader(
            approvision: approvision,
            switchView: switchView,
          ),
        ),
        Expanded(
          child: Card(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4.0)),
            color: theme.primary,
            
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildInfoSection(context, theme),
                  const SizedBox(height: 16.0),
                  LayoutBuilder(builder: (context, constraints) {
                    return _buildArticlesSection(constraints.maxWidth / 4);
                  }),
                  const SizedBox(height: 16.0),
                  _buildTotalSection(theme),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoSection(BuildContext context, ColorScheme theme) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
      
      color: theme.primary,
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFournisseurInfo(),
            _buildFactureInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildFournisseurInfo() {
    final fournisseur = approvision.fournisseur;
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle("Informations du fournisseur"),
          _buildText("Nom :${fournisseur?.fullname ?? "Commun"}", isBold: true),
          if (fournisseur?.contact != null)
            _buildText("Contact :${fournisseur?.contact ?? "Inconnu"}"),
          if (fournisseur?.email != null)
            _buildText("Email :${fournisseur?.email ?? "Inconnu"}"),
          if (fournisseur?.adresse != null)
            _buildText("Adresse :${fournisseur?.adresse ?? "Inconnu"}"),
        ],
      ),
    );
  }

  Widget _buildFactureInfo() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _buildSectionTitle("Informations Facture"),
          if (approvision.createdAt != null)
            _buildText(
                "Date :${DateFormat('d MMMM yyyy', 'fr_FR').format(approvision.createdAt!)}"),
          if (approvision.employer != null)
            _buildText(
                "Fait par :${approvision.employer?.prenom ?? "Inconnu"}"),
        ],
      ),
    );
  }

  Widget _buildArticlesSection(double width) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("Liste des articles"),
        Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: approvision.lignes
              .map((ligne) =>
                  SizedBox(width: width, child: _buildArticleDetail(ligne)))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildArticleDetail(LigneApprovision ligne) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
      
      child: Row(
        children: [
          Expanded(flex: 2, child: _buildArticleImage(ligne)),
          Expanded(flex: 3, child: _buildArticleInfo(ligne)),
        ],
      ),
    );
  }

  Widget _buildArticleImage(LigneApprovision ligne) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(2), bottomLeft: Radius.circular(2)),
      child: CachedNetworkImage(
        imageUrl: ligne.article.images?.isNotEmpty == true
            ? buildUrl(ligne.article.images![0].path)
            : '',
        fit: BoxFit.fill,
        height: 100,
        placeholder: (context, url) =>
            LinearProgressIndicator(color: Colors.grey.withOpacity(.2)),
        errorWidget: (context, url, error) => Image.asset(
            'assets/images/placeholder.png',
            height: 100,
            fit: BoxFit.fill),
      ),
    );
  }

  Widget _buildArticleInfo(LigneApprovision ligne) {
    return Expanded(
      flex: 2,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildText(ligne.article.libelle ?? "Inconnu", isBold: true),
            _buildText('Prix :${formatMontant((ligne.prix ?? 0.0).toDouble())} F',
                color: Colors.blueGrey),
            _buildText('Quantité :${ligne.quantite}', color: Colors.blueGrey),
            _buildText('Total :${formatMontant(ligne.quantite * (ligne.prix ?? 0.0).toDouble())} F',
                color: Colors.blueGrey),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalSection(ColorScheme theme) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
      
      color: theme.primary,
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "Total",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${formatMontant(approvision.montantTotal)} f',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildText(String text,
      {bool isBold = false, double fontSize = 14.0, Color? color}) {
    return Text(
      text,
      style: TextStyle(
          fontWeight: isBold ? FontWeight.bold : FontWeight.w400,
          fontSize: fontSize,
          color: color),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title,
        style: const TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
            decoration: TextDecoration.underline));
  }
}
