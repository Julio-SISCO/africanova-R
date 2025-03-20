import 'package:africanova/provider/auth_provider.dart';
import 'package:africanova/controller/user_controller.dart';
import 'package:africanova/database/user.dart';
import 'package:flutter/material.dart';

class UserTable extends StatefulWidget {
  final List<User> users;
  final VoidCallback disable;
  const UserTable({
    super.key,
    required this.users,
    required this.disable,
  });

  @override
  State<UserTable> createState() => _UserTableState();
}

class _UserTableState extends State<UserTable> {
  int _id = 0;
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
    return SingleChildScrollView(
      padding: EdgeInsets.all(8.0),
      child: Column(
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width,
            child: PaginatedDataTable(
              headingRowColor: WidgetStateProperty.resolveWith<Color?>(
                  (Set<WidgetState> states) => Colors.blueGrey),
              horizontalMargin: 0,
              columnSpacing: 24,
              columns: [
                DataColumn(
                  label: Text(
                    "".toUpperCase(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                  headingRowAlignment: MainAxisAlignment.center,
                ),
                DataColumn(
                  label: Text(
                    "Utilisateur".toUpperCase(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    "Employé".toUpperCase(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    "Rôle(s)".toUpperCase(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    "Permissions".toUpperCase(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    "Statut".toUpperCase(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                  headingRowAlignment: MainAxisAlignment.center,
                ),
                DataColumn(
                  label: Text(
                    "Créé le".toUpperCase(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    "Dernière activité".toUpperCase(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    "Action".toUpperCase(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                  headingRowAlignment: MainAxisAlignment.center,
                ),
              ],
              source: UserRolePermissionDataSource(
                  widget.users, _id, context, widget.disable),
              rowsPerPage: 10,
              onRowsPerPageChanged: null,
            ),
          ),
        ],
      ),
    );
  }
}
