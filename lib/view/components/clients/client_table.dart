import "package:africanova/controller/client_controller.dart";
import "package:africanova/database/client.dart";
import "package:africanova/provider/permissions_providers.dart";
import "package:africanova/theme/theme_provider.dart";
import "package:africanova/view/components/clients/client_form.dart";
import "package:africanova/widget/table_config.dart";
import "package:flutter/material.dart";
import "package:get/get.dart";
import "package:hive_flutter/hive_flutter.dart";
import "package:pluto_grid/pluto_grid.dart";
import "package:provider/provider.dart";

class ClientTable extends StatefulWidget {
  final Function(Widget) switchView;
  const ClientTable({super.key, required this.switchView});

  @override
  State<ClientTable> createState() => _ClientTableState();
}

class _ClientTableState extends State<ClientTable> {
  late List<Client> clients = [];
  late String query = "";
  @override
  void initState() {
    super.initState();
    _fetchAndStoreTopArticles();
  }

  Future<void> _fetchAndStoreTopArticles() async {
    await getClients();
  }

  final List<PlutoColumn> columns = [];
  final List<PlutoRow> rows = [];

  late PlutoGridStateManager stateManager;

  List<PlutoColumn> buildColumns(double width) {
    return [
      PlutoColumn(
        title: "Client",
        field: "client",
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
                'enregistrer clients',
                'modifier clients',
                'voir clients',
                'supprimer clients',
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
                    if (permissions['voir clients'] ?? false)
                      IconButton(
                        icon: Icon(
                          Icons.shopping_cart_checkout,
                        ),
                        onPressed: () {},
                      ),
                    if ((permissions['modifier clients'] ?? false))
                      IconButton(
                        icon: Icon(
                          Icons.edit,
                          color: Colors.blue[800],
                        ),
                        onPressed: () {
                          widget.switchView(ClientForm(
                            editableClient: rendererContext.cell.value,
                          ));
                        },
                      ),
                    if (permissions['supprimer clients'] ?? false)
                      IconButton(
                        icon: Icon(
                          Icons.delete,
                          color: Colors.red[600],
                        ),
                        onPressed: () async {
                          bool? confirmation =
                              await showConfirmationDialog(context);
                          if (confirmation == true) {
                            var result = await supprimerClient(
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
    return ValueListenableBuilder<Box<Client>>(
      valueListenable: Hive.box<Client>("clientBox").listenable(),
      builder: (context, box, _) {
        final clients = box.values.toList();
        clients.sort((a, b) => b.createdAt!.compareTo(a.createdAt!));

        rows.clear();

        rows.addAll(
          clients.map(
            (client) {
              return PlutoRow(
                cells: {
                  "client": PlutoCell(value: client.fullname),
                  "email": PlutoCell(value: client.email ?? "********"),
                  "contact": PlutoCell(value: client.contact ?? "********"),
                  "fax": PlutoCell(value: client.phone ?? "********"),
                  "adresse": PlutoCell(value: client.adresse ?? "********"),
                  "action": PlutoCell(value: client),
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
                          addwidget: ClientForm(),
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
