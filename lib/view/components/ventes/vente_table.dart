// ignore_for_file: unnecessary_import

import "package:africanova/controller/vente_controller.dart";
import "package:africanova/database/vente.dart";
import "package:africanova/provider/permissions_providers.dart";
import "package:africanova/theme/theme_provider.dart";
import "package:africanova/util/date_formatter.dart";
import "package:africanova/view/components/ventes/vente_detail.dart";
import "package:africanova/view/components/ventes/vente_saver.dart";
import "package:africanova/widget/dialogs.dart";
import "package:africanova/widget/table_config.dart";
import "package:flutter/material.dart";
import "package:get/get.dart";
import "package:hive/hive.dart";
import "package:hive_flutter/hive_flutter.dart";
import "package:pluto_grid/pluto_grid.dart";
import "package:provider/provider.dart";

class VenteTable extends StatefulWidget {
  final Function(Widget) switchView;
  const VenteTable({super.key, required this.switchView});

  @override
  State<VenteTable> createState() => _VenteTableState();
}

class _VenteTableState extends State<VenteTable> {
  late List<Vente> ventes = [];
  late String query = "";
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _fetchAndStore();
  }

  Future<void> _fetchAndStore() async {
    await getVente();
  }

  void _cancel(context, int id) async {
    final result = await cancelVente(id);
    if (result['status']) {
      Navigator.pop(context);
    }
    Get.snackbar(
      '',
      result["message"],
      titleText: SizedBox.shrink(),
      messageText: Center(
        child: Text(result["message"]),
      ),
      maxWidth: 300,
      snackPosition: SnackPosition.BOTTOM,
    );
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
        title: "Client",
        field: "client",
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
          title: "Status",
          field: "status",
          type: PlutoColumnType.text(),
          width: width,
          minWidth: width,
          enableContextMenu: false,
          renderer: (rendererContext) {
            return Text(
              rendererContext.cell.value?.toUpperCase() ?? "EN ATTENTE",
              style: TextStyle(
                color: rendererContext.cell.value == null
                    ? Colors.orange
                    : rendererContext.cell.value == "complete"
                        ? Colors.green[700]
                        : Colors.red[700],
                fontWeight: FontWeight.bold,
              ),
            );
          }),
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
        renderer: (rendererContext) {
          return FutureBuilder<Map<String, bool>>(
            future: checkPermissions([
              'modifier ventes',
              'voir ventes',
              'annuler ventes',
            ]),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox();
              }
              if (snapshot.hasError) {
                return Center(child: Text('Erreur: ${snapshot.error}'));
              }

              var permissions = snapshot.data ?? {};

              return Wrap(
                alignment: WrapAlignment.center,
                children: [
                  if (permissions['annuler ventes'] ?? false)
                    Tooltip(
                      message: 'Annuler la vente',
                      child: IconButton(
                        icon: Icon(
                          Icons.cancel,
                          color: Colors.red[600],
                        ),
                        onPressed: () {
                          showCancelConfirmationDialog(
                            context,
                            () {
                              _cancel(
                                context,
                                rendererContext.cell.value.id ?? 0,
                              );
                            },
                            'Êtes-vous sûr de vouloir annuler cette vente ?',
                          );
                        },
                      ),
                    ),
                  if ((permissions['modifier ventes'] ?? false))
                    Tooltip(
                      message: 'Modifier la vente',
                      child: IconButton(
                        icon: Icon(
                          Icons.edit,
                          color: Colors.blue[800],
                        ),
                        onPressed: () {
                          widget.switchView(
                            VenteSaver(
                              editableVente: rendererContext.cell.value,
                            ),
                          );
                        },
                      ),
                    ),
                  if (permissions['voir ventes'] ?? false)
                    Tooltip(
                      message: 'Datails de la vente',
                      child: IconButton(
                        icon: Icon(
                          Icons.info,
                        ),
                        onPressed: () {
                          widget.switchView(
                            VenteDetail(
                              vente: rendererContext.cell.value,
                              switchView: (Widget w) => widget.switchView(w),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              );
            },
          );
        },
      ),
    ];
  }

  void setDate(DateTime? date) {
    setState(() {
      _selectedDate = date;
    });
  }

  void filterDate() {
    final ventes = Hive.box<Vente>("venteHistory").values.toList();

    if (_selectedDate == null) {
      ventes.sort((a, b) => (b.createdAt ?? DateTime(2000))
          .compareTo(a.createdAt ?? DateTime(2000)));

      rows.addAll(
        ventes.map((vente) => _buildRow(vente)),
      );
      return;
    }
    rows.addAll(
      ventes
          .where((vente) =>
              vente.createdAt != null &&
              vente.createdAt!.year == _selectedDate!.year &&
              vente.createdAt!.month == _selectedDate!.month &&
              vente.createdAt!.day == _selectedDate!.day)
          .map((v) => _buildRow(v))
          .toList(),
    );
  }

// Fonction pour éviter la duplication du code
  PlutoRow _buildRow(Vente vente) {
    return PlutoRow(
      cells: {
        "date": PlutoCell(value: formatDate(vente.createdAt)),
        "client": PlutoCell(value: vente.client?.fullname ?? "Inconnu"),
        "nb_article": PlutoCell(value: vente.lignes.length),
        "status": PlutoCell(
            value: vente.status == 'en_attente' ? "en attente" : vente.status),
        "vendeur": PlutoCell(
          value: vente.employer != null
              ? "${vente.employer!.prenom} ${vente.employer!.nom}"
              : vente.initiateur != null
                  ? "${vente.initiateur!.prenom} ${vente.initiateur!.nom}"
                  : "Inconnu",
        ),
        "total": PlutoCell(value: "${formatMontant(vente.montantTotal)} f"),
        "action": PlutoCell(value: vente),
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Box<Vente>>(
      valueListenable: Hive.box<Vente>("venteHistory").listenable(),
      builder: (context, box, _) {
        final ventes = box.values.toList();
        ventes.sort((a, b) => b.createdAt!.compareTo(a.createdAt!));

        rows.clear();

        if (_selectedDate == null) {
          rows.addAll(
            ventes.map(
              (vente) {
                return PlutoRow(
                  cells: {
                    "date": PlutoCell(value: formatDate(vente.createdAt)),
                    "client":
                        PlutoCell(value: vente.client?.fullname ?? "Inconnu"),
                    "nb_article": PlutoCell(value: vente.lignes.length),
                    "status": PlutoCell(
                        value: vente.status == 'en_attente'
                            ? "en attente"
                            : vente.status),
                    "vendeur": PlutoCell(
                      value: vente.employer != null
                          ? "${vente.employer!.prenom} ${vente.employer!.nom}"
                          : vente.initiateur != null
                              ? "${vente.initiateur!.prenom} ${vente.initiateur!.nom}"
                              : "Inconnu",
                    ),
                    "total": PlutoCell(
                        value: "${formatMontant(vente.montantTotal)} f"),
                    "action": PlutoCell(value: vente),
                  },
                );
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
                        columns: buildColumns(totalWidth / 7),
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
                          addwidget: VenteSaver(),
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
