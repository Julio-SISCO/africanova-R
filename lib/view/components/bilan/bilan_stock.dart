import 'package:africanova/controller/bilan_controller.dart';
import 'package:africanova/database/bilan.dart';
import 'package:africanova/theme/theme_provider.dart';
import 'package:africanova/view/components/bilan/stock_filters.dart';
import 'package:africanova/widget/table_config.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:provider/provider.dart';

class BilanStock extends StatefulWidget {
  final Function(Widget) switchView;
  const BilanStock({super.key, required this.switchView});

  @override
  State<BilanStock> createState() => _BilanStockState();
}

class _BilanStockState extends State<BilanStock> {
  late PlutoGridStateManager stateManager;
  List<PlutoRow> rows = [];
  bool isLoading = false;
  String? _selectedCriterion;
  String? _selectedCondition;
  int? _value;
  bool check = false;

  _applyFilter(
    String? criteria,
    String? condition,
    int? value,
    DateTime start,
    DateTime end,
  ) async {
    setState(() {
      isLoading = true;
      rows.clear();
    });
    final result = await getBilan(startDate: start, endDate: end);
    if (result["status"]) {
      setState(() {
        _selectedCondition = condition;
        _selectedCriterion = criteria;
        _value = value;
        check = _selectedCondition != null &&
            _selectedCriterion != null &&
            _value != null &&
            _value! >= 0;
        isLoading = false;
      });
    } else {
      Get.snackbar(
        '',
        "Impossible d'appliquer le filtre",
        titleText: SizedBox.shrink(),
        messageText: Center(
          child: Text("Impossible d'appliquer le filtre"),
        ),
        maxWidth: 300,
        snackPosition: SnackPosition.BOTTOM,
      );
      setState(() {
        isLoading = false;
      });
    }
  }

  Map<String, dynamic> bilanToMap(Bilan bilan) {
    return {
      'quantite initiale': bilan.stockInitial,
      'quantite finale esperable': bilan.stockFinalEsperable,
      'total debite': bilan.totalDebite,
      'total approvision': bilan.totalApprovision,
      'quantite actuelle': bilan.article.stock ?? 0,
    };
  }

