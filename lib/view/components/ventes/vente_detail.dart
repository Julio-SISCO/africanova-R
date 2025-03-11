import 'package:africanova/controller/image_url_controller.dart';
import 'package:africanova/database/ligne_vente.dart';
import 'package:africanova/database/vente.dart';
import 'package:africanova/theme/theme_provider.dart';
import 'package:africanova/view/components/ventes/detail_header.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class VenteDetail extends StatelessWidget {
  final Function(Widget) switchView;
  final Vente vente;
  const VenteDetail({super.key, required this.vente, required this.switchView});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 60.0,
          child: DetailHeader(
            vente: vente,
            switchView: (Widget w) => switchView(w),
          ),
        ),
        Expanded(
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(2.0),
            ),
            color: Provider.of<ThemeProvider>(context)
                .themeData
                .colorScheme
                .primary,
            elevation: 0.0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.max,
              children: [
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(2.0),
                  ),
                  elevation: 0.0,
                  margin: EdgeInsets.all(0.0),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(2.0),
                    ),
                    elevation: 0.0,
                    color: Provider.of<ThemeProvider>(context)
                        .themeData
                        .colorScheme
                        .primary,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 10.0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  "Informations du client",
                                  style: TextStyle(
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.bold,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                                SizedBox(height: 8.0),
                                Text(
                                  "Nom : ${vente.client?.fullname ?? "Commun"}",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (vente.client != null &&
                                    vente.client!.contact != null)
                                  Text(
                                    "Contact : ${vente.client?.contact ?? "Inconnu"}",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                if (vente.client != null &&
                                    vente.client!.email != null)
                                  Text(
                                    "Email : ${vente.client?.email ?? "Inconnu"}",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                if (vente.client != null &&
                                    vente.client!.adresse != null)
                                  Text(
                                    "Adresse : ${vente.client?.adresse ?? "Inconnu"}",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  "Informations Facture",
                                  style: TextStyle(
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.bold,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                                SizedBox(height: 8.0),
                                Text(
                                  "Facture N° : ${vente.numFacture ?? DateFormat('ymsd').format(DateTime.now())}",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (vente.createdAt != null)
                                  Text(
                                    "Date : ${DateFormat('d MMMM yyyy', 'fr_FR').format(vente.createdAt!)}",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                if (vente.employer != null)
                                  Text(
                                    "Vendeur : ${vente.employer?.prenom ?? "Inconnu"}",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                if (vente.employer == null)
                                  Text(
                                    "Vendeur : ${vente.initiateur?.prenom ?? "Inconnu"}",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16.0),
                Text(
                  "Liste des articles",
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4.0),
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(2.0),
                  ),
                  elevation: 0.0,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      double totalWidth = constraints.maxWidth;
                      return Wrap(
                        children: [
                          ...List.generate(
                            vente.lignes.length,
                            (index) {
                              return SizedBox(
                                width: (totalWidth - 16) / 4,
                                child: _buildArticleDetail(
                                  vente.lignes[index],
                                  context,
                                ),
                              );
                            },
                          ),
                        ],
                      );
                    },
                  ),
                ),
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(2.0),
                  ),
                  elevation: 0.0,
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(2.0),
                    ),
                    margin: EdgeInsets.all(4.0),
                    elevation: 0.0,
                    color: Provider.of<ThemeProvider>(context)
                        .themeData
                        .colorScheme
                        .primary,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12.0,
                        vertical: 12.0,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                Text(
                                  "Status",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  vente.status == 'en_attente'
                                      ? "EN ATTENTE"
                                      : vente.status?.toUpperCase() ??
                                          "EN ATTENTE",
                                  style: TextStyle(
                                    color: vente.status == null
                                        ? Colors.orange
                                        : vente.status == "complete"
                                            ? Colors.green[700]
                                            : Colors.red[700],
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              children: [
                                Text(
                                  "Taxes",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                if (vente.designationTaxe != null)
                                  Text(vente.designationTaxe ?? ''),
                                Text(
                                  (vente.taxeInPercent == null ||
                                          vente.taxeInPercent == false)
                                      ? '${vente.taxe?.toStringAsFixed(0) ?? 0} f'
                                      : '${vente.taxe?.toStringAsFixed(0) ?? 0}%',
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              children: [
                                Text(
                                  "Remises",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                if (vente.designationRemise != null)
                                  Text(vente.designationRemise ?? ''),
                                Text(
                                  (vente.remiseInPercent == null ||
                                          vente.remiseInPercent == false)
                                      ? '${vente.remise?.toStringAsFixed(0) ?? 0} f'
                                      : '${vente.remise?.toStringAsFixed(0) ?? 0}%',
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              children: [
                                Text(
                                  "Total",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                if (vente.designationRemise != null)
                                  Text(vente.designationRemise ?? ''),
                                Text(
                                  '${vente.montantTotal.toStringAsFixed(0)} F CFA',
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildArticleDetail(LigneVente ligne, context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(2.0),
      ),
      margin: EdgeInsets.all(4.0),
      elevation: 0.0,
      color: Provider.of<ThemeProvider>(context).themeData.colorScheme.primary,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(2),
                bottomLeft: Radius.circular(2),
              ),
              child: ligne.article.images?.isNotEmpty ?? false
                  ? CachedNetworkImage(
                      imageUrl: buildUrl(ligne.article.images![0].path),
                      fit: BoxFit.fill,
                      height: 100,
                      placeholder: (context, url) => LinearProgressIndicator(
                        color: Colors.grey.withOpacity(.2),
                      ),
                      errorWidget: (context, url, error) => Image.asset(
                        'assets/images/no_image.png',
                        height: 100,
                        fit: BoxFit.fill,
                      ),
                    )
                  : Image.asset(
                      height: 100,
                      'assets/images/no_image.png',
                      fit: BoxFit.fill,
                    ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    ligne.article.libelle ?? "Inconnu",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14.0,
                    ),
                  ),
                  SizedBox(height: 4.0),
                  Text(
                    'Prix : ${ligne.montant?.toInt() ?? 0} F',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.blueGrey,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Text(
                    'Quantité : ${ligne.quantite}',
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: TextStyle(
                      color: Colors.blueGrey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    'Total : ${ligne.quantite * (ligne.montant ?? 0).toInt()} F',
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: TextStyle(
                      color: Colors.blueGrey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
