import 'dart:io';

import 'package:africanova/controller/dashboard_controller.dart';
import 'package:africanova/database/top_articles.dart';
import 'package:africanova/theme/theme_provider.dart';
import 'package:africanova/util/date_formatter.dart';
import 'package:africanova/util/printer_manager.dart';
import 'package:africanova/util/string_formatter.dart';
import 'package:africanova/view/components/dashboard/more_header.dart';
import 'package:africanova/view/components/dashboard/printer.dart';
import 'package:africanova/widget/table_config.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:provider/provider.dart';

class TopSellerMore extends StatefulWidget {
  const TopSellerMore({super.key});

  @override
  State<TopSellerMore> createState() => _TopSellerMoreState();
}

class _TopSellerMoreState extends State<TopSellerMore> {
  late List<TopVendeurs> topVendeurss = [];
  List<PlutoRow> rows = [];
  final List<PlutoColumn> columns = [];
  bool isLoading = false;
  bool check = false;
  late String query = "";
  late String period = formatDateRange(
    DateTime(DateTime.now().year, DateTime.now().month, 1),
    DateTime.now(),
  );
  @override
  void initState() {
    super.initState();
  }

  setPeriod(String text) {
    setState(() {
      period = text;
    });
  }

  _applyFilter(DateTime start, DateTime end) async {
    setState(() {
      isLoading = true;
    });
    final result = await getTopVendeurs(startDate: start, endDate: end);
    if (!result["status"]) {
      Get.snackbar(
        '',
        "Impossible d'appliquer le filtre",
        titleText: SizedBox.shrink(),
        messageText: Center(
          child: Text("Impossible d'appliquer le filtre"),
        ),
        maxWidth: 300,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
    setState(() {
      isLoading = false;
    });
  }

  late PlutoGridStateManager stateManager;

  List<PlutoColumn> buildColumns(double width) {
    return [
      PlutoColumn(
        title: "Employer",
        field: "vendeur",
        type: PlutoColumnType.text(),
        width: width * 2,
        minWidth: width,
        enableContextMenu: false,
        enableFilterMenuItem: false,
        enableSorting: false,
      ),
      PlutoColumn(
        title: "Ventes",
        field: "vente",
        type: PlutoColumnType.text(),
        width: width,
        minWidth: width,
        enableContextMenu: false,
        enableFilterMenuItem: false,
        enableSorting: false,
      ),
      PlutoColumn(
        title: "Services",
        field: "service",
        type: PlutoColumnType.text(),
        width: width,
        minWidth: width,
        enableContextMenu: false,
        enableFilterMenuItem: false,
        enableSorting: false,
      ),
      PlutoColumn(
        title: "Totaux",
        field: "total",
        type: PlutoColumnType.text(),
        width: width,
        minWidth: width,
        enableContextMenu: false,
        enableFilterMenuItem: false,
        enableSorting: false,
      ),
      PlutoColumn(
        title: "% Ventes",
        field: "p_vente",
        type: PlutoColumnType.text(),
        width: width,
        minWidth: width,
        enableContextMenu: false,
        enableFilterMenuItem: false,
        enableSorting: false,
      ),
      PlutoColumn(
        title: "% Services",
        field: "p_service",
        type: PlutoColumnType.text(),
        width: width,
        minWidth: width,
        enableContextMenu: false,
        enableFilterMenuItem: false,
        enableSorting: false,
      ),
      PlutoColumn(
        title: "% Totaux",
        field: "p_total",
        type: PlutoColumnType.text(),
        width: width,
        minWidth: width,
        enableContextMenu: false,
        enableFilterMenuItem: false,
        enableSorting: false,
      ),
    ];
  }

  PlutoRow _buildRow(TopVendeurs topVendeurs) {
    return PlutoRow(
      cells: {
        "vendeur": PlutoCell(
          value: capitalizeEachWord(
              "${topVendeurs.employer.prenom} ${topVendeurs.employer.nom}"),
        ),
        "vente": PlutoCell(
          value: "${formatMontant(topVendeurs.totalMontantVente)} f",
        ),
        "service": PlutoCell(
          value: "${formatMontant(topVendeurs.totalMontantService)} f",
        ),
        "total": PlutoCell(
          value:
              "${formatMontant(topVendeurs.totalMontantVente + topVendeurs.totalMontantService)} f",
        ),
        "p_vente": PlutoCell(
          value: "${topVendeurs.pourcentageVente.toStringAsFixed(2)} %",
        ),
        "p_service": PlutoCell(
          value: "${topVendeurs.pourcentageServices.toStringAsFixed(2)} %",
        ),
        "p_total": PlutoCell(
          value: "${topVendeurs.score.toStringAsFixed(2)} %",
        ),
      },
    );
  }

  printTable() async {
    final DateTime now = DateTime.now();
    final String nomDoc =
        "Rapport du ${DateFormat('dd MMM yyyy', 'fr_FR').format(now)}";

    final pdfFile = await generatePDF(rows: rows, period: period);

    final dirPath = await getDir('Rapports/Rapport des Ventes par Employer');

    final filePath = "$dirPath/$nomDoc.pdf";
    final file = File(filePath);

    if (!await file.exists()) {
      await file.create();
    }

    await file.writeAsBytes(pdfFile);
    openFile(filePath);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            SizedBox(
              height: 60.0,
              child: MoreHeader(
                setPeriod: (String p) => setPeriod(p),
                setValues: (DateTime a, DateTime b) => _applyFilter(a, b),
                printTable: printTable,
              ),
            ),
            Expanded(
              child: ValueListenableBuilder<Box<TopVendeurs>>(
                valueListenable:
                    Hive.box<TopVendeurs>("topVendeursBox").listenable(),
                builder: (context, box, _) {
                  final topVendeurs = box.values.toList();
                  rows.clear();

                  rows.addAll(
                    topVendeurs.map(
                      (topVendeurs) {
                        return _buildRow(topVendeurs);
                      },
                    ),
                  );

                  double totalVente = topVendeurs.fold(
                      0, (sum, item) => sum + item.totalMontantVente);
                  double totalService = topVendeurs.fold(
                      0, (sum, item) => sum + item.totalMontantService);
                  double totalGeneral = totalVente + totalService;

                  double totalPourcentageVente = topVendeurs.fold(
                      0, (sum, item) => sum + item.pourcentageVente);

                  double totalPourcentageService = topVendeurs.fold(
                      0, (sum, item) => sum + item.pourcentageServices);

                  double totalPourcentageTotal =
                      topVendeurs.fold(0, (sum, item) => sum + item.score);

                  rows.add(
                    PlutoRow(
                      cells: {
                        "vendeur": PlutoCell(value: "TOTAL"),
                        "vente":
                            PlutoCell(value: "${formatMontant(totalVente)} f"),
                        "service": PlutoCell(
                            value: "${formatMontant(totalService)} f"),
                        "total": PlutoCell(
                            value: "${formatMontant(totalGeneral)} f"),
                        "p_vente": PlutoCell(
                            value:
                                "${totalPourcentageVente.toStringAsFixed(2)} %"),
                        "p_service": PlutoCell(
                            value:
                                "${totalPourcentageService.toStringAsFixed(2)} %"),
                        "p_total": PlutoCell(
                            value:
                                "${totalPourcentageTotal.toStringAsFixed(2)} %"),
                      },
                    ),
                  );

                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                    elevation: 0.0,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        double totalWidth = constraints.maxWidth;
                        return Padding(
                          padding: EdgeInsets.all(6.0),
                          child: Column(
                            spacing: 0.0,
                            children: [
                              Container(
                                height: 45.0,
                                color: Color(0xFF056148),
                                child: Center(
                                  child: Text(
                                    period.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal:  1.0),
                                  child: PlutoGrid(
                                    configuration:
                                        Provider.of<ThemeProvider>(context)
                                                .isLightTheme()
                                            ? PlutoGridConfiguration(
                                                style: tableStyle,
                                                columnFilter: columnFilterConfig,
                                              )
                                            : PlutoGridConfiguration.dark(
                                                columnFilter: columnFilterConfig,
                                                style: darkTableStyle,
                                              ),
                                    columns: buildColumns((totalWidth - 16) / 8),
                                    rows: rows,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        if (isLoading)
          Container(
            color: Colors.transparent,
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Center(
              child: Container(
                color: Provider.of<ThemeProvider>(context)
                    .themeData
                    .colorScheme
                    .tertiary
                    .withOpacity(0.3),
                width: 80,
                height: 80,
                padding: EdgeInsets.all(20.0),
                child: CircularProgressIndicator(
                  color: Provider.of<ThemeProvider>(context)
                      .themeData
                      .colorScheme
                      .secondary,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
