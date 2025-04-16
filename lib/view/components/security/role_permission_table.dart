import "package:africanova/database/permission.dart";
import "package:africanova/database/role.dart";
import "package:africanova/provider/permissions_providers.dart";
import "package:africanova/theme/theme_provider.dart";
import "package:africanova/widget/table_config.dart";
import "package:flutter/material.dart";
import "package:pluto_grid/pluto_grid.dart";
import "package:provider/provider.dart";

class RolePermissionTable extends StatefulWidget {
  final Function(Widget) switchView;
  final List<Role> roles;
  final List<Permission> permissions;
  const RolePermissionTable({
    super.key,
    required this.switchView,
    required this.roles,
    required this.permissions,
  });

  @override
  State<RolePermissionTable> createState() => _RolePermissionTableState();
}

class _RolePermissionTableState extends State<RolePermissionTable> {
  late PlutoGridStateManager stateManager;

  List<PlutoColumn> buildColumns(List<Role> roles, double width) {
    return [
      PlutoColumn(
        title: '#',
        field: "count",
        type: PlutoColumnType.number(),
        width: 60,
        minWidth: 60,
        enableContextMenu: false,
        enableFilterMenuItem: false,
        enableSorting: false,
      ),
      PlutoColumn(
        title: 'permission'.toUpperCase(),
        field: "permission",
        type: PlutoColumnType.text(),
        width: width,
        minWidth: width,
        enableContextMenu: false,
        renderer: (rendererContext) {
          return Text(rendererContext.cell.value.name.toUpperCase());
        },
      ),
      ...List.generate(
        widget.roles.length,
        (index) => PlutoColumn(
          title: roles[index].name.toUpperCase(),
          field: "role${index + 1}",
          type: PlutoColumnType.text(),
          width: width,
          minWidth: width,
          enableContextMenu: false,
          enableFilterMenuItem: false,
          enableSorting: false,
          renderer: (rendererContext) {
            return Center(
              child: buildStatusWithPermission(
                roles[index].id ?? 0,
                rendererContext.cell.value.name,
              ),
            );
          },
        ),
      ),
    ];
  }

// Fonction pour éviter la duplication du code
  PlutoRow _buildRow(Permission permission, int length, int index) {
    return PlutoRow(
      cells: {
        "count": PlutoCell(value: index),
        "permission": PlutoCell(value: permission),
        for (int i = 0; i < length; i++)
          "role${i + 1}": PlutoCell(value: permission),
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double totalWidth = constraints.maxWidth;
        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4.0),
          ),
          margin: EdgeInsets.all(0.0),
          color:
              Provider.of<ThemeProvider>(context).themeData.colorScheme.surface,
          
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
                    columns: buildColumns(
                      widget.roles,
                      (totalWidth - 74.0) / (widget.roles.length + 1),
                    ),
                    rows: [
                      for (var entry in widget.permissions.asMap().entries)
                        _buildRow(
                            entry.value, widget.roles.length, (entry.key + 1)),
                    ],
                    onChanged: (PlutoGridOnChangedEvent event) {},
                    onLoaded: (PlutoGridOnLoadedEvent event) {
                      event.stateManager.setShowColumnFilter(true);
                      event.stateManager
                          .setSelectingMode(PlutoGridSelectingMode.cell);

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
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
