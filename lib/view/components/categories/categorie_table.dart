import 'package:africanova/controller/categorie_controller.dart';
import 'package:africanova/provider/permissions_providers.dart';

import 'package:africanova/theme/theme_provider.dart';
import 'package:africanova/view/components/categories/categorie_detail.dart';
import 'package:africanova/view/components/categories/categorie_form.dart';
import 'package:africanova/widget/dialogs.dart';
import 'package:africanova/widget/table_config.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:provider/provider.dart';
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

  void _delete(context, int id) async {
    final result = await supprimerCategorie(id);
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
              'voir categories',
              'modifier categories',
              'supprimer categories',
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
                  if (permissions['supprimer categories'] ?? false)
                    Tooltip(
                      message: 'Supprimer la categorie',
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
                            'Êtes-vous sûr de vouloir supprimer cet categorie ?',
                          );
                        },
                      ),
                    ),
                  if ((permissions['modifier categories'] ?? false))
                    Tooltip(
                      message: 'Modifier la categorie',
                      child: IconButton(
                        icon: Icon(
                          Icons.edit,
                          color: Colors.blue[800],
                        ),
                        onPressed: () {
                          widget.switchView(
                            CategorieForm(
                              editableCategorie: rendererContext.cell.value,
                            ),
                          );
                        },
                      ),
                    ),
                  if (permissions['voir categories'] ?? false)
                    Tooltip(
                      message: 'Datails de la categorie',
                      child: IconButton(
                        icon: Icon(
                          Icons.info,
                        ),
                        onPressed: () {
                          widget.switchView(
                            CategorieDetail(
                              categorie: rendererContext.cell.value,
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
                  'nb_article': PlutoCell(value: categorie.nbArticle ?? 0),
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
