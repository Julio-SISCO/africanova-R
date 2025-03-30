// ignore_for_file: unnecessary_import

import 'package:africanova/controller/categorie_controller.dart';
import 'package:africanova/provider/permissions_providers.dart';

import 'package:africanova/theme/theme_provider.dart';
import 'package:africanova/view/components/categories/categorie_form.dart';
import 'package:africanova/widget/table_config.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:provider/provider.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:africanova/database/categorie.dart';

class CategorieTable extends StatefulWidget {
  final Function(Widget) switchView;
  const CategorieTable({super.key, required this.switchView});

  @override
  State<CategorieTable> createState() => _CategorieTableState();
}

class _CategorieTableState extends State<CategorieTable> {
  final List<PlutoColumn> columns = [];
  final List<PlutoRow> rows = [];

  late PlutoGridStateManager stateManager;

  List<PlutoColumn> buildColumns(double width) {
    return [
      PlutoColumn(
        title: "Libelle",
        field: "libelle",
        type: PlutoColumnType.text(),
        width: width,
        minWidth: width,
        enableContextMenu: false,
      ),
      PlutoColumn(
        title: "Nombre d'articles",
        field: "nb_article",
        type: PlutoColumnType.number(),
        width: width,
        minWidth: width,
        enableContextMenu: false,
      ),
      PlutoColumn(
        title: "Action",
        field: "action",
        type: PlutoColumnType.text(),
        width: width,
        minWidth: 100,
        enableContextMenu: false,
        enableFilterMenuItem: false,
        renderer: (rendererContext) {
          return FutureBuilder<Map<String, bool>>(
            future: checkPermissions([
              'voir articles',
              'modifier categories',
              'supprimer categories',
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
                return Center(child: Text('${snapshot.error}'));
              }

              var permissions = snapshot.data ?? {};
              return PopupMenuButton<int>(
                onSelected: (value) async {
                  if (value == 0) {
                  } else if (value == 1) {
                    widget.switchView(
                      CategorieForm(
                        editableCategorie: rendererContext.cell.value,
                      ),
                    );
                  } else if (value == 2) {
                    bool? confirmation = await showConfirmationDialog(context);

                    if (confirmation == true) {
                      var result = await supprimerCategorie(
                          rendererContext.cell.value.id ?? 0);
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
                itemBuilder: (BuildContext context) {
                  return [
                    if (permissions['voir articles'] ?? false)
                      PopupMenuItem(
                        height: 16.0 * 2,
                        value: 0,
                        child: Text("Articles"),
                      ),
                    if (permissions['modifier categories'] ?? false)
                      PopupMenuItem(
                        height: 16.0 * 2,
                        value: 1,
                        child: Text("Modifier"),
                      ),
                    if (permissions['supprimer categories'] ?? false)
                      PopupMenuItem(
                        height: 16.0 * 2,
                        value: 2,
                        child: Text("Supprimer"),
                      ),
                  ];
                },
                icon: Icon(Icons.more_horiz),
              );
            },
          );
        },
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Box<Categorie>>(
      valueListenable: Hive.box<Categorie>('categorieBox').listenable(),
      builder: (context, box, _) {
        final categories = box.values.toList();
        rows.clear();
        rows.addAll(
          categories.map(
            (categorie) {
              return PlutoRow(
                cells: {
                  'libelle': PlutoCell(value: categorie.libelle),
                  'nb_article': PlutoCell(value: 0),
                  'action': PlutoCell(value: categorie),
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
                        columns: buildColumns(totalWidth / 3),
                        rows: rows,
                        onChanged: (PlutoGridOnChangedEvent event) {},
                        onLoaded: (PlutoGridOnLoadedEvent event) {
                          event.stateManager.setShowColumnFilter(true);
                          event.stateManager
                              .setSelectingMode(PlutoGridSelectingMode.cell);

                          stateManager = event.stateManager;
                        },
                        createHeader: (stateManager) => TableHeader(
                          enableDateFilter: false,
                          addAction: (Widget w) {
                            widget.switchView(w);
                          },
                          addwidget: CategorieForm(),
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
