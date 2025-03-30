import 'package:africanova/controller/user_controller.dart';
import 'package:africanova/provider/auth_provider.dart';
import 'package:africanova/database/user.dart';
import 'package:africanova/provider/permissions_providers.dart';
import 'package:africanova/static/theme.dart';
import 'package:africanova/theme/theme_provider.dart';
import 'package:africanova/util/date_formatter.dart';
import 'package:africanova/view/components/security/user_edit.dart';
import 'package:africanova/widget/dialogs.dart';
import 'package:africanova/widget/table_config.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:provider/provider.dart';

class UserTable extends StatefulWidget {
  final List<User> users;
  final VoidCallback disable;
  final Function(Widget?) switchView;
  const UserTable({
    super.key,
    required this.users,
    required this.disable,
    required this.switchView,
  });

  @override
  State<UserTable> createState() => _UserTableState();
}

class _UserTableState extends State<UserTable> {
  int _id = 0;
  late PlutoGridStateManager stateManager;

  void disable(int id) async {
    final result = await disableUser(id);

    if (result['status']) {
      // disableAction();
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

  void enable(int id) async {
    final result = await enableUser(id);

    // if (result['status']) {
    //   disableAction();
    // }:

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

  void delete(int id) async {
    final result = await deleteUser(id);

    if (result['status']) {
      // disableAction();
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
        title: "#",
        field: "d",
        type: PlutoColumnType.text(),
        width: 50,
        minWidth: 50,
        enableContextMenu: false,
        enableFilterMenuItem: false,
        enableSorting: false,
        renderer: (rendererContext) {
          return Center(
            child: CircleAvatar(
              backgroundColor: getRandomColor(),
              radius: 20,
              child: Text(
                rendererContext.cell.value.username[0].toUpperCase(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
          );
        },
      ),
      PlutoColumn(
        title: "Utilisateur",
        field: "utilisateur",
        type: PlutoColumnType.text(),
        width: width,
        minWidth: width,
        enableContextMenu: false,
      ),
      PlutoColumn(
        title: "Profile",
        field: "profile",
        type: PlutoColumnType.text(),
        width: width,
        minWidth: width,
        enableContextMenu: false,
      ),
      PlutoColumn(
        title: "Roles",
        field: "roles",
        type: PlutoColumnType.text(),
        width: width,
        minWidth: width,
        enableContextMenu: false,
      ),
      PlutoColumn(
        title: "Permissions",
        field: "permissions",
        type: PlutoColumnType.text(),
        width: width,
        minWidth: width,
        enableContextMenu: false,
      ),
      PlutoColumn(
        title: "Status",
        field: "status",
        type: PlutoColumnType.text(),
        width: 100,
        minWidth: 100,
        enableContextMenu: false,
        enableFilterMenuItem: false,
        enableSorting: false,
        renderer: (rendererContext) {
          return Center(
            child: rendererContext.cell.value.isActive
                ? Icon(
                    Icons.check_circle,
                    color: Colors.green[800],
                  )
                : Icon(
                    Icons.cancel,
                    color: Colors.red[600],
                  ),
          );
        },
      ),
      PlutoColumn(
        title: "Création",
        field: "creation",
        type: PlutoColumnType.text(),
        width: width,
        minWidth: width,
        enableContextMenu: false,
      ),
      PlutoColumn(
        title: "Dernière activite",
        field: "derniere_activite",
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
        enableFilterMenuItem: false,
        enableSorting: false,
        renderer: (rendererContext) {
          return FutureBuilder<Map<String, bool>>(
            future: checkPermissions(
                ["modifier comptes", "voir comptes", "supprimer comptes"]),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const SizedBox();
              var permissions = snapshot.data!;
              return Wrap(
                alignment: WrapAlignment.center,
                children: [
                  if (permissions['supprimer comptes'] ?? false) ...[
                    if (!rendererContext.cell.value.isActive)
                      IconButton(
                        icon: Icon(
                          Icons.check_circle,
                          color: Colors.green[800],
                        ),
                        onPressed: rendererContext.cell.value.id == _id
                            ? null
                            : () {
                                enable(rendererContext.cell.value.id ?? 0);
                              },
                      ),
                    if (rendererContext.cell.value.isActive)
                      IconButton(
                        icon: const Icon(Icons.cancel, color: Colors.red),
                        onPressed: rendererContext.cell.value.id == _id
                            ? null
                            : () {
                                disable(rendererContext.cell.value.id ?? 0);
                              },
                      ),
                    IconButton(
                      icon: Icon(
                        Icons.delete,
                        color: rendererContext.cell.value.id == _id
                            ? null
                            : Colors.red[600],
                      ),
                      onPressed: rendererContext.cell.value.id == _id
                          ? null
                          : () {
                              showCancelConfirmationDialog(
                                context,
                                () {
                                  delete(rendererContext.cell.value.id ?? 0);
                                },
                                'Êtes-vous sûr de vouloir supprimer ce compte ?',
                              );
                            },
                    ),
                  ],
                  if (permissions['modifier comptes'] ?? false)
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.blue[800]),
                      onPressed: () {
                        widget.switchView(
                          UserEdit(
                            user: rendererContext.cell.value,
                            disableAction: () {},
                            switchView: widget.switchView,
                          ),
                        );
                      },
                    ),
                  if (permissions['voir comptes'] ?? false)
                    IconButton(
                      icon: Icon(Icons.info),
                      onPressed: () {},
                    ),
                ],
              );
            },
          );
        },
      ),
    ];
  }

  PlutoRow _buildRow(User user) {
    return PlutoRow(cells: {
      "d": PlutoCell(value: user),
      "utilisateur": PlutoCell(value: user.username),
      "profile": PlutoCell(
          value: user.employer != null
              ? '${user.employer!.prenom} ${user.employer!.nom}'
              : 'Inconnu'),
      "roles": PlutoCell(
        value: (user.roles != null && user.roles!.isNotEmpty)
            ? user.roles!.length == 1
                ? user.roles![0].name
                : '${user.roles!.length} roles'
            : 'Aucun rôle',
      ),
      "permissions": PlutoCell(
          value: user.permissions?.isNotEmpty ?? false
              ? '${user.permissions!.length} permissions'
              : 'Aucune permission'),
      "status": PlutoCell(value: user),
      "creation": PlutoCell(
          value: DateFormat('dd MMM yyyy', 'fr').format(user.createdAt!)),
      "derniere_activite": PlutoCell(
          value: user.lastLogin != null
              ? formatDate(user.lastLogin)
              : 'Aucune activité détectée'),
      "action": PlutoCell(value: user),
    });
  }

  @override
  void initState() {
    super.initState();
    getId();
  }

  getId() async {
    final user = await getAuthUser();
    if (user != null) {
      setState(() {
        _id = user.id ?? 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double totalWidth = constraints.maxWidth;
        return Card(
          margin: EdgeInsets.zero,
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
                                columnFilter: columnFilterConfig)
                            : PlutoGridConfiguration.dark(
                                columnFilter: columnFilterConfig,
                                style: darkTableStyle),
                    columns: buildColumns((totalWidth - 164.0) / 7),
                    rows: widget.users.map((user) => _buildRow(user)).toList(),
                    onLoaded: (event) {
                      stateManager = event.stateManager;
                      stateManager.setShowColumnFilter(true);
                      stateManager
                          .setSelectingMode(PlutoGridSelectingMode.cell);
                    },
                    rowColorCallback: (rowColorContext) {
                      if (rowColorContext.row.cells.entries
                              .elementAt(5)
                              .value
                              .value
                              .id ==
                          _id) {
                        return const Color(0xFF05CA85);
                      }

                      return Provider.of<ThemeProvider>(context, listen: false)
                              .isLightTheme()
                          ? Colors.grey.shade300
                          : Color(0xFF262D4D);
                    },
                    createFooter: (stateManager) {
                      stateManager.setPageSize(15, notify: false);
                      return PlutoPagination(stateManager, pageSizeToMove: 1);
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
