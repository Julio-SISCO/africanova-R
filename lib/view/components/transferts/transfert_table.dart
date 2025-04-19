import "package:africanova/database/transfert.dart";
import "package:africanova/theme/theme_provider.dart";
import "package:africanova/util/date_formatter.dart";
import "package:africanova/widget/table_config.dart";
import "package:flutter/material.dart";
import "package:hive_flutter/hive_flutter.dart";
import "package:pluto_grid/pluto_grid.dart";
import "package:provider/provider.dart";

class TransfertTable extends StatefulWidget {
  final Function(Widget) switchView;
  const TransfertTable({super.key, required this.switchView});

  @override
  State<TransfertTable> createState() => _TransfertTableState();
}

class _TransfertTableState extends State<TransfertTable> {
  final List<PlutoColumn> columns = [];
  final List<PlutoRow> rows = [];
  late PlutoGridStateManager stateManager;

  @override
  void initState() {
    super.initState();
    _loadTransferts();
  }

  Future<void> _loadTransferts() async {
    final transferts = Hive.box<Transfert>("transfertBox").values.toList();
    setState(() {
      rows.clear();
      rows.addAll(transferts.map((transfert) => _buildRow(transfert)));
      rows.addAll(transferts.map((transfert) => _buildRow(transfert)));
      rows.addAll(transferts.map((transfert) => _buildRow(transfert)));
    });
  }

  final values = {
    'moov africa': 'Moov Africa',
    'yas togo': 'Yas Togo',
    'mixx by yas': 'Mixx By Yas',
    'flooz': 'Flooz',
    'retrait': 'Retrait',
    'depot': 'Dépôt',
    'forfait internet': 'Forfait internet',
    'forfait appel': 'Forfait appel',
    'recharge unite': "Recharge d'unités",
    'transfert argent': "Transfert d'argent",
    'credit simple': 'Crédit simple',
  };
  PlutoRow _buildRow(Transfert transfert) {
    return PlutoRow(
      cells: {
        "date": PlutoCell(value: formatDate(transfert.date)),
        "contact": PlutoCell(value: transfert.contact),
        "montant": PlutoCell(value: "${formatMontant(transfert.montant)} F"),
        "commission":
            PlutoCell(value: "${formatMontant(transfert.commission)} F"),
        "categorie": PlutoCell(value: values[transfert.categorie]),
        "reseau": PlutoCell(value: values[transfert.reseau]),
        "type": PlutoCell(value: values[transfert.type]),
        "vendeur": PlutoCell(
          value: transfert.employer != null
              ? "${transfert.employer?.prenom} ${transfert.employer?.nom}"
              : "Inconnu",
        ),
        "action": PlutoCell(value: transfert),
      },
    );
  }

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
        title: "Catégorie",
        field: "categorie",
        type: PlutoColumnType.text(),
        width: width,
        minWidth: width,
        enableContextMenu: false,
      ),
      PlutoColumn(
        title: "Réseau",
        field: "reseau",
        type: PlutoColumnType.text(),
        width: width,
        minWidth: width,
        enableContextMenu: false,
      ),
      PlutoColumn(
        title: "Type",
        field: "type",
        type: PlutoColumnType.text(),
        width: width,
        minWidth: width,
        enableContextMenu: false,
      ),
      PlutoColumn(
        title: "Contact",
        field: "contact",
        type: PlutoColumnType.text(),
        width: width,
        minWidth: width,
        enableContextMenu: false,
      ),
      PlutoColumn(
        title: "Montant",
        field: "montant",
        type: PlutoColumnType.text(),
        width: width,
        minWidth: width,
        enableContextMenu: false,
      ),
      PlutoColumn(
        title: "Commission",
        field: "commission",
        type: PlutoColumnType.text(),
        width: width,
        minWidth: width,
        enableContextMenu: false,
      ),
      PlutoColumn(
        title: "Fait par",
        field: "vendeur",
        type: PlutoColumnType.text(),
        width: width,
        minWidth: width,
        enableContextMenu: false,
        enableFilterMenuItem: true,
        enableSorting: true,
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
          return Wrap(
            alignment: WrapAlignment.center,
            children: [
              IconButton(
                icon: Icon(Icons.info, color: Colors.blue[800]),
                tooltip: "Détails",
                onPressed: () {
                  // widget.switchView(
                  //   TransfertDetails(
                  //     transfert: rendererContext.cell.value,
                  //   ),
                  // );
                },
              ),
              IconButton(
                icon: Icon(Icons.edit, color: Colors.green[600]),
                tooltip: "Modifier",
                onPressed: () {
                  // widget.switchView(
                  // TransfertSaver(
                  //   editableTransfert: rendererContext.cell.value,
                  // ),
                  // );
                },
              ),
              IconButton(
                icon: Icon(Icons.delete, color: Colors.red[600]),
                tooltip: "Supprimer",
                onPressed: () {
                  _deleteTransfert(rendererContext.cell.value);
                },
              ),
            ],
          );
        },
      ),
    ];
  }

  void _deleteTransfert(Transfert transfert) {
    Hive.box<Transfert>("transfertBox").delete(transfert.key);
    _loadTransferts();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Transfert supprimé avec succès")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double totalWidth = constraints.maxWidth;
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: PlutoGrid(
            configuration: Provider.of<ThemeProvider>(context).isLightTheme()
                ? PlutoGridConfiguration(
                    style: tableStyle,
                    columnFilter: columnFilterConfig,
                  )
                : PlutoGridConfiguration.dark(
                    columnFilter: columnFilterConfig,
                    style: darkTableStyle,
                  ),
            columns: buildColumns((totalWidth - 16) / 9),
            rows: rows,
            onChanged: (PlutoGridOnChangedEvent event) {},
            onLoaded: (PlutoGridOnLoadedEvent event) {
              event.stateManager.setShowColumnFilter(true);
              event.stateManager.setSelectingMode(PlutoGridSelectingMode.cell);

              stateManager = event.stateManager;
            },
            createFooter: (stateManager) {
              stateManager.setPageSize(15, notify: false);
              return PlutoPagination(
                stateManager,
                pageSizeToMove: 1,
              );
            },
          ),
        );
      },
    );
  }
}
