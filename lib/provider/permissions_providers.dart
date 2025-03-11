import 'dart:async';
import 'package:africanova/database/permission.dart';
import 'package:africanova/database/role.dart';
import 'package:africanova/widget/status_point.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

Future<bool> hasPermission(String permissionName) async {
  var box = Hive.box<Permission>('userPermissionBox');

  bool hasPermission =
      box.values.any((permission) => permission.name == permissionName);

  return hasPermission;
}

Future<bool> roleHasPermission(int roleId, String permissionName) async {
  var box = Hive.box<Role>('roleBox');

  Role? role;
  for (int i = 0; i < box.length; i++) {
    if (box.getAt(i)?.id == roleId) {
      role = box.getAt(i);
      break;
    }
  }

  if (role == null) {
    return false;
  }

  bool hasPermission =
      role.permissions.any((permission) => permission.name == permissionName);

  return hasPermission;
}

Future<Map<String, bool>> checkPermissions(List<String> permissionNames) async {
  var box = Hive.box<Permission>('userPermissionBox');
  Map<String, bool> permissions = {};

  for (var permissionName in permissionNames) {
    permissions[permissionName] =
        box.values.any((permission) => permission.name == permissionName);
  }

  return permissions;
}

Widget buildMenuWithPermission(String permissionName, Widget menu) {
  return FutureBuilder<bool>(
    future: hasPermission(permissionName),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const SizedBox();
      }
      if (snapshot.hasData && snapshot.data == true) {
        return menu;
      }
      return SizedBox.shrink();
    },
  );
}

Widget buildStatusWithPermission(
  int role,
  String permissionName,
) {
  return FutureBuilder<bool>(
    future: roleHasPermission(role, permissionName),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const SizedBox();
      }
      if (snapshot.hasData) {
        return StatusPoint(
          isActive: snapshot.data!,
        );
      }
      return Container();
    },
  );
}

class RoleDataSource extends DataTableSource {
  final List<Permission> permissions;
  final List<Role> roles;
  RoleDataSource({
    required this.roles,
    required this.permissions,
  });

  @override
  DataRow getRow(int index) {
    final permission = permissions[index];

    return DataRow(
      cells: [
        DataCell(
          Text(
            permission.name,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        ...List.generate(
          roles.length,
          (roleIndex) => DataCell(
            Center(
              child: buildStatusWithPermission(
                roles[roleIndex].id ?? 0,
                permission.name,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  int get rowCount => permissions.length;

  @override
  int get selectedRowCount => 0;

  @override
  bool get isRowCountApproximate => false;
}
