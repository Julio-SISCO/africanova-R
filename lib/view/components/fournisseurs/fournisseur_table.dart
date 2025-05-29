import "package:africanova/controller/fournisseur_controller.dart";
import "package:africanova/database/fournisseur.dart";
import "package:africanova/provider/permissions_providers.dart";
import "package:africanova/theme/theme_provider.dart";
import "package:africanova/view/components/fournisseurs/fournisseur_form.dart";
import "package:africanova/widget/table_config.dart";
import "package:flutter/material.dart";
import "package:get/get.dart";
import "package:hive_flutter/hive_flutter.dart";
import "package:pluto_grid/pluto_grid.dart";
import "package:provider/provider.dart";

class FournisseurTable extends StatefulWidget {
  final Function(Widget) switchView;
  const FournisseurTable({super.key, required this.switchView});

  @override
  State<FournisseurTable> createState() => _FournisseurTableState();
}

class _FournisseurTableState extends State<FournisseurTable> {
  late List<Fournisseur> fournisseurs = [];
  late String query = "";
  @override
  void initState() {
    super.initState();
    _fetchAndStoreTopArticles();
  }

  Future<void> _fetchAndStoreTopArticles() async {
    await getFournisseurs();
  }

  final List<PlutoColumn> columns = [];
  final List<PlutoRow> rows = [];

  late PlutoGridStateManager stateManager;

  List<PlutoColumn> buildColumns(double width) {
    return [
      PlutoColumn(
        title: "Fournisseur",
        field: "fournisseur",
        type: PlutoColumnType.text(),
        width: width,
        minWidth: width,
        enableContextMenu: false,
      ),
      PlutoColumn(
        title: "Email",
        field: "email",
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
        title: "Fax",
        field: "fax",
        type: PlutoColumnType.text(),
        width: width,
        minWidth: width,
        enableContextMenu: false,
      ),
      PlutoColumn(
        title: "Adresse",
        field: "adresse",
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
                'enregistrer fournisseurs',
                'modifier fournisseurs',
                'voir fournisseurs',
                'supprimer fournisseurs',
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
                    if (permissions['voir fournisseurs'] ?? false)
                      IconButton(
                        icon: Icon(
                          Icons.shopping_cart_checkout,
                        ),
                        onPressed: () {},
                      ),
                    if ((permissions['modifier fournisseurs'] ?? false))
                      IconButton(
                        icon: Icon(
                          Icons.edit,
                          color: Colors.blue[800],
                        ),
                        onPressed: () {
                          widget.switchView(FournisseurForm(
                            editableFournisseur: rendererContext.cell.value,
                          ));
                        },
                      ),
                    if (permissions['supprimer fournisseurs'] ?? false)
                      IconButton(
                        icon: Icon(
                          Icons.delete,
                          color: Colors.red[600],
                        ),
                        onPressed: () async {
                          bool? confirmation =
                              await showConfirmationDialog(context);
                          if (confirmation == true) {
                            var result = await supprimerFournisseur(
                                rendererContext.cell.value.id!);
                            if (result['status'] == 200) {
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
                          }
                        },
                      ),
                  ],
                );
              },
            );
          }),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Box<Fournisseur>>(
      valueListenable: Hive.box<Fournisseur>("fournisseurBox").listenable(),
      builder: (context, box, _) {
        final fournisseurs = box.values.toList();
        fournisseurs.sort((a, b) => b.createdAt!.compareTo(a.createdAt!));

        rows.clear();

        rows.addAll(
          fournisseurs.map(
            (fournisseur) {
              return PlutoRow(
                cells: {
                  "fournisseur": PlutoCell(value: fournisseur.fullname),
                  "email": PlutoCell(value: fournisseur.email ?? "********"),
                  "contact":
                      PlutoCell(value: fournisseur.contact ?? "********"),
                  "fax": PlutoCell(value: fournisseur.phone ?? "********"),
                  "adresse":
                      PlutoCell(value: fournisseur.adresse ?? "********"),
                  "action": PlutoCell(value: fournisseur),
                },
              );
            },
          ),
        );

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
                          addwidget: FournisseurForm(),
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
