import 'package:africanova/controller/permissions_controller.dart';
import 'package:africanova/database/permission.dart';
import 'package:africanova/database/role.dart';
import 'package:africanova/theme/theme_provider.dart';
import 'package:africanova/view/components/security/edit_role_form.dart';
import 'package:africanova/view/components/security/relation_table.dart';
import 'package:africanova/view/components/security/role_form.dart';
import 'package:africanova/view/components/security/user_role_permission.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RoleAndPermission extends StatefulWidget {
  const RoleAndPermission({super.key});

  @override
  State<RoleAndPermission> createState() => _RoleAndPermissionState();
}

class _RoleAndPermissionState extends State<RoleAndPermission> {
  late Future<Map<String, dynamic>> rolesFuture;

  @override
  void initState() {
    super.initState();
    rolesFuture = getRoles();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Card(
        elevation: 0.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(2.0),
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 16.0, right: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 0.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(2.0),
                ),
                color: Provider.of<ThemeProvider>(context)
                    .themeData
                    .colorScheme
                    .primary,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Wrap(
                            children: [
                              InkWell(
                                child: Wrap(
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    Text(
                                      'Accueil'.toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                    Icon(
                                      Icons.navigate_next_rounded,
                                    ),
                                  ],
                                ),
                                onTap: () => Navigator.pop(context),
                              ),
                              Wrap(
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  Text(
                                    'Sécurité'.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Icon(
                                    Icons.navigate_next_rounded,
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Text(
                            'Roles'.toUpperCase(),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Wrap(
                        spacing: 24.0,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          InkWell(
                            child: Wrap(
                              children: [
                                Text(
                                  'Utilisateurs & Permissions'.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ],
                            ),
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (builder) => UserRolePermission(),
                              ),
                            ),
                          ),
                          SizedBox(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                elevation: 4.0,
                                backgroundColor:
                                    Provider.of<ThemeProvider>(context)
                                        .themeData
                                        .colorScheme
                                        .secondary,
                                foregroundColor:
                                    Provider.of<ThemeProvider>(context)
                                        .themeData
                                        .colorScheme
                                        .tertiary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(2.0),
                                ),
                              ),
                              onPressed: () {
                                showRoleForm(context);
                              },
                              icon: Icon(
                                Icons.add,
                                color: Provider.of<ThemeProvider>(context)
                                    .themeData
                                    .colorScheme
                                    .tertiary,
                              ),
                              label: Text(
                                'Nouveau'.toUpperCase(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Card(
                  elevation: 0.0,
                  color: Provider.of<ThemeProvider>(context)
                      .themeData
                      .colorScheme
                      .primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(2.0),
                  ),
                  child: FutureBuilder<Map<String, dynamic>>(
                    future: rolesFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('${snapshot.error}'));
                      } else if (!snapshot.hasData ||
                          !snapshot.data!['status']) {
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
                        final List<Permission> permissions =
                            permissionList.toList();

                        return RelationTable(
                          roles: roles.reversed.toList(),
                          permissions: permissions,
                        );
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
