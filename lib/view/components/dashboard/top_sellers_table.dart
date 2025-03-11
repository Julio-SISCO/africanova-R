// ignore_for_file: unnecessary_import

import "package:africanova/database/top_articles.dart";
import "package:africanova/theme/theme_provider.dart";
import "package:africanova/view/components/dashboard/top_seller_more.dart";
import "package:africanova/widget/table_config.dart";
import "package:flutter/material.dart";
import "package:hive/hive.dart";
import "package:hive_flutter/hive_flutter.dart";
import "package:pluto_grid/pluto_grid.dart";
import "package:provider/provider.dart";

class TopSellerTable extends StatefulWidget {
  final Function(Widget) switchView;
  const TopSellerTable({super.key, required this.switchView});

  @override
  State<TopSellerTable> createState() => _TopSellerTableState();
}

class _TopSellerTableState extends State<TopSellerTable> {
  late List<TopVendeurs> topVendeurss = [];
  late String query = "";
  @override
  void initState() {
    super.initState();
  }

  final List<PlutoColumn> columns = [];
  final List<PlutoRow> rows = [];

  late PlutoGridStateManager stateManager;

  List<PlutoColumn> buildColumns(double width) {
    return [
      PlutoColumn(
        title: "Employers",
        field: "vendeur",
        type: PlutoColumnType.text(),
        width: width,
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
          value: "${topVendeurs.employer.prenom} ${topVendeurs.employer.nom}",
        ),
        "vente": PlutoCell(
          value: "${topVendeurs.totalMontantVente.toStringAsFixed(0)} f",
        ),
        "service": PlutoCell(
          value: "${topVendeurs.totalMontantService.toStringAsFixed(0)} f",
        ),
        "total": PlutoCell(
          value:
              "${(topVendeurs.totalMontantVente + topVendeurs.totalMontantService).toStringAsFixed(0)} f",
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

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Box<TopVendeurs>>(
      valueListenable: Hive.box<TopVendeurs>("topVendeursBox").listenable(),
      builder: (context, box, _) {
        final topVendeurss = box.values.toList();
        rows.clear();

        rows.addAll(
          topVendeurss.map(
            (topVendeurs) {
              return _buildRow(topVendeurs);
            },
          ),
        );

        return LayoutBuilder(
          builder: (context, constraints) {
            double totalWidth = constraints.maxWidth;
            return Container(
              margin: EdgeInsets.all(6.0),
              height: 300,
              child: PlutoGrid(
                configuration:
                    Provider.of<ThemeProvider>(context).isLightTheme()
                        ? PlutoGridConfiguration(
                            style: tableStyle,
                            columnFilter: columnFilterConfig,
                          )
                        : PlutoGridConfiguration.dark(
                            columnFilter: columnFilterConfig,
                            style: darkTableStyle,
                          ),
                columns: buildColumns((totalWidth - 16) / 7),
                rows: rows,
                createHeader: (stateManager) => Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        "Activié par employer",
                        style: TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2.0),
                      child: SizedBox(
                        height: 30.0,
                        child: OutlinedButton(
                          onPressed: () {
                            widget.switchView(TopSellerMore());
                          },
                          style: ElevatedButton.styleFrom(
                            elevation: 0.0,
                            foregroundColor: Provider.of<ThemeProvider>(context)
                                .themeData
                                .colorScheme
                                .tertiary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(2.0),
                            ),
                          ),
                          child: Text("Plus de détails"),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
