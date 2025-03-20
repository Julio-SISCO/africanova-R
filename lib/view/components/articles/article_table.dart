// ignore_for_file: unnecessary_import

import 'package:africanova/controller/article_controller.dart';
import 'package:africanova/provider/permissions_providers.dart';

import 'package:africanova/theme/theme_provider.dart';
import 'package:africanova/view/components/articles/article_detail.dart';
import 'package:africanova/view/components/articles/article_form.dart';
import 'package:africanova/widget/dialogs.dart';
import 'package:africanova/widget/table_config.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:provider/provider.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:africanova/database/article.dart';

class ArticleTable extends StatefulWidget {
  final Function(Widget) switchView;

  const ArticleTable({super.key, required this.switchView});

  @override
  State<ArticleTable> createState() => _ArticleTableState();
}

class _ArticleTableState extends State<ArticleTable> {
  final List<PlutoColumn> columns = [];
  final List<PlutoRow> rows = [];

  late PlutoGridStateManager stateManager;

  @override
  void initState() {
    super.initState();
    _fetchAndStoreTopArticles();
  }

  Future<void> _fetchAndStoreTopArticles() async {
    await getArticles();
  }

  void _delete(context, int id) async {
    final result = await supprimerArticle(id);
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

  List<PlutoColumn> buildColumns(double width) {
    return [
      PlutoColumn(
        title: 'Libelle',
        field: 'libelle',
        type: PlutoColumnType.text(),
        width: width,
        minWidth: width,
        enableContextMenu: false,
      ),
      PlutoColumn(
        title: 'Catégorie',
        field: 'categorie',
        type: PlutoColumnType.text(),
        width: width,
        minWidth: width,
        enableContextMenu: false,
      ),
      PlutoColumn(
        title: 'Stock',
        field: 'stock',
        type: PlutoColumnType.number(),
        width: width,
        minWidth: width,
        enableContextMenu: false,
      ),
      PlutoColumn(
        title: 'Action',
        field: 'action',
        type: PlutoColumnType.text(),
        width: width,
        minWidth: width,
        enableContextMenu: false,
        enableFilterMenuItem: false,
        enableSorting: false,
        renderer: (rendererContext) {
          return FutureBuilder<Map<String, bool>>(
            future: checkPermissions([
              'voir articles',
              'modifier articles',
              'supprimer articles',
              'modifier stock',
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
                  if (permissions['supprimer articles'] ?? false)
                    Tooltip(
                      message: 'Supprimer l\'article',
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
                            'Êtes-vous sûr de vouloir supprimer cet article ?',
                          );
                        },
                      ),
                    ),
                  if ((permissions['modifier articles'] ?? false))
                    Tooltip(
                      message: 'Modifier l\'article',
                      child: IconButton(
                        icon: Icon(
                          Icons.edit,
                          color: Colors.blue[800],
                        ),
                        onPressed: () {
                          widget.switchView(
                            ArticleForm(
                              editableArticle: rendererContext.cell.value,
                            ),
                          );
                        },
                      ),
                    ),
                  if (permissions['voir articles'] ?? false)
                    Tooltip(
                      message: 'Datails de l\'article',
                      child: IconButton(
                        icon: Icon(
                          Icons.info,
                        ),
                        onPressed: () {
                          widget.switchView(
                            ArticleDetail(
                              article: rendererContext.cell.value,
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
        // renderer: (rendererContext) {
        //   return FutureBuilder<Map<String, bool>>(
        //     future: checkPermissions([
        //       'voir articles',
        //       'modifier articles',
        //       'supprimer articles',
        //       'modifier stock',
        //     ]),
        //     builder: (context, snapshot) {
        //       if (snapshot.connectionState == ConnectionState.waiting) {
        //         return const Center(child: CircularProgressIndicator());
        //       }
        //       if (snapshot.hasError) {
        //         return Center(child: Text('${snapshot.error}'));
        //       }

        //       var permissions = snapshot.data ?? {};
        //       return PopupMenuButton<int>(
        //         onSelected: (value) async {
        //           if (value == 0) {
        //           } else if (value == 1) {
        //             widget.switchView(
        //               ArticleForm(
        //                 editableArticle: rendererContext.cell.value,
        //               ),
        //             );
        //           } else if (value == 2) {
        //             bool? confirmation = await showConfirmationDialog(context);

        //             if (confirmation == true) {
        //               var result = await supprimerArticle(
        //                   rendererContext.cell.value.id ?? 0);
        //               Get.snackbar(
        //                 '',
        //                 result["message"],
        //                 titleText: SizedBox.shrink(),
        //                 messageText: Center(
        //                   child: Text(result["message"]),
        //                 ),
        //                 maxWidth: 300,
        //                 snackPosition: SnackPosition.BOTTOM,
        //               );
        //             }
        //           } else if (value == 3) {
        //             await showEditStockDialog(
        //                 context, rendererContext.cell.value);
        //           }
        //         },
        //         itemBuilder: (BuildContext context) {
        //           return [
        //             if (permissions['voir articles'] ?? false)
        //               PopupMenuItem(
        //                 height: 16.0 * 2,
        //                 value: 0,
        //                 child: Text("Détails"),
        //               ),
        //             if (permissions['modifier articles'] ?? false)
        //               PopupMenuItem(
        //                 height: 16.0 * 2,
        //                 value: 1,
        //                 child: Text("Modifier"),
        //               ),
        //             if (permissions['supprimer articles'] ?? false)
        //               PopupMenuItem(
        //                 height: 16.0 * 2,
        //                 value: 2,
        //                 child: Text("Supprimer"),
        //               ),
        //             if (permissions['modifier stock'] ?? false)
        //               PopupMenuItem(
        //                 height: 16.0 * 2,
        //                 value: 3,
        //                 child: Text("Modifier la quantité"),
        //               ),
        //           ];
        //         },
        //         icon: Icon(Icons.more_horiz),
        //       );
        //     },
        //   );
        // },
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Box<Article>>(
      valueListenable: Hive.box<Article>('articleBox').listenable(),
      builder: (context, box, _) {
        final articles = box.values.toList();
        rows.clear();
        rows.addAll(
          articles.map(
            (article) {
              return PlutoRow(
                cells: {
                  'libelle': PlutoCell(value: article.libelle),
                  'categorie':
                      PlutoCell(value: article.categorie?.libelle ?? 'aucune'),
                  'stock': PlutoCell(value: article.stock.toString()),
                  'action': PlutoCell(value: article),
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
                  crossAxisAlignment: CrossAxisAlignment.stretch,
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
                        columns: buildColumns(totalWidth / 4),
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
                          addwidget: ArticleForm(),
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