  filter() {
    final bilans = Hive.box<Bilan>("bilanBox").values.toList();

    if (check) {
      rows.addAll(bilans.where((bilan) {
        final bilanMap = bilanToMap(bilan);
        if (!bilanMap.containsKey(_selectedCriterion)) {
          return false;
        }

        final int bilanValue =
            int.tryParse(bilanMap[_selectedCriterion]!.toString()) ?? 0;
        if (_selectedCondition == 'supérieur à') {
          return bilanValue > _value!;
        }
        if (_selectedCondition == 'inférieur à') {
          return bilanValue < _value!;
        }
        if (_selectedCondition == 'supérieur ou égale à') {
          return bilanValue >= _value!;
        }
        if (_selectedCondition == 'inférieur ou égale à') {
          return bilanValue <= _value!;
        }

        return false;
      }).map((bilan) => _buildRow(bilan)));
      return;
    }
    rows.addAll(bilans.map((bilan) => _buildRow(bilan)));
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4.0),
            ),
            elevation: 0.0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 0.0,
              children: [
                StockFilters(
                  switchView: widget.switchView,
                  setValues:
                      (String? a, String? b, int? c, DateTime d, DateTime e) =>
                          _applyFilter(a, b, c, d, e),
                ),
                Expanded(
                  child: ValueListenableBuilder<Box<Bilan>>(
                    valueListenable: Hive.box<Bilan>("bilanBox").listenable(),
                    builder: (context, box, _) {
                      final bilans = box.values.toList();
                      rows.clear();

                      if (!check) {
                        rows.addAll(bilans.map((bilan) => _buildRow(bilan)));
                      } else {
                        filter();
                      }
                      return LayoutBuilder(
                        builder: (context, constraints) {
                          double totalWidth = constraints.maxWidth;
                          return Padding(
                            padding: const EdgeInsets.only(
                              left: 6.0,
                              right: 6.0,
                              bottom: 6.0,
                            ),
                            child: PlutoGrid(
                              configuration: Provider.of<ThemeProvider>(context)
                                      .isLightTheme()
                                  ? PlutoGridConfiguration(
                                      style: tableStyle,
                                      columnFilter: columnFilterConfig,
                                    )
                                  : PlutoGridConfiguration.dark(
                                      columnFilter: columnFilterConfig,
                                      style: darkTableStyle,
                                    ),
                              columns: buildColumns((totalWidth - 16) / 6),
                              rows: rows,
                              onChanged: (PlutoGridOnChangedEvent event) {
                                stateManager.notifyListeners();
                              },
                              onLoaded: (PlutoGridOnLoadedEvent event) {
                                event.stateManager.setShowColumnFilter(true);
                                event.stateManager.setSelectingMode(
                                    PlutoGridSelectingMode.cell);
                                stateManager = event.stateManager;
                              },
                              rowColorCallback: (rowColorContext) {
                                if (rowColorContext.row.cells.entries
                                        .elementAt(4)
                                        .value
                                        .value !=
                                    rowColorContext.row.cells.entries
                                        .elementAt(5)
                                        .value
                                        .value) {
                                  return Colors.red.withOpacity(0.2);
                                }
                                if (rowColorContext.row.cells.entries
                                        .elementAt(5)
                                        .value
                                        .value <=
                                    10) {
                                  return Colors.yellow.withOpacity(0.5);
                                }

                                return Provider.of<ThemeProvider>(context,
                                            listen: false)
                                        .isLightTheme()
                                    ? Colors.grey.shade300
                                    : Color(0xFF262D4D);
                              },
                              createFooter: (stateManager) {
                                stateManager.setPageSize(10, notify: false);
                                return PlutoPagination(
                                  stateManager,
                                  pageSizeToMove: 1,
                                );
                              },
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        if (isLoading)
          Container(
            color: Colors.transparent,
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Center(
              child: Container(
                color: Provider.of<ThemeProvider>(context)
                    .themeData
                    .colorScheme
                    .tertiary
                    .withOpacity(0.3),
                width: 80,
                height: 80,
                padding: EdgeInsets.all(20.0),
                child: CircularProgressIndicator(
                  color: Provider.of<ThemeProvider>(context)
                      .themeData
                      .colorScheme
                      .secondary,
                ),
              ),
            ),
          ),
      ],
    );
  }

  List<PlutoColumn> buildColumns(double columnWidth) {
    return [
      PlutoColumn(
        title: 'Article',
        field: 'article',
        type: PlutoColumnType.text(),
        width: columnWidth,
        enableContextMenu: false,
      ),
      PlutoColumn(
        title: 'Quantité Initiale',
        field: 'stock_initiale',
        type: PlutoColumnType.number(),
        width: columnWidth,
        enableContextMenu: false,
      ),
      PlutoColumn(
        title: 'Quantité Totale Débitée',
        field: 'total_debite',
        type: PlutoColumnType.number(),
        width: columnWidth,
        enableContextMenu: false,
      ),
      PlutoColumn(
        title: 'Quantité Approvisionnée',
        field: 'total_approvision',
        type: PlutoColumnType.number(),
        width: columnWidth,
        enableContextMenu: false,
      ),
      PlutoColumn(
        title: 'Quantité Finale Espérable',
        field: 'stock_finale_esperable',
        type: PlutoColumnType.number(),
        width: columnWidth,
        enableContextMenu: false,
      ),
      PlutoColumn(
        title: 'Quantité Actuelle',
        field: 'quantite_actuelle',
        type: PlutoColumnType.number(),
        width: columnWidth,
        enableContextMenu: false,
      ),
    ];
  }

  PlutoRow _buildRow(Bilan bilan) {
    return PlutoRow(
      cells: {
        'article': PlutoCell(value: bilan.article.libelle),
        'stock_initiale': PlutoCell(value: bilan.stockInitial),
        'total_debite': PlutoCell(value: bilan.totalDebite),
        'total_approvision': PlutoCell(value: bilan.totalApprovision),
        'stock_finale_esperable': PlutoCell(value: bilan.stockFinalEsperable),
        'quantite_actuelle': PlutoCell(value: bilan.article.stock),
      },
      type: PlutoRowType.normal(),
      sortIdx: 0,
    );
  }
}
