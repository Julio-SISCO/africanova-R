import 'package:africanova/controller/service_controller.dart';
import 'package:africanova/database/service.dart';
import 'package:africanova/provider/permissions_providers.dart';
import 'package:africanova/theme/theme_provider.dart';
import 'package:africanova/util/date_formatter.dart';
import 'package:africanova/view/components/services/service_detail.dart';
import 'package:africanova/widget/table_config.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:provider/provider.dart';

class ServiceTable extends StatefulWidget {
  final Function(Widget) switchView;
  const ServiceTable({super.key, required this.switchView});

  @override
  State<ServiceTable> createState() => _ServiceTableState();
}

class _ServiceTableState extends State<ServiceTable> {
  List<PlutoRow> rows = [];
  List<PlutoColumn> columns = [];
  late PlutoGridStateManager stateManager;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _fetchAndStoreTopArticles();
  }

  Future<void> _fetchAndStoreTopArticles() async {
    await getService();
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
        title: "Services",
        field: "services",
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
        title: "Montant",
        field: "montant",
        type: PlutoColumnType.text(),
        width: width,
        minWidth: width,
        enableContextMenu: false,
      ),
      PlutoColumn(
        title: "Fait Par",
        field: "traiteur",
        type: PlutoColumnType.text(),
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
        title: "Actions",
        field: "actions",
        type: PlutoColumnType.text(),
        width: 100,
        minWidth: 100,
        enableContextMenu: false,
        enableFilterMenuItem: false,
        enableSorting: false,
        renderer: (rendererContext) {
          return FutureBuilder<Map<String, bool>>(
            future: checkPermissions([
              'voir services',
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
                  if (permissions['voir services'] ?? false)
                    Tooltip(
                      message: 'Datails du service',
                      child: IconButton(
                        icon: Icon(
                          Icons.info,
                        ),
                        onPressed: () {
                          widget.switchView(
                            ServiceDetail(
                              service: rendererContext.cell.value,
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

  PlutoRow _buildRow(Service service) {
    final formattedDate = formatDate(service.createdAt);
    final typeServices = service.typeServices
            .map((typeService) => typeService.libelle)
            .take(2)
            .join(', ') +
        (service.typeServices.length > 2 ? '...' : '');
    final total = service.total ?? 0;
    final traiteur = service.traiteur.prenom;

    return PlutoRow(cells: {
      'date': PlutoCell(value: formattedDate),
      'services': PlutoCell(value: typeServices),
      'client': PlutoCell(value: service.client.fullname ?? 'Non spécifié'),
      'montant': PlutoCell(value: "${formatMontant(total)} f"),
      'status': PlutoCell(value: service.status == 'en_attente' ? "en attente" : service.status),
      'traiteur': PlutoCell(value: traiteur),
      'actions': PlutoCell(value: service),
    });
  }

  void setDate(DateTime? date) {
    setState(() {
      _selectedDate = date;
    });
  }

  void filterDate() {
    final services = Hive.box<Service>("serviceBox").values.toList();

    if (_selectedDate == null) {
      services.sort((a, b) => (b.createdAt).compareTo(a.createdAt));

      rows.addAll(
        services.map((service) => _buildRow(service)),
      );
      return;
    }
    rows.addAll(
      services
          .where((service) =>
              service.createdAt.year == _selectedDate!.year &&
              service.createdAt.month == _selectedDate!.month &&
              service.createdAt.day == _selectedDate!.day)
          .map((s) => _buildRow(s))
          .toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Box<Service>>(
      valueListenable: Hive.box<Service>("serviceBox").listenable(),
      builder: (context, box, _) {
        final services = box.values.toList();
        services.sort((a, b) => b.createdAt.compareTo(a.createdAt));

        rows.clear();
        if (_selectedDate == null) {
          rows.addAll(
            services.map(
              (service) {
                return _buildRow(service);
              },
            ),
          );
        } else {
          filterDate();
        }
        return LayoutBuilder(
          builder: (context, constraints) {
            double totalWidth = constraints.maxWidth;
            return Padding(
              padding: EdgeInsets.all(6.0),
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
                columns: buildColumns((totalWidth - 140) / 7),
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
                  addAction: (Widget w) {},
                  addwidget: Container(),
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
            );
          },
        );
      },
    );
  }
}
