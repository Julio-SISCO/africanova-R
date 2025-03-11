// ignore_for_file: unnecessary_import

import "package:africanova/controller/approvision_controller.dart";
import "package:africanova/database/approvision.dart";
import "package:africanova/theme/theme_provider.dart";
import "package:africanova/util/date_formatter.dart";
import "package:africanova/view/components/approvisions/approvision_saver.dart";
import "package:africanova/widget/table_config.dart";
import "package:flutter/material.dart";
import "package:hive/hive.dart";
import "package:hive_flutter/hive_flutter.dart";
import "package:pluto_grid/pluto_grid.dart";
import "package:provider/provider.dart";

class ApprovisionTable extends StatefulWidget {
  final Function(Widget) switchView;
  const ApprovisionTable({super.key, required this.switchView});

  @override
  State<ApprovisionTable> createState() => _ApprovisionTableState();
}

class _ApprovisionTableState extends State<ApprovisionTable> {
  late List<Approvision> approvisions = [];
  late String query = "";
  DateTime? _selectedDate;
  @override
  void initState() {
    super.initState();
    _fetchAndStoreTopArticles();
  }

  Future<void> _fetchAndStoreTopArticles() async {
    await getApprovision();
  }

  final List<PlutoColumn> columns = [];
  final List<PlutoRow> rows = [];

  late PlutoGridStateManager stateManager;

  List<PlutoColumn> buildColumns(double width) {
    return [
      PlutoColumn(
        title: "Date",
        field: "date",
        type: PlutoColumnType.text(),
        width: width,
        minWidth: width,
        enableContextMenu: false,
      ),
      PlutoColumn(
        title: "Fournisseur",
        field: "fournisseur",
        type: PlutoColumnType.text(),
        width: width,
        minWidth: width,
        enableContextMenu: false,
      ),
      PlutoColumn(
        title: "Nombre d'article",
        field: "nb_article",
        type: PlutoColumnType.number(),
        width: width,
        minWidth: width,
        enableContextMenu: false,
      ),
      PlutoColumn(
        title: "Vendeur",
        field: "vendeur",
        type: PlutoColumnType.text(),
        width: width,
        minWidth: width,
        enableContextMenu: false,
      ),
      PlutoColumn(
        title: "Total",
        field: "total",
        type: PlutoColumnType.text(),
        width: width,
        minWidth: width,
        enableContextMenu: false,
      ),
      PlutoColumn(
        title: "Action",
        field: "action",
        type: PlutoColumnType.text(),
        width: width,
        minWidth: width,
        enableContextMenu: false,
        enableFilterMenuItem: false,
        enableSorting: false,
      ),
    ];
  }

  void setDate(DateTime? date) {
    setState(() {
      _selectedDate = date;
    });
  }

  void filterDate() {
    final approvisions =
        Hive.box<Approvision>("approvisionBox").values.toList();

    if (_selectedDate == null) {
      approvisions.sort((a, b) => (b.createdAt ?? DateTime(2000))
          .compareTo(a.createdAt ?? DateTime(2000)));

      rows.addAll(
        approvisions.map((approvision) => _buildRow(approvision)),
      );
      return;
    }
    rows.addAll(
      approvisions
          .where((approvision) =>
              approvision.createdAt != null &&
              approvision.createdAt!.year == _selectedDate!.year &&
              approvision.createdAt!.month == _selectedDate!.month &&
              approvision.createdAt!.day == _selectedDate!.day)
          .map((v) => _buildRow(v))
          .toList(),
    );
  }

// Fonction pour éviter la duplication du code
  PlutoRow _buildRow(Approvision approvision) {
    return PlutoRow(
      cells: {
        "date": PlutoCell(value: formatDate(approvision.createdAt)),
        "fournisseur":
            PlutoCell(value: approvision.fournisseur?.fullname ?? "Inconnu"),
        "nb_article": PlutoCell(value: approvision.lignes.length),
        "vendeur": PlutoCell(
          value: approvision.employer != null
              ? "${approvision.employer!.prenom} ${approvision.employer!.nom}"
              : "Inconnu",
        ),
        "total": PlutoCell(
            value: "${approvision.montantTotal.toStringAsFixed(0)} f"),
        "action": PlutoCell(value: "voir"),
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Box<Approvision>>(
      valueListenable: Hive.box<Approvision>("approvisionBox").listenable(),
      builder: (context, box, _) {
        final approvisions = box.values.toList();
        approvisions.sort((a, b) => b.createdAt!.compareTo(a.createdAt!));

        rows.clear();

        if (_selectedDate == null) {
          rows.addAll(
            approvisions.map(
              (approvision) {
                return _buildRow(approvision);
              },
            ),
          );
        } else {
          filterDate();
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            double totalWidth = constraints.maxWidth;
            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(2.0),
              ),
              margin: EdgeInsets.all(0.0),
              color: Provider.of<ThemeProvider>(context)
                  .themeData
                  .colorScheme
                  .surface,
              elevation: 0.0,
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Column(
                  children: [
                    Expanded(
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
                        columns: buildColumns(totalWidth / 6),
                        rows: rows,
                        onChanged: (PlutoGridOnChangedEvent event) {},
                        onLoaded: (PlutoGridOnLoadedEvent event) {
                          event.stateManager.setShowColumnFilter(true);
                          event.stateManager
                              .setSelectingMode(PlutoGridSelectingMode.cell);

                          stateManager = event.stateManager;
                        },
                        createHeader: (stateManager) => TableHeader(
                          addAction: (Widget w) {
                            widget.switchView(w);
                          },
                          addwidget: ApprovisionSaver(),
                          setDate: (DateTime? d) {
                            setDate(d);
                          },
                        ),
                        createFooter: (stateManager) {
                          stateManager.setPageSize(15, notify: false);
                          return PlutoPagination(
                            stateManager,
                            pageSizeToMove: 1,
                          );
                        },
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
