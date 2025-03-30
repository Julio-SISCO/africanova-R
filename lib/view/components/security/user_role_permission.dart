import 'package:africanova/controller/user_controller.dart';
import 'package:africanova/database/user.dart';
import 'package:africanova/theme/theme_provider.dart';
import 'package:africanova/view/components/security/user_table.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UserRolePermission extends StatefulWidget {
  final Function(Widget?) switchView;
  const UserRolePermission({super.key, required this.switchView});

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
    return Card(
      elevation: 0.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(2.0),
      ),
      margin: EdgeInsets.all(0.0),
      child: FutureBuilder<Map<String, dynamic>>(
        future: usersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
                child: CircularProgressIndicator(
              color: Provider.of<ThemeProvider>(context)
                  .themeData
                  .colorScheme
                  .secondary,
            ));
          } else if (snapshot.hasError) {
            return Center(child: Text('${snapshot.error}'));
          } else if (!snapshot.hasData || !snapshot.data!['status']) {
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
              switchView: widget.switchView,
            );
          }
        },
      ),
    );
  }
}
