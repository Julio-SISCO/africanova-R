// ignore_for_file: unnecessary_import

import 'package:africanova/controller/bilan_controller.dart';
import 'package:africanova/controller/dashboard_controller.dart';
import 'package:africanova/database/bilan.dart';
import 'package:africanova/provider/permissions_providers.dart';
import 'package:africanova/theme/theme_provider.dart';
import 'package:africanova/util/date_formatter.dart';
import 'package:africanova/view/components/dashboard/article_plus_vendu.dart';
import 'package:africanova/view/components/dashboard/dash_shortcut.dart';
import 'package:africanova/view/components/dashboard/service_vente_chart.dart';
import 'package:africanova/view/components/dashboard/top_sellers_table.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

class Dashboard extends StatefulWidget {
  final Function(Widget) switchView;
  const Dashboard({super.key, required this.switchView});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  double totalJour = 0;
  double venteJour = 0;
  double serviceJour = 0;
  double totalSemaine = 0;
  double venteSemaine = 0;
  double serviceSemaine = 0;

  @override
  void initState() {
    super.initState();
    _fetchAndStoreTopArticles();
  }

  Future<void> _fetchAndStoreTopArticles() async {
    await getTopArticles();
    await getTopVendeurs();
    await getSimpleBilan();
    await getBilan();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DashShortcut(
          switchView: (Widget w) {
            widget.switchView(w);
          },
        ),
        FutureBuilder<Map<String, bool>>(
          future: checkPermissions([
            'voir dashboard',
          ]),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                  child: CircularProgressIndicator(
                color: Provider.of<ThemeProvider>(context)
                    .themeData
                    .colorScheme
                    .secondary,
              ));
            }
            if (snapshot.hasError) {
              return Center(child: Text('Erreur: ${snapshot.error}'));
            }

            var permissions = snapshot.data ?? {};

            return (permissions['voir dashboard'] ?? false)
                ? Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(
                            height: 135,
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(2.0),
                              ),
                              elevation: 0.0,
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 2.0, vertical: 2.0),
                                child: ValueListenableBuilder<Box<Statistique>>(
                                  valueListenable:
                                      Hive.box<Statistique>("statData")
                                          .listenable(),
                                  builder: (context, box, _) {
                                    if (box.values.isNotEmpty) {
                                      final bilan = box.values.first;
                                      totalJour = (bilan.salesToday +
                                              bilan.servicesToday)
                                          .toDouble();
                                      venteJour = (bilan.salesToday).toDouble();
                                      serviceJour =
                                          (bilan.servicesToday).toDouble();
                                      totalSemaine =
                                          (bilan.servicesWeek + bilan.salesWeek)
                                              .toDouble();
                                      venteSemaine =
                                          (bilan.salesWeek).toDouble();
                                      serviceSemaine =
                                          (bilan.servicesWeek).toDouble();
                                    }
                                    return LayoutBuilder(
                                      builder: (context, constraints) {
                                        double totalWidth =
                                            constraints.maxWidth;
                                        return Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.stretch,
                                          children: [
                                            _buildArticleCard(
                                              width: totalWidth / 6,
                                              libelle: "Total du jour",
                                              total: totalJour,
                                            ),
                                            _buildArticleCard(
                                              width: totalWidth / 6,
                                              libelle: "Ventes du Jour",
                                              total: venteJour,
                                              proportion:
                                                  "${(venteJour * 100 / (venteJour + serviceJour)).toStringAsFixed(2)}%",
                                            ),
                                            _buildArticleCard(
                                              width: totalWidth / 6,
                                              libelle: "Services du Jour",
                                              total: serviceJour,
                                              proportion:
                                                  "${(serviceJour * 100 / (venteJour + serviceJour)).toStringAsFixed(2)}%",
                                            ),
                                            _buildArticleCard(
                                              width: totalWidth / 6,
                                              libelle: "Total de la semaine",
                                              total: totalSemaine,
                                            ),
                                            _buildArticleCard(
                                              width: totalWidth / 6,
                                              libelle: "Ventes de la semaine",
                                              total: venteSemaine,
                                              proportion:
                                                  "${(venteSemaine * 100 / (venteSemaine + serviceSemaine)).toStringAsFixed(2)}%",
                                            ),
                                            _buildArticleCard(
                                              width: totalWidth / 6,
                                              libelle: "Services de la semaine",
                                              total: serviceSemaine,
                                              proportion:
                                                  "${(serviceSemaine * 100 / (venteSemaine + serviceSemaine)).toStringAsFixed(2)}%",
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                          Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(2.0),
                            ),
                            elevation: 0.0,
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 2.0, vertical: 2.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: Column(
                                      children: [
                                        TopSellerTable(
                                          switchView: (Widget w) =>
                                              widget.switchView(w),
                                        ),
                                        ServiceVenteChart(),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: ArticlePlusVendu(),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : Padding(
                    padding: EdgeInsets.only(top: 200),
                    child: Text('Ravi de vous revoir !'),
                  );
          },
        ),
      ],
    );
  }

  Widget _buildArticleCard({
    required double width,
    required String libelle,
    required double total,
    String? proportion,
  }) {
    return SizedBox(
      width: width,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4.0),
        ),
        color:
            Provider.of<ThemeProvider>(context).themeData.colorScheme.primary,
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                libelle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(height: 8.0),
              Text(
                "${formatMontant(total)} f",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.amber[700],
                ),
              ),
              SizedBox(height: 8.0),
              if (proportion != null) Text(proportion),
            ],
          ),
        ),
      ),
    );
  }
}
