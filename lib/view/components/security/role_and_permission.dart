import 'package:africanova/controller/permissions_controller.dart';
import 'package:africanova/database/permission.dart';
import 'package:africanova/database/role.dart';
import 'package:africanova/theme/theme_provider.dart';
import 'package:africanova/view/components/security/access_button.dart';
import 'package:africanova/view/components/security/edit_role_form.dart';
import 'package:africanova/view/components/security/role_form.dart';
import 'package:africanova/view/components/security/role_permission_table.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RoleAndPermission extends StatefulWidget {
  const RoleAndPermission({super.key});

  @override
  State<RoleAndPermission> createState() => _RoleAndPermissionState();
}

class _RoleAndPermissionState extends State<RoleAndPermission> {
  late Future<Map<String, dynamic>> rolesFuture;
  Widget _content = Container();
  @override
  void initState() {
    super.initState();
    rolesFuture = getRoles();
    _content = _defaultContent();
  }

  void showRoleForm(BuildContext context) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (BuildContext context) {
        return RoleForm();
      },
    );

    if (result != null) {
      _refreshRoles();
    }
  }

  void showRoleEditionForm(BuildContext context, Role role) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (BuildContext context) {
        return EditRoleForm(role: role);
      },
    );

    if (result != null) {
      _refreshRoles();
    }
  }

  void _refreshRoles() {
    setState(() {
      rolesFuture = getRoles();
    });
  }

  void _injectContent(Widget? w) {
    setState(() {
      _content = w ?? _defaultContent();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 5.0,
      children: [
        AccessButton(switchView: _injectContent),
        Expanded(
          child: _content,
        ),
      ],
    );
  }

  Widget _defaultContent() {
    return FutureBuilder<Map<String, dynamic>>(
      future: rolesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              color: Provider.of<ThemeProvider>(context)
                  .themeData
                  .colorScheme
                  .secondary,
            ),
          );
        } else if (snapshot.hasError) {
          return Center(child: Text('${snapshot.error}'));
        } else if (!snapshot.hasData || !snapshot.data!['status']) {
          return Center(
            child: Text(
              '${snapshot.data?['message'] ?? 'Aucune donnée'}',
            ),
          );
        } else {
          final roleList = snapshot.data!['roles'];
          final permissionList = snapshot.data!['permissions'];
          if (roleList.isEmpty || permissionList.isEmpty) {
            return Center(child: Text('Aucun rôle trouvé.'));
          }

          final List<Role> roles = roleList.toList();
          final List<Permission> permissions = permissionList.toList();

          return RolePermissionTable(
            switchView: (Widget w) {},
            roles: roles.reversed.toList(),
            permissions: permissions,
          );
        }
      },
    );
  }
}
