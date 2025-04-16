import "package:africanova/database/top_articles.dart";
import "package:africanova/theme/theme_provider.dart";
import "package:africanova/util/date_formatter.dart";
import "package:africanova/view/components/dashboard/top_seller_more.dart";
import "package:africanova/widget/table_config.dart";
import "package:flutter/material.dart";
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
    ];
  }

  PlutoRow _buildRow(TopVendeurs topVendeurs) {
    return PlutoRow(
      cells: {
        "vendeur": PlutoCell(
          value: "${topVendeurs.employer.prenom} ${topVendeurs.employer.nom}",
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
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Box<TopVendeurs>>(
      valueListenable: Hive.box<TopVendeurs>("topVendeursBox").listenable(),
      builder: (context, box, _) {
        final topVendeurs = box.values.toList();
        rows.clear();

        double totalVentes = 0;
        double totalServices = 0;
        double totalGeneral = 0;

        final topTrois = topVendeurs.take(3).toList();

        for (var vendeur in topTrois) {
          totalVentes += vendeur.totalMontantVente;
          totalServices += vendeur.totalMontantService;
          totalGeneral +=
              vendeur.totalMontantVente + vendeur.totalMontantService;
        }

        rows.addAll(
          topTrois.map(
            (topVendeurs) {
              return _buildRow(topVendeurs);
            },
          ),
        );

        rows.add(
          PlutoRow(
            cells: {
              "vendeur": PlutoCell(value: "Total"),
              "vente": PlutoCell(value: "${formatMontant(totalVentes)} f"),
              "service": PlutoCell(value: "${formatMontant(totalServices)} f"),
              "total": PlutoCell(value: "${formatMontant(totalGeneral)} f"),
            },
          ),
        );

        return LayoutBuilder(
          builder: (context, constraints) {
            double totalWidth = constraints.maxWidth;
            return Container(
              margin: EdgeInsets.all(6.0),
              height: 270,
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
                columns: buildColumns((totalWidth - 16) / 4),
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
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: SizedBox(
                        height: 30.0,
                        child: TextButton(
                          onPressed: () {
                            widget.switchView(TopSellerMore());
                          },
                          style: TextButton.styleFrom(
                            elevation: 0.0,
                            foregroundColor: Provider.of<ThemeProvider>(context)
                                .themeData
                                .colorScheme
                                .tertiary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4.0),
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
