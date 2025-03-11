import 'package:africanova/controller/user_controller.dart';
import 'package:africanova/database/user.dart';
import 'package:africanova/view/components/security/user_table.dart';
import 'package:flutter/material.dart';

class UserRolePermission extends StatefulWidget {
  const UserRolePermission({super.key});

  @override
  State<UserRolePermission> createState() => _UserRolePermissionState();
}

class _UserRolePermissionState extends State<UserRolePermission> {
  late Future<Map<String, dynamic>> usersFuture;

  @override
  void initState() {
    super.initState();
    usersFuture = getUsers();
  }

  void showUserForm(BuildContext context) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (BuildContext context) {
        return Container();
      },
    );

    if (result != null) {
      _refreshUsers();
    }
  }

  void showUserEditionForm(BuildContext context, User user) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (BuildContext context) {
        return Container();
      },
    );

    if (result != null) {
      _refreshUsers();
    }
  }

  void disable(int id) async {
    final result = await disableUser(id);

    if (result['status']) {
      _refreshUsers();
    }
  }

  void _refreshUsers() {
    setState(() {
      usersFuture = getUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Card(
        elevation: 0.0,
        color: Colors.white,
        margin: const EdgeInsets.all(16.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        children: [
                          InkWell(
                            child: Wrap(
                              children: [
                                Text(
                                  'Accueil'.toUpperCase(),
                                  style: TextStyle(
                                    color: Colors.green[600],
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                                Icon(
                                  Icons.navigate_next_rounded,
                                  color: Colors.grey[600],
                                ),
                              ],
                            ),
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.pop(context);
                            },
                          ),
                          InkWell(
                            child: Wrap(
                              children: [
                                Text(
                                  'Sécurité'.toUpperCase(),
                                  style: TextStyle(
                                    color: Colors.green[600],
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                                Icon(
                                  Icons.navigate_next_rounded,
                                  color: Colors.grey[600],
                                ),
                              ],
                            ),
                            onTap: () => Navigator.pop(context),
                          ),
                          Text(
                            'Utilisateurs'.toUpperCase(),
                            style: TextStyle(
                              color: Colors.green[600],
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Icon(
                            Icons.navigate_next_rounded,
                            color: Colors.grey[600],
                          ),
                        ],
                      ),
                      Text(
                        'Permissions & Rôles',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Card(
                  color: Colors.grey[100],
                  elevation: 0.0,
                  child: FutureBuilder<Map<String, dynamic>>(
                    future: usersFuture,
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
                        final userList = snapshot.data!['users'];
                        if (userList.isEmpty) {
                          return Center(child: Text('Aucun rôle trouvé.'));
                        }

                        final List<User> users = userList.toList();
                        return UserTable(
                          users: users,
                          disable: _refreshUsers,
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
