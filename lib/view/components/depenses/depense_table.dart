import "package:africanova/controller/depense_controller.dart";
import "package:africanova/database/depense.dart";
import "package:africanova/provider/permissions_providers.dart";
import "package:africanova/theme/theme_provider.dart";
import "package:africanova/util/date_formatter.dart";
import "package:africanova/view/components/depenses/depense_saver.dart";
import "package:africanova/widget/dialogs.dart";
import "package:africanova/widget/table_config.dart";
import "package:flutter/material.dart";
import "package:get/get.dart";
import "package:hive_flutter/hive_flutter.dart";
import "package:pluto_grid/pluto_grid.dart";
import "package:provider/provider.dart";

class DepenseTable extends StatefulWidget {
  final Function(Widget) switchView;
  const DepenseTable({super.key, required this.switchView});

  @override
  State<DepenseTable> createState() => _DepenseTableState();
}

class _DepenseTableState extends State<DepenseTable> {
  late List<Depense> depenses = [];
  late String query = "";
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _fetchAndStoreTopArticles();
  }

  Future<void> _fetchAndStoreTopArticles() async {
    await getDepenses();
  }

  void _delete(context, int id) async {
    final result = await supprimerDepense(id);
    if (result['status']) {
      Get.back();
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
        title: "Fait par",
        field: "fait_par",
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
        title: "Enregistré",
        field: "enregistre_le",
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
              'modifier depenses',
              'voir depenses',
              'supprimer depenses',
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
                  if (permissions['supprimer depenses'] ?? false)
                    Tooltip(
                      message: 'Supprimer la depense',
                      child: IconButton(
                        icon: Icon(
                          Icons.delete,
                          color: Colors.red[600],
                        ),
                        onPressed: () {
                          showCancelConfirmationDialog(
                            context,
                            () {
                              _delete(
                                context,
                                rendererContext.cell.value.id ?? 0,
                              );
                            },
                            'Êtes-vous sûr de vouloir supprimer cette dépense ?',
                          );
                        },
                      ),
                    ),
                  if ((permissions['modifier depenses'] ?? false))
                    Tooltip(
                      message: 'Modifier la dépense',
                      child: IconButton(
                        icon: Icon(
                          Icons.edit,
                          color: Colors.blue[800],
                        ),
                        onPressed: () {
                          // widget.switchView(
                          //   DepenseSaver(),
                          // );
                        },
                      ),
                    ),
                  if (permissions['voir depenses'] ?? false)
                    Tooltip(
                      message: 'Détails de la dépense',
                      child: IconButton(
                        icon: Icon(
                          Icons.info,
                        ),
                        onPressed: () {},
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
    final depenses = Hive.box<Depense>("depenseBox").values.toList();

    if (_selectedDate == null) {
      depenses.sort((a, b) => (b.date).compareTo(a.date));

      rows.addAll(
        depenses.map((depense) => _buildRow(depense)),
      );
      return;
    }
    rows.addAll(
      depenses
          .where((depense) =>
              depense.date.year == _selectedDate!.year &&
              depense.date.month == _selectedDate!.month &&
              depense.date.day == _selectedDate!.day)
          .map((v) => _buildRow(v))
          .toList(),
    );
  }

  // Fonction pour éviter la duplication du code
  PlutoRow _buildRow(Depense depense) {
    return PlutoRow(
      cells: {
        "date": PlutoCell(value: formatDate(depense.date)),
        "fait_par": PlutoCell(
          value: depense.employer != null
              ? "${depense.employer!.prenom} ${depense.employer!.nom}"
              : "Inconnu",
        ),
        "total": PlutoCell(value: "${formatMontant(depense.montant)} f"),
        "enregistre_le": PlutoCell(value: formatDate(depense.createdAt)),
        "action": PlutoCell(value: depense),
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Box<Depense>>(
      valueListenable: Hive.box<Depense>("depenseBox").listenable(),
      builder: (context, box, _) {
        final depenses = box.values.toList();
        depenses.sort((a, b) => b.createdAt.compareTo(a.createdAt));

        rows.clear();

        if (_selectedDate == null) {
          rows.addAll(
            depenses.map(
              (depense) {
                return _buildRow(depense);
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
                borderRadius: BorderRadius.circular(4.0),
              ),
              margin: EdgeInsets.all(0.0),
              color: Provider.of<ThemeProvider>(context)
                  .themeData
                  .colorScheme
                  .surface,
              
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
                        columns: buildColumns((totalWidth - 14.0) / 5),
                        rows: rows,
                        onChanged: (PlutoGridOnChangedEvent event) {},
                        onLoaded: (PlutoGridOnLoadedEvent event) {
                          event.stateManager.setShowColumnFilter(true);
                          event.stateManager
                              .setSelectingMode(PlutoGridSelectingMode.cell);

                          stateManager = event.stateManager;
                        },
                        createHeader: (stateManager) => TableHeader(
                          enableAdd: false,
                          addwidget: DepenseSaver(),
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
